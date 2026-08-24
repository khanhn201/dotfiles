pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int percentage: 0

    readonly property string icon: "memory"

    // No native Quickshell API for memory, so read /proc/meminfo and compute
    // used = total - available. MemTotal is read first, then applied when the
    // MemAvailable line arrives.
    property real _total: 0

    Process {
        id: proc
        command: ["cat", "/proc/meminfo"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                if (line.startsWith("MemTotal:")) {
                    root._total = parseFloat(line.split(/\s+/)[1]);
                } else if (line.startsWith("MemAvailable:")) {
                    const avail = parseFloat(line.split(/\s+/)[1]);
                    if (root._total > 0)
                        root.percentage = Math.round((1 - avail / root._total) * 100);
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: proc.running = true
    }
}
