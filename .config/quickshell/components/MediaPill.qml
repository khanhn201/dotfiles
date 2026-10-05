import QtQuick
import QtQuick.Layouts

import "../"
import "../services"

StyledRectangle {
    id: root

    visible: Media.active && Media.title !== ""

    width: Theme.railThickness
    radius: width / 2

    color: Media.playing ? Theme.colorPrimary : Theme.colorRail
    readonly property color ink: Media.playing ? Theme.colorOnPrimary : Theme.colorOnRail

    ColumnLayout {
        anchors.fill: parent
        SvgIcon {
            id: icon
            color: root.ink
            name: Media.icon
            Layout.preferredWidth: Theme.railIcon
            Layout.preferredHeight: Theme.railIcon
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            RowLayout {
                id: row
                width: parent.height
                height: parent.width
                transform: Rotation { angle: -90}

                x: 0
                y: parent.height

                readonly property bool hasArtist: Media.artist !== ""
                readonly property real freeWidth: width - separator.width

                MarqueeText {
                    Layout.preferredWidth: row.hasArtist ? row.freeWidth * 0.8 : width
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
                    Layout.preferredWidth: row.freeWidth * 0.2
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
