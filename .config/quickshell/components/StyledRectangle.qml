import QtQuick
import "../"

Rectangle {
    property alias text: label.text

    color: Theme.colorSecondary
    radius: Theme.radius

    StyledText {
        id: label
        opacity: 1.0
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
    }
}
