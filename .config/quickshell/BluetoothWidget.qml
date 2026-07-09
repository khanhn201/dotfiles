import QtQuick
import QtQuick.Layouts

import "./components"
import "./services"

ColumnLayout {
    StyledRectangle {
        implicitHeight: 30
        Layout.fillWidth: true
        text: Bluetooth.icon + " "
            + (Bluetooth.count == 0 ? "on" : Bluetooth.count)
    }
}
