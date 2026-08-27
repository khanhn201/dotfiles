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
    // sitting fully enclosed in it: each dot (and the well itself) renders
    // as its own bottom half only -- a flat top edge, a short straight run,
    // then a true semicircle. Both use CornerRect, which exists specifically
    // because Qt's per-corner radius caps out at min(radius, width/2,
    // height/2) using the rectangle's own full height -- even for a corner
    // whose opposite corner is zero, so there's no actual room conflict --
    // and a straight `bottomLeftRadius: width/2` on a short shape silently
    // shrinks below what was asked for. See CornerRect.qml's own comment for
    // how it dodges that.
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
        // reads as a well, no rim needed. CornerRect handles the halfCut
        // case's flat-run-then-round-cap shape in one piece (see its own
        // comment for why that needs special handling at all).
        CornerRect {
            anchors.fill: parent
            radius: root.thickness / 2
            color: Theme.colorRail
            roundTopLeft: !root.halfCut
            roundTopRight: !root.halfCut
            roundBottomLeft: true
            roundBottomRight: true
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

                        CornerRect {
                            anchors.fill: parent
                            radius: width / 2
                            color: cell.dotColor
                            roundTopLeft: !root.halfCut
                            roundTopRight: !root.halfCut
                            roundBottomLeft: true
                            roundBottomRight: true

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
