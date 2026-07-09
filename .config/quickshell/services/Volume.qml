pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    property int percentage: 0
    property bool muted: false

    readonly property string icon: {
        if (muted) return "󰝟"
        if (percentage >= 67) return ""
        if (percentage >= 34) return ""
        return ""
    }

    Process {
        id: wpctl
        command: ["wpctl", "get-volume", "@DEFAULT_SINK@"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                const m = line.match(/Volume:\s*([0-9.]+)/);
                if (m)
                    percentage = Math.round(parseFloat(m[1]) * 100);

                muted = line.includes("[MUTED]");
            }
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: wpctl.running = true
    }
}
