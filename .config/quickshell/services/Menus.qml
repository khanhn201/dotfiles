pragma Singleton
import Quickshell
import QtQuick

// The menus that used to be rofi scripts: the app launcher, the power
// menu and the screenshot menu. This holds only what they *are* -- which one is
// open, and what each entry does -- so Overlay.qml can stay presentation.
Singleton {
    id: root

    // "" | "launcher" | "power" | "screenshot" | "commands" | "wallpaperPicker"
    property string mode: ""

    readonly property string scripts: Quickshell.env("HOME") + "/.config/quickshell/scripts"

    function toggle(which: string) {
        root.mode = (root.mode === which) ? "" : which;
    }

    function close() {
        root.mode = "";
    }

    // One step back rather than closing outright, for menus that are reached
    // through another menu (wallpaperPicker is opened from commands).
    function back() {
        if (root.mode === "wallpaperPicker")
            root.mode = "commands";
        else
            root.close();
    }

    // Same actions, icons and order the rofi powermenu had. Lock goes
    // through Session rather than an exec -- LockScreen.qml is our own lock
    // now, not a separate hyprlock process to spawn.
    readonly property var power: [
        { icon: "󰌾", label: "Lock",     action: () => { root.close(); Session.lockRequested(); } },
        { icon: "󰜉", label: "Reboot",   exec: ["systemctl", "reboot"] },
        { icon: "󰐥", label: "Shutdown", exec: ["systemctl", "poweroff"] }
    ]

    readonly property var screenshot: [
        { icon: "󰍹", label: "Capture Desktop", exec: [root.scripts + "/screenshot.sh", "desktop"] },
        { icon: "󰆞", label: "Capture Area",    exec: [root.scripts + "/screenshot.sh", "area"] },
        { icon: "󰖲", label: "Capture Window",  exec: [root.scripts + "/screenshot.sh", "window"] }
    ]

    // The command palette (SUPER + `). Each entry runs its own action rather
    // than a fixed exec, so a command can do something other than spawn a
    // process -- Pick Wallpaper opens a second menu instead.
    readonly property var commands: [
        { icon: "🖼", label: "Pick Wallpaper", action: () => { root.mode = "wallpaperPicker"; } },
        {
            icon: ThemeMode.isDark ? "🌙" : "☀️",
            label: ThemeMode.isDark ? "Switch to Light" : "Switch to Dark",
            action: () => { root.close(); ThemeMode.toggle(); }
        }
    ]

    // Installed applications, filtered by a query and sorted by name. Matches
    // the same fields rofi's -drun-match-fields all did.
    function apps(query: string): var {
        const q = (query || "").trim().toLowerCase();
        const out = [];

        for (const entry of DesktopEntries.applications.values) {
            if (entry.noDisplay)
                continue;
            if (q !== "") {
                const hay = [entry.name, entry.genericName, entry.comment, (entry.keywords || []).join(" ")]
                    .filter(v => !!v).join(" ").toLowerCase();
                if (!hay.includes(q))
                    continue;
            }
            out.push(entry);
        }

        out.sort((a, b) => a.name.localeCompare(b.name));
        return out;
    }

    // What the overlay is currently listing.
    readonly property var entries: {
        if (root.mode === "power")
            return root.power;
        if (root.mode === "screenshot")
            return root.screenshot;
        if (root.mode === "commands")
            return root.commands;
        if (root.mode === "wallpaperPicker")
            return Wallpapers.files;
        return [];
    }

    function run(cmd: var) {
        root.close();
        Quickshell.execDetached(cmd);
    }

    // Single-quotes each argument, escaping any embedded ' -- the standard
    // "close, escape, reopen" trick, since single quotes admit no escape
    // sequences of their own.
    function shellQuote(args: var): string {
        return args.map(a => "'" + String(a).replace(/'/g, "'\\''") + "'").join(" ");
    }

    // A window-opening launch has to go through Hyprland's own exec, not
    // Quickshell.execDetached: only Hyprland's executor stamps the spawned
    // process with HL_INITIAL_WORKSPACE_TOKEN, which is what lets the
    // window land on the workspace it was launched *from* once it actually
    // maps -- which can be well after this call returns, and well after
    // whatever was the active workspace at that moment. Skip that token and
    // Hyprland falls back to "wherever's active when the window shows up",
    // which for anything slow to start is a coin flip -- most often
    // whichever workspace happens to be active by then, workspace 1 if nothing
    // else has changed it. hyprctl itself, not a script -- same as the
    // hyprctl reload calls elsewhere in this shell.
    function launch(entry: var) {
        root.close();
        // Terminal entries carry a bare command; give them one, as rofi did.
        const argv = entry.runInTerminal ? ["kitty", "-e"].concat(entry.command) : entry.command;
        const shellCmd = root.shellQuote(argv);
        const luaExpr = 'hl.dsp.exec_cmd("' + shellCmd.replace(/\\/g, "\\\\").replace(/"/g, '\\"') + '")';
        Quickshell.execDetached(["hyprctl", "dispatch", luaExpr]);
    }

    function runCommand(entry: var) {
        entry.action();
    }

    function pickWallpaper(entry: var) {
        root.close();
        Wallpapers.apply(entry.path);
    }
}
