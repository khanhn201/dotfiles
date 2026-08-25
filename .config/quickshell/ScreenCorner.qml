// A rounded cutout overlaying one screen corner, matching the bar color, so
// the framed content area gets rounded corners.
import Quickshell
import Quickshell.Hyprland
import QtQuick

import "./components"

PanelWindow {
    id: root

    // "topLeft" | "topRight" | "bottomLeft" | "bottomRight"
    required property string corner

    readonly property bool atTop: corner.startsWith("top")
    readonly property bool atLeft: corner.endsWith("Left")

    // A fullscreen window on this screen still renders Bar/TopBar/the edge
    // strips above it (layer-shell top/overlay surfaces always do), but it
    // covers their own reserved space, so they end up hidden behind it in
    // practice. This wedge would otherwise stay pinned at the seam between
    // them -- a seam that, with both pieces covered, is just an arbitrary
    // point out in the middle of visible content -- so it needs to know
    // when that's happened and fall back to the screen's real corner
    // instead, same as a rounded mask over the fullscreen content itself
    // would sit.
    readonly property var hyprMonitor: Hyprland.monitors.values.find(m => m.name === root.screen?.name)
    readonly property bool fullscreen: hyprMonitor?.activeWorkspace?.hasFullscreen ?? false

    color: "transparent"
    implicitWidth: Theme.cornerRadius
    implicitHeight: Theme.cornerRadius

    anchors {
        top: root.atTop
        bottom: !root.atTop
        left: root.atLeft
        right: !root.atLeft
    }

    // The wedge belongs at the seam between the two frame elements that meet
    // at this corner, not at the screen's bare corner -- Bar's own width on
    // the left, TopBar's/the bottom strip's height on top/bottom. That used
    // to happen for free, as a side effect of this window also being pushed
    // around by the same exclusive zones as everyone else; now that Bar,
    // TopBar and the bottom strip resolve their own geometry from fixed
    // values instead of that stacking (see their files), the corner needs
    // the matching fixed values too.
    //
    // Except while fullscreen hides both those pieces -- then the seam
    // isn't there to meet anymore, and sitting flush with the screen's own
    // corner instead is what makes the wedge read as a rounded mask over
    // the fullscreen content rather than a fragment stranded mid-screen.
    margins {
        left: root.atLeft && !root.fullscreen ? Theme.barWidth : 0
        right: !root.atLeft && !root.fullscreen ? Theme.frameThickness : 0
        top: root.atTop && !root.fullscreen ? Theme.frameThicknessTop : 0
        bottom: !root.atTop && !root.fullscreen ? Theme.frameThickness : 0
    }

    // Reserves nothing (always has -- "corners nothing" per the frame's
    // design) and, now made explicit, is not shifted by anyone else's zone
    // either: its position comes entirely from the margins above.
    exclusionMode: ExclusionMode.Ignore

    CornerWedge {
        anchors.fill: parent
        corner: root.corner
    }
}
