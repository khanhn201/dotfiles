pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int percentage: 0

    readonly property string icon: "cpu"

    // No native Quickshell API for CPU load, so sample /proc/stat and derive
    // usage from the change in idle-vs-total jiffies between polls.
    property real _prevIdle: 0
    property real _prevTotal: 0

    Process {
        id: proc
        command: ["cat", "/proc/stat"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                if (!line.startsWith("cpu ")) return;

                const fields = line.trim().split(/\s+/).slice(1).map(Number);
                const idle = fields[3] + (fields[4] || 0);       // idle + iowait
                const total = fields.reduce((a, b) => a + b, 0);

                const dIdle = idle - root._prevIdle;
                const dTotal = total - root._prevTotal;
                if (root._prevTotal > 0 && dTotal > 0)
                    root.percentage = Math.round((1 - dIdle / dTotal) * 100);

                root._prevIdle = idle;
                root._prevTotal = total;
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: proc.running = true
    }
}
