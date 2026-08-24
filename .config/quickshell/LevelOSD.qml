// Volume and brightness as a transient HUD instead of a permanent row in the
// bar: a tab pushes out from the middle of the right edge -- flush against
// it, frame-coloured, reading as the edge strip itself growing rather than a
// card floating in front of it -- shows the new level, and slides back in on
// its own. Neither one steals keyboard focus; changing volume shouldn't
// interrupt whatever you were doing with it. Centred on the edge, not at the
// top, because top-right is the notification corner.
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick

import "./components"
import "./services"

PanelWindow {
    id: root

    screen: {
        const name = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "";
        for (const s of Quickshell.screens) {
            if (s.name === name)
                return s;
        }
        return null;
    }

    property bool volumeShown: false
    property bool brightnessShown: false
    readonly property bool anyShown: volumeShown || brightnessShown

    // Stay mapped through the slide-out: the moment both flags drop, x
    // starts animating back off-edge, but visible would otherwise flip to
    // false on the same tick and unmap the surface mid-slide instead of
    // after it.
    visible: anyShown || hideLinger.running
    color: "transparent"

    onAnyShownChanged: if (!anyShown) hideLinger.restart()

    Timer { id: hideLinger; interval: Theme.durationMedium }

    // Full height, not just right -- Hyprland's layer-shell doesn't reliably
    // auto-centre an axis left with no anchor at all, so the window spans
    // the whole edge and the two pills are centred inside it by hand
    // instead.
    anchors { top: true; bottom: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Flush with the true screen edge, not clear of it -- the whole point
    // is to look continuous with the right edge strip sitting there, not to
    // float just past it with a gap showing between them.
    margins.right: 0

    implicitWidth: volumePill.width

    readonly property real stackHeight: volumePill.height + Theme.gap + brightnessPill.height

    Timer {
        id: volumeHide
        interval: 1600
        onTriggered: root.volumeShown = false
    }

    Timer {
        id: brightnessHide
        interval: 1600
        onTriggered: root.brightnessShown = false
    }

    // Every change re-triggers the same pulse, so holding a volume/backlight
    // key down keeps the pill on screen instead of it flickering in and out
    // between individual steps.
    Connections {
        target: Volume
        function onPercentageChanged() { root.volumeShown = true; volumeHide.restart(); }
        function onMutedChanged() { root.volumeShown = true; volumeHide.restart(); }
    }

    Connections {
        target: Brightness
        function onPercentageChanged() { root.brightnessShown = true; brightnessHide.restart(); }
    }

    LevelIndicator {
        id: volumePill
        y: (parent.height - root.stackHeight) / 2
        // Off past the window's own edge when hidden, in place when shown --
        // the window itself is already clear of the screen's right edge via
        // margins.right, so sliding out just means leaving this pill's own
        // footprint.
        x: root.volumeShown ? 0 : width + Theme.gap
        level: Volume.muted ? 0 : Volume.percentage / 100
        icon: Volume.icon

        Behavior on x {
            NumberAnimation { duration: Theme.durationMedium; easing.type: Theme.easingStandard }
        }
    }

    LevelIndicator {
        id: brightnessPill
        anchors.top: volumePill.bottom
        anchors.topMargin: Theme.gap
        x: root.brightnessShown ? 0 : width + Theme.gap
        level: Brightness.percentage / 100
        icon: Brightness.icon

        Behavior on x {
            NumberAnimation { duration: Theme.durationMedium; easing.type: Theme.easingStandard }
        }
    }
}
