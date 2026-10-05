import QtQuick

import "../"

Item {
    id: root

    property alias text: label.text
    property alias variant: label.variant
    property alias color: label.color

    implicitHeight: label.implicitHeight
    clip: true

    readonly property bool overflowing: label.implicitWidth > root.width

    StyledText {
        id: label
    }

    Binding {
        target: label
        property: "x"
        value: Math.max(0, (root.width - label.implicitWidth) / 2)
        when: !root.overflowing
    }

    SequentialAnimation {
        running: root.overflowing
        loops: Animation.Infinite

        PauseAnimation { duration: 500 }
        NumberAnimation {
            target: label
            property: "x"
            from: 0
            to: root.width - label.implicitWidth
            duration: Math.max(1200, (label.implicitWidth - root.width) * 40)
            easing.type: Easing.Linear
        }
        PauseAnimation { duration: 500 }
        // Straight back to the head, not a mirrored scroll -- a jump cut
        // reads as a loop; sliding back the way it came read as a bounce.
        PropertyAction { target: label; property: "x"; value: 0 }
    }
}
