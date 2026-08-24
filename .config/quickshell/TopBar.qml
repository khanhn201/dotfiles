// The horizontal frame element across the top of the screen: the accent
// colour band, and the scrolling layout's column indicator riding it. Its own
// class, not a case inside EdgeStrip, since it carries content.
//
// Reserves its real height along the top edge (exclusionMode: Normal), same as
// every other frame piece -- real windows have to avoid it, or they render
// underneath it, which is worse than any cosmetic misalignment. That means
// this window is not full-width: it starts after Bar's left reservation and
// stops before the right strip's, same as it always has.
//
// The dot rail still centres on the TRUE screen width, not on this narrower,
// offset window -- computed explicitly (screen width minus Bar's width and the
// right strip's, halved, then shifted back into this window's own local
// coordinates) rather than by making the window itself span the full screen,
// which is what broke the reservation in the first place.
import Quickshell
import QtQuick

import "./components"
import "./services"

PanelWindow {
    id: root
    implicitHeight: Theme.frameThicknessTop

    anchors { top: true; left: true; right: true }

    Rectangle {
        id: fill
        anchors.fill: parent
        color: Theme.colorFrame

        DotRail {
            id: rail
            vertical: false
            halfCut: true
            dots: Workspaces.columnDotsFor(root.screen)
            onActivated: index => Workspaces.focusColumn(root.screen, index)

            // fill.width is this window's own (offset, narrower) width; the
            // true screen width is barWidth + fill.width + the right strip's
            // reservation. Centring on the true width and then subtracting
            // Bar's reservation converts that back into this window's local
            // x, where 0 already means "just past Bar".
            readonly property real trueWidth: Theme.barWidth + fill.width + Theme.frameThickness
            x: (trueWidth - width) / 2 - Theme.barWidth
            // halfCut already draws only the top-flat, bottom-round half --
            // its own implicitHeight is that half's height -- so flush
            // against the strip's own top edge is the whole rail, not a
            // window-boundary trick doing the cutting.
            anchors.top: parent.top
        }
    }
}
