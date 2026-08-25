// The desktop background, rendered directly instead of through hyprpaper --
// one less daemon, and Wallpapers.currentPath is already the single source
// of truth apply() writes to, so this is just a plain binding away.
import Quickshell
import Quickshell.Wayland
import QtQuick

import "./services"

PanelWindow {
    id: root

    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    // The true background, behind every window and every other frame
    // piece here -- reserves nothing, sits under everything.
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background

    Image {
        anchors.fill: parent
        source: Wallpapers.currentPath ? "file://" + Wallpapers.currentPath : ""
        // Cover fit, same as hyprpaper.conf's own fit_mode was.
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }
}
