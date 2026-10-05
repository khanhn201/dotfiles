pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string icon: "brightness"

    readonly property string devicePath: "/sys/class/backlight/amdgpu_bl1"

    readonly property int maxBrightness: parseInt(maxFile.text()) || 1
    readonly property int percentage: Math.round((parseInt(liveFile.text()) || 0) / root.maxBrightness * 100)

    FileView {
        id: maxFile
        path: root.devicePath + "/max_brightness"
        blockLoading: true
    }

    FileView {
        id: liveFile
        path: root.devicePath + "/brightness"
        blockLoading: true
    }

    Process {
        command: ["stdbuf", "-oL", "udevadm", "monitor", "--udev", "--subsystem-match=backlight"]
        running: true

        stdout: SplitParser {
            onRead: line => {
                if (line.includes("change"))
                    liveFile.reload();
            }
        }
    }
}
