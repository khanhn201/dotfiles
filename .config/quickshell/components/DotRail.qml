// The shell's indicator style in one place: a recessed rail carrying one dot
// per item, the current one swollen and lit. Used vertically in the bar for
// workspaces, and horizontally in the top strip for scrolling columns, so the
// two read as the same instrument in two orientations.
import QtQuick

import "../"

Item {
    id: root

    // One array in, not a count plus an index. Those are two bindings, and QML
    // re-evaluates them in whatever order it likes: on a workspace switch the
    // Repeater rebuilt with the *previous* workspace's active index, so the lit
    // dot appeared on the wrong one and then animated across. As a single value
    // the count and which-one-is-lit cannot disagree.
    required property var dots      // array of bool: is this dot the current one
    property bool vertical: true
    // The top strip's rail hangs below the strip's own edge rather than
    // sitting fully enclosed in it: each dot renders as its own bottom half
    // only -- a flat top edge, a short straight run, then a true semicircle.
    //
    // This is NOT done with Rectangle's per-corner radius (topLeftRadius: 0,
    // bottomLeftRadius: width/2, etc). That looked right in theory but Qt
    // caps every corner's *effective* radius at min(radius, width/2,
    // height/2) using the rectangle's own full height -- even for a corner
    // whose opposite corner is zero, so there's no actual room conflict.
    // Once a dot's height (radius + a straight extension) dropped much below
    // its width, the requested width/2 radius silently shrank to roughly
    // height/2, and the curve stopped short of the centre instead of closing
    // into a point -- confirmed by rendering the two shapes in isolation and
    // measuring the pixel profile.
    //
    // The fix is to never ask Rectangle for a radius its own height can't
    // satisfy: draw the dot as a full circle at its natural (width == height)
    // proportions, where the cap is never hit, then reveal only its bottom
    // half through a clipped Item. A separate flat, radius-less Rectangle
    // covers the straight extension above it. Two ordinary shapes, neither
    // of which ever hits the cap, seamed together.
    property bool halfCut: false
    readonly property real extension: Theme.railHalfCutExtension

    // Clicking a dot jumps to whatever it stands for; the rail does not know
    // what that is, so it just reports which one was hit.
    signal activated(int index)

    readonly property int count: dots.length

    readonly property int gutter: Theme.railGutter
    readonly property int dotActive: Theme.railDotActive
    readonly property int dotIdle: Theme.railDotIdle
    readonly property int dotSpacing: Theme.railDotSpacing

    readonly property int thickness: dotActive + 2 * gutter
    readonly property int span: count * dotActive + (count - 1) * dotSpacing + 2 * gutter

    implicitWidth: vertical ? thickness : span
    implicitHeight: vertical ? span : (halfCut ? Math.round(thickness / 2 + extension) : thickness)

    Item {
        id: well
        anchors.centerIn: parent
        width: root.implicitWidth
        height: root.implicitHeight
        visible: root.count > 0

        // Recessed out of the surface it sits on -- a lower-tone fill is what
        // reads as a well, no rim needed. Same fix as the dot, same reason:
        // asking a thickness/2-plus-extension-tall Rectangle for corner
        // radius thickness/2 hits Qt's min(radius, width/2, height/2) cap
        // and the end caps stop short of a true quarter-circle. A stadium at
        // its natural height (radius already equal to height/2, never
        // capped) reveals a correct bottom half -- flat run, then both
        // rounded ends -- once clipped, because a stadium's corner curves
        // are exactly as tall as its own half-height to begin with, so the
        // clip line lands precisely on their widest point.
        Rectangle {
            visible: !root.halfCut
            anchors.fill: parent
            radius: root.thickness / 2
            color: Theme.colorRail
        }

        Item {
            visible: root.halfCut
            anchors.fill: parent

            Rectangle {
                width: parent.width
                height: root.extension
                color: Theme.colorRail
            }

            Item {
                anchors.top: parent.top
                anchors.topMargin: root.extension
                width: parent.width
                height: root.thickness / 2
                clip: true

                Rectangle {
                    width: parent.width
                    height: root.thickness
                    radius: root.thickness / 2
                    color: Theme.colorRail
                    anchors.bottom: parent.bottom
                }
            }
        }

        Grid {
            id: grid
            anchors.horizontalCenter: parent.horizontalCenter
            // Centred normally; top-aligned with exactly the gutter's worth
            // of clearance when half-cut, so the visible (upper) half of
            // each dot sits where the centred layout would have put its
            // upper half anyway -- half-cut is a rendering change, not a
            // repositioning of what the full rail would have looked like.
            y: root.halfCut ? 0 : (well.height - height) / 2
            rows: root.vertical ? root.count : 1
            columns: root.vertical ? 1 : root.count
            spacing: root.dotSpacing

            Repeater {
                model: root.dots

                // A fixed slot with the dot centred in it, so the rhythm holds
                // while the dot swells and shrinks inside.
                Item {
                    id: cell

                    required property int index
                    required property var modelData
                    readonly property bool current: modelData === true
                    readonly property color dotColor: current ? Theme.colorPrimary : Theme.colorOnRail

                    width: root.dotActive
                    height: root.halfCut ? Math.round(root.dotActive / 2 + root.extension) : root.dotActive

                    // The whole slot is the target, not just the dot, so an
                    // idle 8px pip is still comfortably clickable.
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.activated(cell.index)
                    }

                    Item {
                        id: dot
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: root.halfCut ? 0 : (cell.height - height) / 2
                        width: cell.current ? root.dotActive : root.dotIdle
                        height: root.halfCut ? Math.round(width / 2 + root.extension) : width

                        Behavior on width {
                            NumberAnimation { duration: Theme.durationMedium; easing.type: Theme.easingStandard }
                        }

                        // Full circle at its natural proportions -- never
                        // capped, since radius (width/2) already equals
                        // height/2 exactly.
                        Rectangle {
                            visible: !root.halfCut
                            anchors.fill: parent
                            radius: width / 2
                            color: cell.dotColor

                            Behavior on color {
                                ColorAnimation { duration: Theme.durationMedium; easing.type: Theme.easingStandard }
                            }
                        }

                        // Half-cut: a flat cap for the straight run, then the
                        // same natural, never-capped circle, revealed only
                        // from its own vertical centre down.
                        Item {
                            visible: root.halfCut
                            anchors.fill: parent

                            Rectangle {
                                width: parent.width
                                height: root.extension
                                color: cell.dotColor

                                Behavior on color {
                                    ColorAnimation { duration: Theme.durationMedium; easing.type: Theme.easingStandard }
                                }
                            }

                            Item {
                                anchors.top: parent.top
                                anchors.topMargin: root.extension
                                width: parent.width
                                height: parent.width / 2
                                clip: true

                                Rectangle {
                                    width: parent.width
                                    height: parent.width
                                    radius: width / 2
                                    color: cell.dotColor
                                    anchors.bottom: parent.bottom

                                    Behavior on color {
                                        ColorAnimation { duration: Theme.durationMedium; easing.type: Theme.easingStandard }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
