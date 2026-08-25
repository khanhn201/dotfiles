pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

import "../"

// The live dark/light switch. Colors.qml already carries both schemes for
// the current wallpaper, so toggling mode needs no new colour data and no
// wait: this singleton flips isDark immediately -- every Theme.colorXxx
// token is bound through it, so the whole shell repaints in the same frame
// -- then calls the same derivation script apply() does, just to persist
// the choice and refresh colors.lua/colors.conf for Hyprland/hyprlock.
// Quickshell itself never needs to reload for a mode toggle, only for a new
// wallpaper (new seed, genuinely new data to load) -- see Wallpapers.apply.
Singleton {
    id: root

    property bool isDark: Colors.initialIsDark

    function toggle() {
        root.isDark = !root.isDark;
        deriveProc.command = [
            "python3", Wallpapers.scriptsDir + "/m3-from-wallpaper.py",
            "--mode", root.isDark ? "dark" : "light",
        ];
        deriveProc.running = true;
    }

    Process {
        id: deriveProc

        stderr: StdioCollector {}

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.warn("m3-from-wallpaper.py --mode failed:", stderr.text);
                return;
            }
            Quickshell.execDetached(["hyprctl", "reload"]);
        }
    }
}
