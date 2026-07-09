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
            implicitHeight: 10

            anchors {
                bottom: true
                left: true
                right: true
            }
        }
    }
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            color: Theme.colorSecondary
            implicitHeight: 10

            anchors {
                top: true
                left: true
                right: true
            }
        }
    }
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            color: Theme.colorSecondary
            implicitWidth: 10

            anchors {
                top: true
                bottom: true
                right: true
            }
        }
    }
}
