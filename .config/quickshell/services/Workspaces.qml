pragma Singleton
import Quickshell
import Quickshell.Hyprland
import QtQuick

Singleton {
    readonly property var list: [...Hyprland.workspaces.values].sort((a, b) => a.id - b.id)
    readonly property int count: list.length
    readonly property int activeId: Hyprland.focusedWorkspace?.id ?? 0
}
