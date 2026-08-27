// A Rectangle usable at any height, even one shorter than its own corner
// radius would normally allow. Qt caps a per-corner radius at
// min(radius, width/2, height/2) using the rectangle's own FULL height --
// even for a corner whose opposite edge isn't rounded at all, so there's no
// actual room conflict (confirmed by rendering the two shapes in isolation
// and measuring the pixel profile). The fix: draw the shape padded out to
// whichever height safely clears that cap, anchored so the padding bleeds
// off the unrounded edge, then reveal only the requested height through a
// clip. One Rectangle handles both the flat run and the curved cap this
// way -- no separate flat piece stacked alongside it.
import QtQuick

Item {
    id: root

    property real radius: 0
    property bool roundTopLeft: false
    property bool roundTopRight: false
    property bool roundBottomLeft: false
    property bool roundBottomRight: false
    property color color: "transparent"

    readonly property bool topRounded: roundTopLeft || roundTopRight
    readonly property bool bottomRounded: roundBottomLeft || roundBottomRight

    clip: true

    Rectangle {
        id: fill

        width: root.width
        // Never shorter than 2x radius, so height/2 can never pull the cap
        // below the requested radius -- padding bleeds off whichever edge
        // has no rounded corner. Rounding both edges only happens when the
        // requested height already covers 2x radius on its own, so there's
        // never padding left to place in that case either way.
        height: Math.max(root.height, root.radius * 2)
        y: root.bottomRounded && !root.topRounded ? root.height - height : 0

        color: root.color
        topLeftRadius: root.roundTopLeft ? root.radius : 0
        topRightRadius: root.roundTopRight ? root.radius : 0
        bottomLeftRadius: root.roundBottomLeft ? root.radius : 0
        bottomRightRadius: root.roundBottomRight ? root.radius : 0
    }
}
