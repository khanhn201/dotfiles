// A rounded cutout overlaying one screen corner, matching the bar color, so
// the framed content area gets rounded corners.
import Quickshell
import QtQuick

import "./components"

PanelWindow {
    id: root

    // "topLeft" | "topRight" | "bottomLeft" | "bottomRight"
    required property string corner

    readonly property bool atTop: corner.startsWith("top")
    readonly property bool atLeft: corner.endsWith("Left")

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
    margins {
        left: root.atLeft ? Theme.barWidth : 0
        right: root.atLeft ? 0 : Theme.frameThickness
        top: root.atTop ? Theme.frameThicknessTop : 0
        bottom: root.atTop ? 0 : Theme.frameThickness
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
