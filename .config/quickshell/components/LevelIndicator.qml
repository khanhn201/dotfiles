// A vertical level gauge: an icon at the top, a filled bar below it showing
// 0-1 as a proportion of the track's own height. Shared by the volume and
// brightness OSDs -- same instrument, different service behind it.
import QtQuick

import "../"

StyledRectangle {
    id: pill

    property real level: 0
    property alias icon: glyph.name

    // Frame-coloured, not a surface tone: this is meant to read as the edge
    // strip itself pushing out a tab, not a card floating in front of it.
    color: Theme.colorFrame
    implicitWidth: 44
    implicitHeight: 160
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
    CornerWedge {
        corner: "bottomRight"
        x: pill.width - Theme.frameThickness - size
        y: -size
    }

    CornerWedge {
        corner: "topRight"
        x: pill.width - Theme.frameThickness - size
        y: pill.height
    }

    SvgIcon {
        id: glyph
        anchors.top: parent.top
        anchors.topMargin: Theme.gap * 1.5
        anchors.horizontalCenter: parent.horizontalCenter
        width: 18
        height: 18
        color: Theme.colorOnFrame
    }

    Rectangle {
        id: track
        anchors.top: glyph.bottom
        anchors.topMargin: Theme.gap
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.gap * 1.5
        anchors.horizontalCenter: parent.horizontalCenter
        width: 8
        radius: width / 2
        color: Theme.colorSurfaceContainerHighest
        clip: true

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            radius: width / 2
            height: parent.height * Math.max(0, Math.min(1, pill.level))
            color: Theme.colorPrimary

            Behavior on height {
                NumberAnimation { duration: Theme.durationShort; easing.type: Theme.easingStandard }
            }
        }
    }
}
