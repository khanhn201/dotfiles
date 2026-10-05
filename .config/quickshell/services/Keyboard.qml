pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string layout: "en"

    readonly property string icon: {
        if (root.layout === "en") return "keyboard_us";
        if (root.layout === "jp") return "keyboard_jp";
        if (root.layout === "vn") return "keyboard_vn";
        return "keyboard";
    }

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

    IpcHandler {
        target: "keyboard"
        function refresh(): void { proc.running = true }
    }
}
