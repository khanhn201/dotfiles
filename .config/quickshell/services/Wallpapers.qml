pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Wallpapers available to the picker, read live from ~/.config/hypr/wallpapers.
Singleton {
    id: root

    readonly property string dir: Quickshell.env("HOME") + "/.config/hypr/wallpapers"
    readonly property string applyScript: Quickshell.env("HOME") + "/.config/hypr/scripts/apply-wallpaper.sh"

    // [{ name, path }], sorted by filename.
    property var files: []

    function refresh() {
        listProc.running = true;
    }

    Process {
        id: listProc
        command: ["find", root.dir, "-maxdepth", "1", "-type", "f", "(",
                  "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o",
                  "-iname", "*.png", "-o", "-iname", "*.webp", ")"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n").map(l => l.trim()).filter(l => l.length > 0);
                lines.sort();
                root.files = lines.map(p => ({ path: p, name: p.slice(p.lastIndexOf("/") + 1) }));
            }
        }
    }

    Component.onCompleted: refresh();

    // Set the wallpaper live and rederive the colour scheme from it. Fully
    // detached: the script reloads Hyprland and restarts this shell itself,
    // so nothing here waits around for that to happen.
    function apply(path) {
        Quickshell.execDetached([root.applyScript, path]);
    }
}
