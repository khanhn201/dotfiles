// Corner.qml
import QtQuick
import Quickshell

Item {
    id: root
    property real radius: Theme.cornerRadius
    property color color: Theme.colorSecondary
    // "bottomLeft" | "topLeft" | "bottomRight" | "topRight"
    // refers to which screen corner this piece sits near
    property string corner: "bottomLeft"

    implicitWidth: radius
    implicitHeight: radius

    Canvas {
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            var r = root.radius
            ctx.save()

            // Reuse one base path (meeting point = bottom-left of local box,
            // far/rounded corner = top-right) and mirror it into place.
            switch (root.corner) {
            case "topLeft":
                ctx.translate(0, r); ctx.scale(1, -1)
                break
            case "bottomRight":
                ctx.translate(r, 0); ctx.scale(-1, 1)
                break
            case "topRight":
                ctx.translate(r, r); ctx.scale(-1, -1)
                break
            default: // bottomLeft
                break
            }

            ctx.fillStyle = root.color
            ctx.beginPath()
            ctx.moveTo(0, 0)
            ctx.lineTo(0, r)
            ctx.lineTo(r, r)
            ctx.arc(r, 0, r, Math.PI / 2, Math.PI, false)
            ctx.closePath()
            ctx.fill()
            ctx.restore()
        }
        Component.onCompleted: requestPaint()
        Connections {
            target: root
            function onRadiusChanged() { requestPaint() }
            function onColorChanged() { requestPaint() }
            function onCornerChanged() { requestPaint() }
        }
    }
}
