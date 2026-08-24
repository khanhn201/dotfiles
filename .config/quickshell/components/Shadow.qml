import QtQuick.Effects
import "../"

MultiEffect {
    property real padLeft: 0
    property real padTop: 0
    property real padRight: 0
    property real padBottom: 0

    anchors.fill: source
    // Quickshell's PanelWindow doesn't compute autoPaddingEnabled correctly,
    // so the padding for the shadow to render into must be given explicitly.
    autoPaddingEnabled: false
    paddingRect: Qt.rect(-padLeft, -padTop,
        source.width + padLeft + padRight,
        source.height + padTop + padBottom)
    shadowEnabled: true
    shadowColor: Theme.colorShadow
    shadowBlur: Theme.shadowBlur
    shadowOpacity: Theme.shadowOpacity
}
