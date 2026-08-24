// A small concave wedge: fills its own box except for a quarter-circle cut
// in one corner, so two perpendicular frame-coloured pieces that meet at a
// point round that meeting into the open content between them instead of
// leaving a hard right-angle notch. Shared by ScreenCorner (the screen's
// own four corners) and any sliding panel that meets a fixed edge strip.
import QtQuick
import QtQuick.Shapes
import "../"

Shape {
    id: root

    // "topLeft" | "topRight" | "bottomLeft" | "bottomRight" -- which corner
    // of this wedge's own box touches the seam point; the fill sits there,
    // and the concave cutout opens into the opposite corner.
    required property string corner
    readonly property bool atTop: corner.startsWith("top")
    readonly property bool atLeft: corner.endsWith("Left")

    property real size: Theme.cornerRadius
    property color fillColor: Theme.colorFrame

    width: size
    height: size
    preferredRendererType: Shape.CurveRenderer

    // Base path below is the bottomLeft wedge; mirror it into the other
    // three via scale rather than duplicating the path per corner.
    transform: Scale {
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: root.atLeft ? 1 : -1
        yScale: root.atTop ? -1 : 1
    }

    ShapePath {
        strokeWidth: -1
        fillColor: root.fillColor
        startX: 0; startY: 0
        PathLine { x: 0; y: root.size }
        PathLine { x: root.size; y: root.size }
        PathArc  { x: 0; y: 0; radiusX: root.size; radiusY: root.size }
    }
}
