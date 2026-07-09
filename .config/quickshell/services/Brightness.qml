pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import QtQuick

Singleton {
    property int percentage: 0

    readonly property var icons: [
        "", "", "", "", "",
        "", "", "", "", "",
        "", "", "", "", ""
    ]

    readonly property string icon: {
        const idx = Math.floor(percentage / 100 * icons.length);
        return icons[idx];
    }

    Process {
        id: brightnessctl
        command: ["brightnessctl", "-m"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                const fields = line.trim().split(",");
                if (fields.length >= 4)
                    percentage = parseInt(fields[3]);
            }
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: brightnessctl.running = true
    }
}
