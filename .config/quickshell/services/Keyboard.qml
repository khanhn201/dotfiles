pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Two-letter language of the active fcitx5 input method.
    property string layout: "en"

    readonly property string icon: "keyboard"

    // No native API, so poll fcitx5-remote and map the engine name to a label,
    // matching the waybar custom_modules/fcitx5.sh mapping.
    Process {
        id: proc
        command: ["fcitx5-remote", "-n"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                const name = line.trim();
                if (name.includes("mozc")) root.layout = "jp";
                else if (name.includes("unikey")) root.layout = "vn";
                else if (name.includes("us")) root.layout = "en";
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: proc.running = true
    }
}
