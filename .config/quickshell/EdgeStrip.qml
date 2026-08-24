// A thin hairline of frame colour along the bottom or right screen edge. The
// top edge used to be a third case here, but it carries real content (the
// column indicator) and its own centering rule, so it is TopBar.qml now.
//
// Reserves its real thickness like every other frame piece, so tiled windows
// leave a gap for it rather than rendering underneath.
import Quickshell
import QtQuick

PanelWindow {
    id: root

    // "bottom" | "right" -- the screen edge this strip sits on
    required property string edge

    color: "transparent"
    implicitWidth: Theme.frameThickness
    implicitHeight: Theme.frameThickness

    anchors {
        top: root.edge !== "bottom"
        bottom: root.edge !== "top"
        left: root.edge !== "right"
        right: true
    }

    exclusionMode: ExclusionMode.Normal
    exclusiveZone: Theme.frameThickness

    Rectangle {
        anchors.fill: parent
        color: Theme.colorFrame
    }
}
