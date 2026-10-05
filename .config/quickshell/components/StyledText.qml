import QtQuick
import "../"

Text {
    property string variant: "bodyLarge"

    font.family: Theme.fontFamily
    font.pixelSize: Theme["fontSize" + variant[0].toUpperCase() + variant.slice(1)]
    color: Theme.colorOnSurface

    Behavior on color {
        ColorAnimation { duration: Theme.durationShort; easing.type: Theme.easingStandard }
    }
}
