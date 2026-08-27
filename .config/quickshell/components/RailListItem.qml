// Reusable "rail" list-row aesthetic: a fully rounded pill (radius:
// height/2, the same formula the rail's own active dot uses in DotRail.qml
// -- never asking Rectangle for a radius its height can't satisfy, since
// width is always the larger dimension here, so the cap never bites) that
// fills solid with Theme.colorPrimary when current and sits transparent
// otherwise. Shared by every menu list -- launcher, power, screenshot,
// wallpaper picker, the screen/window picker -- so they read as one
// instrument instead of each row style being invented per menu.
//
// Purely the shape and the hover/click plumbing; content (icon, label,
// thumbnail...) is supplied by the caller as children, which land inside an
// Item already inset by the standard row margin.
import QtQuick
import "../"

Rectangle {
    id: root

    property bool current: false
    // Shown instead of "transparent" when not current -- tabs and similar
    // rail-toggle pills want their own rest colour (Theme.colorRail) rather
    // than disappearing against the card behind them; plain list rows leave
    // this at the default.
    property color idleColor: "transparent"
    default property alias content: inner.data

    signal hovered()
    signal activated()

    radius: height / 2
    color: current ? Theme.colorPrimary : idleColor

    Behavior on color {
        ColorAnimation { duration: Theme.durationShort; easing.type: Theme.easingStandard }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered()
        onClicked: root.activated()
    }

    Item {
        id: inner
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
    }
}
