pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

Singleton {
    id: root

    // Quickshell's built-in Hyprland workspace model cannot be trusted here.
    // It goes stale the moment a workspace id changes: Hyprland announces that
    // as "changeworkspaceid", which this version does not listen for, and once
    // an id is lost every later event for that workspace is dropped too, since
    // they are matched by id. Reordering the strip is exactly an id swap, so the
    // bar would keep phantom entries and light several dots at once.
    //
    // So read the truth from hyprctl, and re-read whenever an event says the
    // workspaces may have moved. Same shape as Brightness: no usable native API,
    // so shell out.
    property var list: []
    property var activeByMonitor: ({})
    property var clients: []

    // The three reads finish at different moments. Publishing each as it lands
    // briefly pairs the *new* workspace with the *old* window list, and the
    // column indicator would light the wrong dot and then animate across to the
    // right one. So stage them and publish all three in one go.
    property var pending: ({})

    function stage(key: string, value: var) {
        const p = root.pending;
        p[key] = value;

        if (("list" in p) && ("active" in p) && ("clients" in p)) {
            root.list = p.list;
            root.activeByMonitor = p.active;
            root.clients = p.clients;
            root.pending = ({});
        }
    }

    // Workspaces on one screen, in strip order.
    function listFor(screen: ShellScreen): var {
        return list.filter(ws => ws.monitor === screen.name);
    }

    // What a screen is currently displaying. Not the same as the focused
    // workspace: an unfocused monitor is still showing one of its own.
    function activeIdFor(screen: ShellScreen): int {
        return activeByMonitor[screen.name] ?? 0;
    }

    // Columns of the scrolling layout on the workspace a screen is showing.
    // Hyprland has no column query, but the layout gives every window in a
    // column the same x, so the distinct x values in tape order *are* the
    // columns -- including the ones scrolled off past the monitor's edges.
    function columnsFor(screen: ShellScreen): var {
        const ws = activeIdFor(screen);
        const xs = [];
        for (const c of clients) {
            if (!c.workspace || c.workspace.id !== ws)
                continue;
            if (c.floating || c.hidden || !c.mapped)
                continue;
            if (!xs.includes(c.at[0]))
                xs.push(c.at[0]);
        }
        return xs.sort((a, b) => a - b);
    }

    function columnCountFor(screen: ShellScreen): int {
        return columnsFor(screen).length;
    }

    // Count and current-ness as one value, so a consumer cannot pair a fresh
    // count with a stale index. See the note in DotRail.
    function columnDotsFor(screen: ShellScreen): var {
        const active = activeColumnFor(screen);
        return columnsFor(screen).map((x, i) => i === active);
    }

    function workspaceDotsFor(screen: ShellScreen): var {
        const active = activeIdFor(screen);
        return listFor(screen).map(ws => ws.id === active);
    }

    // Which column is current. focusHistoryID 0 is the focused window overall,
    // so the lowest one on a workspace is the window that screen would return
    // to -- which keeps the indicator meaningful on the unfocused monitor too.
    function activeColumnFor(screen: ShellScreen): int {
        const ws = activeIdFor(screen);
        let best = null;
        for (const c of clients) {
            if (!c.workspace || c.workspace.id !== ws)
                continue;
            if (c.floating || c.hidden || !c.mapped)
                continue;
            if (best === null || c.focusHistoryID < best.focusHistoryID)
                best = c;
        }
        return best === null ? -1 : columnsFor(screen).indexOf(best.at[0]);
    }

    // Jump to the workspace behind a dot on this screen's rail.
    function focusWorkspace(screen: ShellScreen, index: int) {
        const list = listFor(screen);
        if (index < 0 || index >= list.length)
            return;
        Hyprland.dispatch("hl.dsp.focus({ workspace = " + list[index].id + " })");
    }

    // Jump to a column of the scrolling layout. A column is a set of windows
    // sharing an x, so focus the one in it you were on most recently.
    //
    // hl.dsp.focus's underlying Actions::focus() calls window->warpCursor()
    // unconditionally -- cursor:no_warps does not gate that call, only a
    // separate follow-up in a different code path -- so a plain focus
    // dispatch always drags the mouse to the window's centre. Clicking a
    // dot in the top strip is a mouse action already sitting wherever the
    // user put it; jumping it away is the wrong feel for that specific
    // gesture. Recording the position first and dispatching it straight
    // back after the focus change undoes the warp without touching
    // Hyprland's own source.
    function focusColumn(screen: ShellScreen, index: int) {
        const cols = columnsFor(screen);
        if (index < 0 || index >= cols.length)
            return;

        const ws = activeIdFor(screen);
        const x = cols[index];
        let best = null;
        for (const c of clients) {
            if (!c.workspace || c.workspace.id !== ws)
                continue;
            if (c.floating || c.hidden || !c.mapped || c.at[0] !== x)
                continue;
            if (best === null || c.focusHistoryID < best.focusHistoryID)
                best = c;
        }

        if (best !== null) {
            cursorRestore.address = best.address;
            cursorRestore.running = true;
        }
    }

    Process {
        id: cursorRestore
        property string address: ""
        command: ["hyprctl", "cursorpos"]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",");
                const x = parseInt(parts[0]);
                const y = parseInt(parts[1]);

                Hyprland.dispatch("hl.dsp.focus({ window = \"address:" + cursorRestore.address + "\" })");

                if (!isNaN(x) && !isNaN(y))
                    Hyprland.dispatch("hl.dsp.cursor.move({ x = " + x + ", y = " + y + " })");
            }
        }
    }

    function refresh() {
        root.pending = ({});
        readWorkspaces.running = true;
        readMonitors.running = true;
        readClients.running = true;
    }

    Process {
        id: readWorkspaces
        command: ["hyprctl", "-j", "workspaces"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.stage("list", JSON.parse(text)
                        .filter(ws => ws.id > 0)
                        .sort((a, b) => a.id - b.id));
                } catch (e) {
                    // A torn or empty read just leaves the last good list up.
                }
            }
        }
    }

    Process {
        id: readMonitors
        command: ["hyprctl", "-j", "monitors"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const map = {};
                    for (const mon of JSON.parse(text))
                        map[mon.name] = mon.activeWorkspace.id;
                    root.stage("active", map);
                } catch (e) {
                }
            }
        }
    }

    Process {
        id: readClients
        command: ["hyprctl", "-j", "clients"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.stage("clients", JSON.parse(text));
                } catch (e) {
                }
            }
        }
    }

    // Events arrive in bursts — a reorder is three id changes — so coalesce them
    // into one re-read instead of spawning hyprctl for each.
    Timer {
        id: coalesce
        interval: 30
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            const name = event.name;
            // "custom" is what hyprland.lua emits after reordering columns:
            // Hyprland itself says nothing when the scrolling layout's column
            // order changes, so there is no built-in event to listen for.
            if (name === "custom" || name.includes("workspace") || name.includes("window")
                || name.includes("floating") || name.startsWith("focusedmon")
                || name.startsWith("monitor") || name === "fullscreen")
                coalesce.restart();
        }
    }
}
