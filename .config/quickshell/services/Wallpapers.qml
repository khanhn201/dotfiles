pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Wallpapers available to the picker, read live from ~/.config/hypr/wallpapers
// (still just the image files themselves -- everything that *acts* on them is
// quickshell's own now).
Singleton {
    id: root

    readonly property string dir: Quickshell.env("HOME") + "/.config/hypr/wallpapers"
    readonly property string scriptsDir: Quickshell.env("HOME") + "/.config/quickshell/scripts"

    // [{ name, path }], sorted by filename.
    property var files: []

    // The wallpaper actually on screen right now. Seeded from theme-state.json
    // at startup (a plain binding), but apply() below overrides it directly
    // for instant feedback -- which permanently breaks that binding, same as
    // any QML property assigned to after being bound. That's fine: once
    // apply() has run at least once this session, this is the only source of
    // truth for it, not the file.
    property string currentPath: {
        try {
            return JSON.parse(stateFile.text()).current_wallpaper ?? "";
        } catch (e) {
            return "";
        }
    }

    FileView {
        id: stateFile
        path: Quickshell.env("HOME") + "/.config/quickshell/theme-state.json"
        blockLoading: true
        printErrors: false
    }

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

    // Set the wallpaper live -- Wallpaper.qml's Image is bound straight to
    // currentPath, so this alone repaints every screen the same frame, no
    // process and no wait. The colour scheme is real work (image
    // quantisation via the actual Material Color Utilities, over Node) that
    // no amount of native QML replaces, so that part still shells out --
    // but to the one script doing actual colour science, not a wrapper
    // gluing that to hyprctl/hyprpaper calls, which now happen directly
    // below instead.
    function apply(path) {
        root.currentPath = path;
        deriveProc.command = ["python3", root.scriptsDir + "/m3-from-wallpaper.py", path];
        deriveProc.running = true;
    }

    Process {
        id: deriveProc

        stderr: StdioCollector {}

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.warn("m3-from-wallpaper.py failed:", stderr.text);
                return;
            }
            // Hyprland reads colors.lua for its own border colours at
            // reload time, not live -- still needs telling. Quickshell's
            // own Colors.qml just needs re-reading, which a hard reload
            // does in place, in this same process: no more killing and
            // re-execing qs just to pick up a new wallpaper's palette.
            Quickshell.execDetached(["hyprctl", "reload"]);
            Quickshell.reload(true);
        }
    }
}
