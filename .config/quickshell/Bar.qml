import Quickshell
import QtQuick
import QtQuick.Layouts

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      color: Theme.colorSecondary

      implicitWidth: Theme.barWidth

      anchors {
        top: true
        bottom: true
        left: true
      }


      ColumnLayout {
        anchors.fill: parent
        Item { Layout.fillHeight: true }
        WorkspaceWidget {
          Layout.alignment: Qt.AlignHCenter
        }
        VolumeWidget {
          Layout.alignment: Qt.AlignHCenter
        }
        BrightnessWidget {
          Layout.alignment: Qt.AlignHCenter
        }
        BatteryWidget {
          Layout.alignment: Qt.AlignHCenter
        }
        BluetoothWidget {
          Layout.alignment: Qt.AlignHCenter
        }
        NetworkWidget {
          Layout.alignment: Qt.AlignHCenter
        }
        ClockWidget {
          Layout.alignment: Qt.AlignHCenter
        }
        Item { height: 10 }
      }
    }
  }
}
