// A themed pill: rounded rectangle with a centered label, colored by an M3
// tone role from Theme.tonePairs.
import QtQuick
import "../"

Rectangle {
    property string tone: "primary"
    property color contentColor: Theme.toneOnColor(tone)
    color: Theme.toneColor(tone)
    radius: Theme.radius

    Behavior on color {
        ColorAnimation { duration: Theme.durationMedium; easing.type: Theme.easingStandard }
    }
}
