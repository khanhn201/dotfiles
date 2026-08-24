// The one overlay window, hosting all three menus that used to be rofi. Keeping
// them in a single window means one scrim, one keyboard grab and one card
// style, and makes it impossible for two of them to be open at once.
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

    readonly property bool isLauncher: Menus.mode === "launcher"
    readonly property bool isWallpaperPicker: Menus.mode === "wallpaperPicker"
    readonly property var items: isLauncher ? Menus.apps(search.text) : Menus.entries

    property int selected: 0

    // Follow the focused monitor, so the menu opens where you are looking.
    screen: {
        const name = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "";
        for (const s of Quickshell.screens) {
            if (s.name === name)
                return s;
        }
        return null;
    }

    // Menus.mode flipping to "" starts the close animation; the window
    // itself has to stay mapped and click-through-blocking until the sheet
    // has actually finished sliding down, or it would just vanish mid-slide.
    readonly property bool wantOpen: Menus.mode !== ""
    visible: wantOpen || hideLinger.running
    color: "transparent"

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Timer {
        id: hideLinger
        interval: Theme.durationLong
    }

    // Reset every time a menu opens, and put the caret back in the search box.
    onWantOpenChanged: {
        if (wantOpen) {
            root.selected = 0;
            search.text = "";
            search.forceActiveFocus();
        } else {
            hideLinger.restart();
        }
    }

    function move(delta: int) {
        if (root.items.length === 0)
            return;
        root.selected = (root.selected + delta + root.items.length) % root.items.length;
    }

    function activate() {
        if (root.selected < 0 || root.selected >= root.items.length)
            return;
        const item = root.items[root.selected];
        if (root.isLauncher)
            Menus.launch(item);
        else if (Menus.mode === "commands")
            Menus.runCommand(item);
        else if (Menus.mode === "wallpaperPicker")
            Menus.pickWallpaper(item);
        else
            Menus.run(item.exec);
    }

    // Click anywhere outside the card to dismiss.
    MouseArea {
        anchors.fill: parent
        onClicked: Menus.close()
    }

    // No scrim: the sheet reads as the frame itself growing a tab, not a
    // modal blocking the desktop, so there's nothing behind it to dim.

    StyledRectangle {
        id: card

        // Centred, not spanning the full content width -- a dialog-sized
        // sheet, just one that lives on the bottom edge instead of the
        // middle of the screen.
        anchors.horizontalCenter: parent.horizontalCenter
        width: 520
        // A fixed height, not one reactive to the current menu's content:
        // letting layout.implicitHeight (which jumps around as the model,
        // and therefore contentHeight, changes) drive height meant every
        // height change also nudged this y binding, and Behavior on y
        // animated those nudges too -- so on top of the real open/close
        // slide, a mode with a different item count could add a second,
        // unrelated slide partway through. Pinning height stops that
        // second motion from ever existing; the list scrolls internally
        // instead.
        height: 460
        // Off the bottom edge when closed, flush with it when open -- a
        // sheet pulled up from the edge it lives on, not a dialog floating
        // in the middle of the screen.
        y: root.wantOpen ? parent.height - height : parent.height

        Behavior on y {
            NumberAnimation { duration: Theme.durationLong; easing.type: Theme.easingStandard }
        }

        // Frame-coloured, not a surface tone -- continuous with the bottom
        // edge strip and the two corner wedges it grows up between.
        color: Theme.colorFrame
        // Rounded where the sheet meets open screen (its own top corners,
        // same radius the corner wedges already use), square where it meets
        // the edge strips it's flush against.
        radius: Theme.cornerRadius
        bottomLeftRadius: 0
        bottomRightRadius: 0

        // Swallow clicks so they do not reach the dismiss area behind.
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: layout
            anchors.fill: parent
            anchors.margins: Theme.gap * 4
            spacing: Theme.gap * 2

            // Search, launcher only. It keeps the key focus in every mode so
            // navigation is handled in one place; the other two menus simply
            // have nothing to filter.
            StyledRectangle {
                Layout.fillWidth: true
                implicitHeight: 44
                visible: root.isLauncher
                // One step down from surfaceContainerHighest, not that tone
                // itself -- the card's own background is colorFrame now,
                // which *is* surfaceContainerHighest, so matching it here
                // would make the search box invisible against it.
                tone: "surfaceContainerHigh"
                radius: Theme.radiusMedium

                StyledText {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    variant: "titleMedium"
                    color: Theme.colorOnSurfaceVariant
                    text: "󰍉"
                }

                TextInput {
                    id: search

                    anchors.fill: parent
                    anchors.leftMargin: 42
                    anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter

                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeTitleMedium
                    color: Theme.colorOnSurface
                    selectionColor: Theme.colorPrimary
                    selectedTextColor: Theme.colorOnPrimary
                    clip: true
                    focus: true

                    onTextChanged: root.selected = 0

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            Menus.back();
                        } else if (event.key === Qt.Key_Up) {
                            root.move(-1);
                        } else if (event.key === Qt.Key_Down) {
                            root.move(1);
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.activate();
                        } else if (event.key === Qt.Key_Tab) {
                            root.move(event.modifiers & Qt.ShiftModifier ? -1 : 1);
                        } else {
                            return;
                        }
                        event.accepted = true;
                    }

                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: search.text === ""
                        variant: "titleMedium"
                        color: Theme.colorOnSurfaceVariant
                        opacity: 0.6
                        text: "Search applications"
                    }
                }
            }

            ListView {
                id: list

                Layout.fillWidth: true
                Layout.fillHeight: true
                implicitHeight: contentHeight

                clip: true
                model: root.items
                currentIndex: root.selected
                highlightMoveDuration: Theme.durationShort
                boundsBehavior: Flickable.StopAtBounds

                // Keep the selection in view when arrowing past the fold.
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                delegate: Rectangle {
                    id: row

                    required property int index
                    required property var modelData
                    readonly property bool current: index === root.selected

                    width: list.width
                    height: root.isWallpaperPicker ? 64 : 44
                    radius: Theme.radiusMedium
                    color: current ? Theme.colorPrimary : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: Theme.durationShort; easing.type: Theme.easingStandard }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: root.selected = row.index
                        onClicked: root.activate()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 14

                        // Launcher entries carry a themed icon name; power
                        // and screenshot entries carry a glyph; wallpaper
                        // entries carry an actual thumbnail read off disk.
                        Item {
                            Layout.preferredWidth: root.isWallpaperPicker ? 76 : 24
                            Layout.preferredHeight: root.isWallpaperPicker ? 44 : 24

                            Image {
                                id: appIcon
                                anchors.fill: parent
                                fillMode: Image.PreserveAspectCrop
                                sourceSize.width: root.isWallpaperPicker ? 152 : 24
                                sourceSize.height: root.isWallpaperPicker ? 88 : 24
                                visible: status === Image.Ready
                                source: {
                                    if (root.isWallpaperPicker)
                                        return "file://" + row.modelData.path;
                                    if (root.isLauncher && row.modelData.icon)
                                        // The two-argument form returns "" when the
                                        // icon is not in the theme; the one-argument
                                        // form hands back a URL that resolves to
                                        // nothing and renders as a broken-image
                                        // checkerboard.
                                        return Quickshell.iconPath(row.modelData.icon, true);
                                    return "";
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                visible: root.isWallpaperPicker
                                radius: Theme.radiusSmall
                                color: "transparent"
                                border.width: 1
                                border.color: row.current ? Theme.colorOnPrimary : Theme.colorOutlineVariant
                            }

                            // Whatever the row needs when there is no image: the
                            // menu entry's glyph, or a generic one for an app
                            // with no themed icon.
                            StyledText {
                                anchors.centerIn: parent
                                visible: !appIcon.visible && !root.isWallpaperPicker
                                variant: "titleMedium"
                                color: row.current ? Theme.colorOnPrimary : Theme.colorOnSurface
                                text: root.isLauncher ? "󰣆" : row.modelData.icon
                            }
                        }

                        StyledText {
                            Layout.fillWidth: true
                            variant: "titleMedium"
                            elide: Text.ElideRight
                            color: row.current ? Theme.colorOnPrimary : Theme.colorOnSurface
                            text: root.isLauncher ? row.modelData.name : row.modelData.label
                        }
                    }
                }
            }

            StyledText {
                Layout.fillWidth: true
                visible: root.items.length === 0
                horizontalAlignment: Text.AlignHCenter
                variant: "bodyMedium"
                color: Theme.colorOnSurfaceVariant
                text: root.isWallpaperPicker ? "No wallpapers in ~/.config/hypr/wallpapers" : "No matches"
            }
        }
    }

    // Rounds the seam where the sheet's straight left/right edges cross the
    // bottom edge strip's top edge, mid-strip -- same trick as ScreenCorner's
    // own four wedges, just at the two points where this sheet happens to
    // interrupt the strip instead of at a true screen corner. Siblings of
    // card, not children of it, so their x/y stay in root's own coordinate
    // space instead of getting dragged along by card's animated y. Bound to
    // card.y directly rather than wantOpen, so they appear and disappear
    // exactly when the sheet actually crosses the strip's line, not a beat
    // early or late relative to the slide.
    CornerWedge {
        corner: "bottomRight"
        x: card.x - size
        y: root.height - Theme.frameThickness - size
        visible: card.y < root.height - Theme.frameThickness
    }

    CornerWedge {
        corner: "bottomLeft"
        x: card.x + card.width
        y: root.height - Theme.frameThickness - size
        visible: card.y < root.height - Theme.frameThickness
    }

    // Hyprland triggers these by name (`hl.dsp.global("quickshell:launcher")`),
    // so no process is spawned to open a menu.
    GlobalShortcut { appid: "quickshell"; name: "launcher";   onPressed: Menus.toggle("launcher") }
    GlobalShortcut { appid: "quickshell"; name: "power";      onPressed: Menus.toggle("power") }
    GlobalShortcut { appid: "quickshell"; name: "screenshot"; onPressed: Menus.toggle("screenshot") }
    GlobalShortcut { appid: "quickshell"; name: "commands";   onPressed: Menus.toggle("commands") }
}
