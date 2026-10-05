import QtQuick
import QtQuick.Layouts

import "../"

Item {
    id: root

    required property var dots      // array of bool: is this dot the current one
    property bool vertical: true
    property bool halfCut: false

    // Clicking a dot jumps to whatever it stands for; the rail does not know
    // what that is, so it just reports which one was hit.
    signal activated(int index)

    readonly property int count: dots.length

    readonly property int gutter: Theme.railGutter
    readonly property int dotActive: Theme.railDotActive
    readonly property int dotIdle: Theme.railDotIdle
    readonly property int dotSpacing: Theme.railDotSpacing
    readonly property int thickness: Theme.railThickness

    readonly property int span: count * dotActive + (count - 1) * dotSpacing + 2 * gutter

    implicitWidth: vertical ? thickness : span
    implicitHeight: vertical ? span : thickness

    StyledRectangle {
        id: well
        width: root.implicitWidth
        height: root.implicitHeight
        y: root.halfCut ? -height/2 : 0
        radius: root.thickness / 2
        color: Theme.colorRail
        visible: root.count > 0

        GridLayout {
            id: grid
            rows: root.vertical ? root.count : 1
            columns: root.vertical ? 1 : root.count
            columnSpacing: root.dotSpacing
            rowSpacing: root.dotSpacing

            Repeater {
                model: root.dots
                Item {
                    id: cell

                    required property int index
                    required property var modelData
                    readonly property bool current: modelData === true
                    readonly property color dotColor: current ? Theme.colorPrimary : Theme.colorOnRail

                    width: root.dotActive
                    height: root.dotActive

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.activated(cell.index)
                    }

                    Item {
                        id: dot
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        width: cell.current ? root.dotActive : root.dotIdle
                        height: width

                        Behavior on width {
                            NumberAnimation { duration: Theme.durationMedium; easing.type: Theme.easingStandard }
                        }

                        StyledRectangle {
                            anchors.fill: parent
                            width: parent.width
                            height: width
                            radius: width / 2
                            color: cell.dotColor
                        }
                    }
                }
            }
        }
    }
}
