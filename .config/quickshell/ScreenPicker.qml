// The picker xdg-desktop-portal-hyprland's screencopy portal shows when
// something asks to share a screen or window -- wired in as its
// `custom_picker_binary` (see ~/.config/hypr/xdph.conf and
// ~/code/quickshell-portals/screen-picker). That binary blocks on a fifo
// until this writes an answer to it, so this is the one thing standing
// between the request and either a screencast starting or it being
// cancelled -- same bottom-sheet family as Overlay.qml/AuthPrompt.qml, with
// the same list-navigation feel as the launcher.
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import "./components"
import "./services"

PanelWindow {
    id: root

    property var outputs: []
    property var windows: []
    property string fifoPath: ""
    property int selected: 0
    // xdph itself never forwards which source types the caller actually
    // asked for (Screencopy.cpp logs "unused option types" and drops it,
    // even for the stock hyprland-share-picker) -- there's no way to
    // default to only the relevant tab, so this just remembers the last
    // one the user was on.
    property int activeTab: 0

    readonly property var screenEntries: root.outputs.map(o =>
        ({ kind: "screen", label: o.name, sublabel: o.description, value: o.name }))
    readonly property var windowEntries: root.windows.map(w =>
        ({ kind: "window", label: w.window_title || w.window_class, sublabel: w.window_class, value: w.handle }))
    readonly property var entries: root.activeTab === 0 ? root.screenEntries : root.windowEntries

    function switchTab(tab: int) {
        root.activeTab = tab;
        root.selected = 0;
    }

    readonly property bool wantOpen: fifoPath !== ""
    readonly property bool fullscreen: Hyprland.focusedMonitor?.activeWorkspace?.hasFullscreen ?? false

    IpcHandler {
        target: "screenpicker"

        function open(requestPath: string): void {
            requestReader.path = requestPath;
            requestReader.reload();
        }
    }

    // IpcHandler functions run before the event loop has necessarily
    // settled anything else -- reading the request through a FileView
    // (already the established pattern for reading JSON in this shell,
    // e.g. Wallpapers.qml's theme-state.json) rather than a hypothetical
    // synchronous read keeps this on the same footing as everything else
    // that loads JSON here.
    FileView {
        id: requestReader
        blockLoading: true
        onLoaded: {
            const data = JSON.parse(text());
            root.outputs = data.outputs || [];
            root.windows = data.windows || [];
            root.activeTab = root.outputs.length > 0 ? 0 : 1;
            root.selected = 0;
            // Request path sits next to its paired fifo, same basename,
            // .json swapped for .fifo -- portals-common creates them as a
            // pair (write_request), so deriving one from the other here
            // avoids needing a second IPC round trip just to learn it.
            root.fifoPath = requestReader.path.replace(/\.json$/, ".fifo");
        }
    }

    function respond(text: string) {
        const fifo = root.fifoPath;
        root.fifoPath = "";
        root.outputs = [];
        root.windows = [];
        if (fifo === "")
            return;
        // Fire-and-forget write+close -- the picker binary is blocked
        // reading this exact fifo already (portals_common::await_response),
        // so as soon as this closes its end, that read unblocks.
        responder.command = ["sh", "-c", "printf %s \"$1\" > \"$2\"", "sh", text, fifo];
        responder.running = true;
    }

    Process { id: responder }

    function pick(entry: var) {
        if (!entry)
            return;
        if (entry.kind === "screen")
            root.respond("[SELECTION]/screen:" + entry.value);
        else
            root.respond("[SELECTION]/window:" + entry.value);
    }

    function cancel() {
        // No "[SELECTION]" substring at all reads as a failed/cancelled
        // pick to xdph (ScreencopyShared.cpp) -- an empty response does
        // that cleanly.
        root.respond("");
    }

    visible: wantOpen || hideLinger.running
    color: "transparent"

    onWantOpenChanged: if (!wantOpen) hideLinger.restart()

    Timer { id: hideLinger; interval: Theme.durationLong }

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    MouseArea {
        anchors.fill: parent
        onClicked: root.cancel()
    }

    StyledRectangle {
        id: card

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: 560
        height: 480

        transform: Translate {
            y: root.wantOpen ? 0 : card.height

            Behavior on y {
                NumberAnimation { duration: Theme.durationLong; easing.type: Theme.easingStandard }
            }
        }

        color: Theme.colorFrame
        radius: Theme.cornerRadius
        bottomLeftRadius: 0
        bottomRightRadius: 0

        MouseArea { anchors.fill: parent }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                root.cancel();
            } else if (event.key === Qt.Key_Up) {
                root.selected = Math.max(0, root.selected - 1);
            } else if (event.key === Qt.Key_Down) {
                root.selected = Math.min(root.entries.length - 1, root.selected + 1);
            } else if (event.key === Qt.Key_Left) {
                root.switchTab(0);
            } else if (event.key === Qt.Key_Right) {
                root.switchTab(1);
            } else if (event.key === Qt.Key_Tab) {
                root.switchTab(root.activeTab === 0 ? 1 : 0);
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.pick(root.entries[root.selected]);
            } else {
                return;
            }
            event.accepted = true;
        }

        focus: root.wantOpen
        Keys.forwardTo: []

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.framePadding
            spacing: Theme.gap * 2

            StyledText {
                Layout.fillWidth: true
                variant: "titleMedium"
                color: Theme.colorOnFrame
                text: "Share your screen"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.gap

                Repeater {
                    model: [
                        { label: "Screens", count: root.screenEntries.length },
                        { label: "Windows", count: root.windowEntries.length }
                    ]

                    delegate: RailListItem {
                        id: tab

                        required property int index
                        required property var modelData
                        current: index === root.activeTab
                        idleColor: Theme.colorRail

                        Layout.fillWidth: true
                        implicitHeight: 36

                        onActivated: root.switchTab(tab.index)

                        StyledText {
                            anchors.centerIn: parent
                            variant: "labelLarge"
                            color: tab.current ? Theme.colorOnPrimary : Theme.colorOnRail
                            text: tab.modelData.label + " (" + tab.modelData.count + ")"
                        }
                    }
                }
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: root.entries
                currentIndex: root.selected
                highlightMoveDuration: Theme.durationShort
                boundsBehavior: Flickable.StopAtBounds

                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                delegate: RailListItem {
                    id: row

                    required property int index
                    required property var modelData
                    current: index === root.selected

                    width: ListView.view.width
                    height: modelData.kind === "screen" ? 68 : 52

                    onHovered: root.selected = row.index
                    onActivated: root.pick(row.modelData)

                    RowLayout {
                        anchors.fill: parent
                        spacing: 14

                        // Live thumbnail, screens only -- windows have no
                        // shared handle between xdph's candidate list and
                        // Quickshell's own toplevel manager to match against
                        // reliably (see ScreenPicker.qml history), so this
                        // stays text-only there rather than risk a preview
                        // that's actually a different window.
                        Item {
                            Layout.preferredWidth: row.modelData.kind === "screen" ? 96 : 0
                            Layout.preferredHeight: 54
                            Layout.alignment: Qt.AlignVCenter
                            visible: row.modelData.kind === "screen"
                            clip: true

                            Rectangle {
                                anchors.fill: parent
                                radius: Theme.radiusMedium * 0.6
                                color: "black"
                            }

                            ScreencopyView {
                                anchors.fill: parent
                                paintCursor: false
                                // Only capturing while this tile could
                                // actually be seen -- tab hidden or the
                                // whole picker closed both stop the stream
                                // rather than leaving it running unwatched.
                                live: root.wantOpen && root.activeTab === 0
                                captureSource: {
                                    for (const s of Quickshell.screens)
                                        if (s.name === row.modelData.value)
                                            return s;
                                    return null;
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            StyledText {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                variant: "titleMedium"
                                color: row.current ? Theme.colorOnPrimary : Theme.colorOnSurface
                                text: row.modelData.label
                            }

                            StyledText {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                variant: "labelSmall"
                                opacity: 0.7
                                color: row.current ? Theme.colorOnPrimary : Theme.colorOnSurface
                                text: row.modelData.sublabel
                            }
                        }
                    }
                }
            }

            StyledText {
                Layout.fillWidth: true
                visible: root.entries.length === 0
                horizontalAlignment: Text.AlignHCenter
                variant: "bodyMedium"
                color: Theme.colorOnSurfaceVariant
                text: root.activeTab === 0 ? "No screens available" : "No windows available"
            }
        }
    }

    Item {
        x: card.x - Theme.cornerRadius
        width: Theme.cornerRadius
        height: Theme.cornerRadius
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.fullscreen ? 0 : Theme.frameThickness

        transform: Translate {
            y: root.wantOpen ? 0 : Theme.cornerRadius

            Behavior on y {
                NumberAnimation { duration: Theme.durationLong; easing.type: Theme.easingStandard }
            }
        }

        CornerWedge { anchors.fill: parent; corner: "bottomRight" }
    }

    Item {
        x: card.x + card.width
        width: Theme.cornerRadius
        height: Theme.cornerRadius
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.fullscreen ? 0 : Theme.frameThickness

        transform: Translate {
            y: root.wantOpen ? 0 : Theme.cornerRadius

            Behavior on y {
                NumberAnimation { duration: Theme.durationLong; easing.type: Theme.easingStandard }
            }
        }

        CornerWedge { anchors.fill: parent; corner: "bottomLeft" }
    }
}
