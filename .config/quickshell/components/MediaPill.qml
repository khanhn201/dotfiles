// The media transport, sized for a narrow vertical bar: the transport glyph on
// top and the track's title and artist beneath it, rotated a quarter turn so
// there is room to actually read them. Click toggles play/pause, scroll moves
// between tracks.
import QtQuick
import QtQuick.Layouts

import "../"
import "../services"

StyledRectangle {
    id: root

    visible: Media.active

    tone: Media.playing ? "primary" : "surfaceContainerHighest"
    // Idle, it is a readout, not a button -- flush with the frame, no pill of
    // its own. Playing is worth a pop of colour, same as the alert indicators.
    color: Media.playing ? Theme.toneColor(tone) : "transparent"

    readonly property color ink: Media.playing ? Theme.toneOnColor(tone) : Theme.colorOnFrame

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.framePadding
        spacing: Theme.gap

        SvgIcon {
            Layout.alignment: Qt.AlignHCenter
            width: 24
            height: 24
            color: root.ink
            name: Media.icon
        }

        // Rotating the text block is what buys the room: after a -90 turn the
        // block's height becomes its width on screen, so a long title runs down
        // the bar instead of being cut off after four characters.
        Item {
            id: slot

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            Column {
                anchors.centerIn: parent
                width: slot.height
                rotation: -90
                spacing: 2

                StyledText {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    variant: "labelMedium"
                    color: root.ink
                    text: Media.title
                }

                StyledText {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    variant: "labelSmall"
                    color: root.ink
                    opacity: 0.7
                    visible: Media.artist !== ""
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
