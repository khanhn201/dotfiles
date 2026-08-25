// The media transport, sized for a narrow vertical bar: the transport glyph on
// top, the track's title and artist below it on one line, rotated a quarter
// turn so there is room to actually read them. Click toggles play/pause,
// scroll moves between tracks.
import QtQuick

import "../"
import "../services"

StyledRectangle {
    id: root

    // slot below already clips to its own bounds too -- this is the backstop
    // in case anything (a future change, a still-settling font metric on
    // first paint) ever pushes it wide again; cheap insurance against the
    // pill spilling past the bar's own edge into the wallpaper the way it
    // did before slot's sizing moved off Layout.fillWidth (see below).
    clip: true
    visible: Media.active

    // Same capsule as the workspace rail's own well and IconRail's: this
    // pill's width is already exactly Theme.railThickness -- Bar's outer
    // ColumnLayout gives every fillWidth child barWidth - 2*framePadding,
    // which is railThickness by construction -- so width/2 lands on the
    // same radius those two use.
    radius: width / 2

    // Idle/paused reads as the same rail everything else in the bar sits on
    // -- Theme.colorRail/colorOnRail, the same pairing DotRail's well and
    // IconRail use. Playing is worth a pop of colour, same as the alert
    // indicators.
    color: Media.playing ? Theme.colorPrimary : Theme.colorRail
    readonly property color ink: Media.playing ? Theme.colorOnPrimary : Theme.colorOnRail

    // Plain anchors rather than a ColumnLayout: with a rotated child inside
    // the second row, Layout.fillWidth on that row measured itself against
    // the rotated column's *unrotated*, un-elided natural text width -- e.g.
    // a long title -- rather than the space actually available, and grew
    // past the pill's own edge instead of shrinking to fit. Anchoring left
    // and right directly leaves nothing for that to measure against; slot's
    // width is just parent.width, full stop.
    Item {
        anchors.fill: parent
        // Top/bottom keep the full framePadding -- that's the generous
        // along-the-bar axis, no pressure there. Left/right is what caps how
        // tall a line of rotated text can be before it clips against slot's
        // own width, and framePadding on both sides only left 15px for it --
        // barely a labelMedium line, let alone anything bigger. A tighter,
        // pill-specific inset here (not a Theme-wide change) buys the room.
        anchors.topMargin: Theme.framePadding
        anchors.bottomMargin: Theme.framePadding
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        SvgIcon {
            id: icon
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            // Theme.railIcon -- same size as every other icon in the bar,
            // wifi/bluetooth included.
            width: Theme.railIcon
            height: Theme.railIcon
            color: root.ink
            name: Media.icon
        }

        // Rotating the text block is what buys the room: after a -90 turn the
        // block's height becomes its width on screen, so a long title runs down
        // the bar instead of being cut off after four characters.
        Item {
            id: slot

            anchors.top: icon.bottom
            anchors.topMargin: Theme.gap
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            clip: true

            // One line, not two stacked -- title and artist sharing a row
            // instead of each claiming their own slice of the pill's own
            // width is what actually buys the room for a bigger typeface:
            // two stacked lines had to split that width between them, one
            // line gets to spend all of it. The "-" is static; title and
            // artist each still scroll in their own clipped share of the
            // row independently, same as when they were stacked.
            Row {
                id: row
                anchors.centerIn: parent
                width: slot.height
                rotation: -90
                spacing: 4

                readonly property bool hasArtist: Media.artist !== ""
                // Weighted rather than even -- the title is the primary
                // read; the artist is confirmation once you already know
                // the title.
                readonly property real freeWidth: row.width - separator.width - 2 * row.spacing

                MarqueeText {
                    width: row.hasArtist ? row.freeWidth * 0.6 : row.width
                    variant: "labelLarge"
                    color: root.ink
                    text: Media.title
                }

                StyledText {
                    id: separator
                    visible: row.hasArtist
                    variant: "labelLarge"
                    color: root.ink
                    opacity: 0.5
                    text: "-"
                }

                MarqueeText {
                    width: row.freeWidth * 0.4
                    visible: row.hasArtist
                    variant: "labelLarge"
                    color: root.ink
                    opacity: 0.7
                    text: Media.artist
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: Media.toggle()
        onWheel: wheel => wheel.angleDelta.y > 0 ? Media.previous() : Media.next()
    }
}
