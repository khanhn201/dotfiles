// Time.qml
pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: root
  readonly property string day: {
    Qt.formatDateTime(clock.date, "ddd")
  }
  readonly property string month: {
    Qt.formatDateTime(clock.date, "MMM")
  }
  readonly property string date: {
    Qt.formatDateTime(clock.date, "dd")
  }
  readonly property string year: {
    Qt.formatDateTime(clock.date, "yyyy")
  }
  readonly property string hour: {
    Qt.formatDateTime(clock.date, "HH")
  }
  readonly property string minute: {
    Qt.formatDateTime(clock.date, "mm")
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}
