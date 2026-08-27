// Reusable "rail" input-field aesthetic: a fully rounded pill (radius:
// height/2, same formula as RailListItem/DotRail's own active dot) filled
// with the rail's own well colour -- Theme.colorRail/colorOnRail, not a
// surface tone -- so a search box reads as part of the same rail instrument
// as the list it filters, rather than a separately-styled control.
import QtQuick
import "../"

Rectangle {
    id: root

    property alias text: input.text
    property string placeholder: ""
    // A vendored Icons.qml name (see SvgIcon), not a glyph character.
    property string icon: ""
    // Left-aligned suits a search box (reads naturally next to its icon);
    // a lock screen's single field reads better centred in the pill.
    property bool centerText: false
    // The actual TextInput, for a caller that needs to attach its own
    // Keys.onPressed (navigation, Escape-to-close, ...) -- behavior stays
    // with the caller; this component only owns the look.
    property alias input: input

    radius: height / 2
    color: Theme.colorRail

    SvgIcon {
        visible: root.icon !== ""
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 14
        // Same size as every other icon in the shell.
        width: Theme.railIcon
        height: Theme.railIcon
        color: Theme.colorOnRail
        name: root.icon
    }

    TextInput {
        id: input

        anchors.fill: parent
        anchors.leftMargin: root.icon !== "" ? 14 + Theme.railIcon + 8 : 14
        anchors.rightMargin: 14
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: root.centerText ? TextInput.AlignHCenter : TextInput.AlignLeft

        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeTitleMedium
        color: Theme.colorOnRail
        selectionColor: Theme.colorPrimary
        selectedTextColor: Theme.colorOnPrimary
        clip: true

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: root.centerText ? undefined : parent.left
            anchors.horizontalCenter: root.centerText ? parent.horizontalCenter : undefined
            visible: input.text === ""
            variant: "titleMedium"
            color: Theme.colorOnRail
            opacity: 0.6
            text: root.placeholder
        }
    }
}
