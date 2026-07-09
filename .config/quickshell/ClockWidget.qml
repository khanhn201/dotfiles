import QtQuick
import QtQuick.Layouts

import "./components"
import "./services"

ColumnLayout {
  StyledRectangle {
    implicitHeight: 100
    Layout.fillWidth: true
    text: Clock.day + "\n" + Clock.month + "\n" + Clock.date + "\n" + Clock.year
  }
  StyledRectangle {
    implicitHeight: 60
    Layout.fillWidth: true
    text: Clock.hour + "\n" + Clock.minute
  }
}
