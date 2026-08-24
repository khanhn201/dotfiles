pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

import "../"

// The live dark/light switch. Colors.qml is regenerated (both schemes, plus
// which one this wallpaper was last left in) whenever the wallpaper changes,
// but toggling mode on the *current* wallpaper does not wait for that: this
// singleton flips isDark immediately -- every Theme.colorXxx token is bound
// through it, so the whole shell repaints in the same frame -- then fires the
// script that persists the choice and updates Hyprland/hyprlock in the
// background. Quickshell itself never needs to restart for a mode toggle,
// only for a new wallpaper (new seed, genuinely new data to load).
Singleton {
    id: root

    property bool isDark: Colors.initialIsDark

    function toggle() {
        root.isDark = !root.isDark;
        Quickshell.execDetached([
            Quickshell.env("HOME") + "/.config/hypr/scripts/toggle-theme-mode.sh",
            root.isDark ? "dark" : "light",
        ]);
    }
}
