// A themed pill: rounded rectangle with a centered label, colored by an M3
// tone role from Theme.tonePairs.
import QtQuick
import "../"

Rectangle {
    id: pill

    property alias text: label.text
    property alias variant: label.variant
    // Escape hatch for a caller sized off a dedicated token (Theme.mainFontSize)
    // rather than a step on the M3 type scale -- overrides variant's own size
    // without giving up its family/colour/behaviour.
    property alias fontSize: label.font.pixelSize
    property string tone: "primary"
    property color contentColor: Theme.toneOnColor(tone)
    property real contentOpacity: 1.0
    // So a caller can size the pill from what the label actually needs
    // (content height + its own padding) instead of a guessed constant.
    readonly property alias contentWidth: label.implicitWidth
    readonly property alias contentHeight: label.implicitHeight

    color: Theme.toneColor(tone)
    radius: Theme.radius

    Behavior on color {
        ColorAnimation { duration: Theme.durationMedium; easing.type: Theme.easingStandard }
    }

    StyledText {
        id: label
        variant: "labelLarge"
        color: pill.contentColor
        opacity: pill.contentOpacity
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
    }
}
