// StyledText.qml
import QtQuick
import "../"

Text {
    property string variant: "bodyLarge" // e.g. titleLarge, labelSmall, etc.

    font.family: Theme.fontFamily
    font.pixelSize: Theme["fontSize" + variant[0].toUpperCase() + variant.slice(1)]
    color: Theme.colorOnTertiary
}
