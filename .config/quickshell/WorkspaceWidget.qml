import QtQuick
import QtQuick.Layouts

import "./components"
import "./services"

ColumnLayout {
    spacing: 4

    Repeater {
        model: Workspaces.list

        StyledRectangle {
            required property var modelData

            Layout.fillWidth: true
            implicitHeight: 24
            color: modelData.id === Workspaces.activeId ? Theme.colorPrimary : Theme.colorSurfaceContainerHigh
            text: modelData.id
        }
    }
}
