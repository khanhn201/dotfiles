// Corners.qml
import Quickshell
import QtQuick

Scope {
  Variants {
    model: Quickshell.screens
    PanelWindow {
      required property var modelData
      screen: modelData
      color: "transparent"
      implicitWidth: Theme.cornerRadius
      implicitHeight: Theme.cornerRadius
      anchors { left: true; bottom: true }
      Corner { anchors.fill: parent; radius: Theme.cornerRadius; color: Theme.colorSecondary; corner: "bottomLeft" }
    }
  }
  Variants {
    model: Quickshell.screens
    PanelWindow {
      required property var modelData
      screen: modelData
      color: "transparent"
      implicitWidth: Theme.cornerRadius
      implicitHeight: Theme.cornerRadius
      anchors { left: true; top: true }
      Corner { anchors.fill: parent; radius: Theme.cornerRadius; color: Theme.colorSecondary; corner: "topLeft" }
    }
  }
  Variants {
    model: Quickshell.screens
    PanelWindow {
      required property var modelData
      screen: modelData
      color: "transparent"
      implicitWidth: Theme.cornerRadius
      implicitHeight: Theme.cornerRadius
      anchors { right: true; bottom: true }
      Corner { anchors.fill: parent; radius: Theme.cornerRadius; color: Theme.colorSecondary; corner: "bottomRight" }
    }
  }
  Variants {
    model: Quickshell.screens
    PanelWindow {
      required property var modelData
      screen: modelData
      color: "transparent"
      implicitWidth: Theme.cornerRadius
      implicitHeight: Theme.cornerRadius
      anchors { right: true; top: true }
      Corner { anchors.fill: parent; radius: Theme.cornerRadius; color: Theme.colorSecondary; corner: "topRight" }
    }
  }
}
