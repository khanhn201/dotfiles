// A vertical level gauge: an icon and a filled bar sharing one rail, the
// same rounded well DotRail and IconRail use. Shared by the volume and
// brightness OSDs -- same instrument, different service behind it.
import QtQuick

import "../"

StyledRectangle {
    id: pill

    property real level: 0
    property alias icon: glyph.name
    // Set by the OSD window from its own fullscreen check -- see LevelOSD.
    property bool fullscreen: false

    // Frame-coloured, not a surface tone: this is meant to read as the edge
    // strip itself pushing out a tab, not a card floating in front of it.
    color: Theme.colorFrame
    // Theme.barWidth, not a literal -- this pill holds one rail the same
    // way Bar holds its own, so it earns the same width: railThickness plus
    // a framePadding gutter on each side.
    implicitWidth: Theme.barWidth
    implicitHeight: 260
    // A plain Rectangle doesn't bind its own width/height to implicit* the
    // way a Layout-managed child does -- this is used as a bare child of a
    // PanelWindow, not inside a Layout, so it has to be told directly.
    width: implicitWidth
    height: implicitHeight
    // Rounded on the side facing into the screen, sharp on the side flush
    // against the true screen edge -- the same "frame corners are rounded
    // where they meet content, square where they meet the edge" logic
    // ScreenCorner already uses, just for a tab instead of a wedge.
    radius: Theme.cornerRadius
    topRightRadius: 0
    bottomRightRadius: 0

    // Rounds the seam where this pill's flush right edge meets the right
    // EdgeStrip running past it above and below -- same concave-wedge trick
    // ScreenCorner uses at the screen's own corners, just at the two points
    // where a pill happens to interrupt the strip instead of at a true
    // screen corner. Anchored to the pill's own top/bottom so they slide
    // out of view together with it.
    //
    // Normally inset by frameThickness to share the strip's own last few
    // pixels with it -- but a fullscreen window hides the strip behind
    // itself while still reserving its space, so with nothing there to
    // share, that inset just leaves a gap between the wedge and the true
    // edge. Flush instead, same as ScreenCorner falls back to.
    CornerWedge {
        corner: "bottomRight"
        x: pill.width - (pill.fullscreen ? 0 : Theme.frameThickness) - size
        y: -size
    }

    CornerWedge {
        corner: "topRight"
        x: pill.width - (pill.fullscreen ? 0 : Theme.frameThickness) - size
        y: pill.height
    }

    // The rail itself: same width, rounding and colour as DotRail's own well
    // and IconRail's.
    Rectangle {
        id: well
        anchors.top: parent.top
        anchors.topMargin: Theme.framePadding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.framePadding
        anchors.horizontalCenter: parent.horizontalCenter
        width: Theme.railThickness
        radius: width / 2
        color: Theme.colorRail
        clip: true

        // One fill, not a separate dot riding above a separate trail: rises
        // from well's true bottom edge with the level, rounded at both ends.
        // Never shorter than well's own width, so at 0% it still reads as
        // a single rounded dot sitting at the bottom (the icon's home),
        // rather than shrinking away to nothing -- 100% has it flush with
        // the top, filling the rail.
        property real fillHeight: width + (well.height-width) * Math.max(0, Math.min(1, pill.level))

        Behavior on fillHeight {
            NumberAnimation { duration: Theme.durationShort; easing.type: Theme.easingStandard }
        }

        // A *full* rounded cap only ever needs the bottom (or top) half of
        // a circle this size -- capReveal tall, not the full diameter.
        readonly property real capReveal: width / 2
        readonly property real bottomCapHeight: Math.min(fillHeight, capReveal)
        readonly property real afterBottomCap: Math.max(0, fillHeight - capReveal)
        readonly property real topCapHeight: Math.min(afterBottomCap, capReveal)
        readonly property real flatHeight: Math.max(0, afterBottomCap - capReveal)

        // Built from two natural, always-square circles (DotRail's own fix
        // for this exact problem -- see its half-cut dot) rather than
        // asking a plain Rectangle for radius: width/2 directly. Qt caps a
        // Rectangle's own radius at min(radius, width/2, height/2), so the
        // instant either cap got shorter than it is wide, the requested
        // curve would silently shrink to height/2 -- far shallower than
        // well's own curve, which is never capped since well's height
        // always dwarfs its width. A circle sized width == height is never
        // capped no matter how little of it ends up revealed, so its curve
        // always matches well's exactly.
        Item {
            visible: well.bottomCapHeight > 0
            anchors.bottom: parent.bottom
            width: well.width
            height: well.bottomCapHeight
            clip: true

            Rectangle {
                anchors.bottom: parent.bottom
                width: well.width
                height: well.width
                radius: width / 2
                color: Theme.colorPrimary
            }
        }

        Rectangle {
            visible: well.flatHeight > 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: well.bottomCapHeight
            width: well.width
            height: well.flatHeight
            color: Theme.colorPrimary
        }

        Item {
            visible: well.topCapHeight > 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: well.bottomCapHeight + well.flatHeight
            width: well.width
            height: well.topCapHeight
            clip: true

            Rectangle {
                anchors.top: parent.top
                width: well.width
                height: well.width
                radius: width / 2
                color: Theme.colorPrimary
            }
        }

        // Rides the fill's own leading edge -- centred in the top
        // well.width-tall stretch of it, the same "dot" the fill always has
        // at least that much room for, whatever the level. A plain y
        // binding, not anchors -- it reads off fillHeight, which already
        // animates on its own Behavior, so this glides along with the fill
        // for free without needing a Behavior of its own.
        SvgIcon {
            id: glyph
            y: (well.height - well.fillHeight) + well.width / 2 - height / 2
            anchors.horizontalCenter: parent.horizontalCenter
            width: Theme.railIcon
            height: Theme.railIcon
            // On the fill's own primary colour now, not the rail's --
            // colorOnPrimary, the pairing every other primary-toned
            // surface in the shell uses.
            color: Theme.colorOnPrimary
        }
    }
}
