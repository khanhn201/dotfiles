import QtQuick
import QtQuick.Layouts

import "./components"
import "./services"

ColumnLayout {
    StyledRectangle {
        implicitHeight: 40
        Layout.fillWidth: true
        text: Volume.icon + " " + Volume.percentage
    }
}
