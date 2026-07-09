// NetworkWidget.qml
import QtQuick
import QtQuick.Layouts

import "./components"
import "./services"

ColumnLayout {
    StyledRectangle {
        implicitHeight: 30
        Layout.fillWidth: true
        text: Brightness.icon + " " + Brightness.percentage
    }
}
