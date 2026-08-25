pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Material Symbols has no graduated brightness-sun ramp (its brightness_N
    // glyphs are unrelated circle icons), so this reads the same way Cpu and
    // Memory do: one static glyph, the number carries the value.
    readonly property string icon: "brightness"

    // amdgpu_bl1 -- this machine's own backlight device (see
    // /sys/class/backlight/).
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

    // The kernel doesn't run sysfs_notify() on this attribute -- confirmed
    // neither inotify (FileView's own watchChanges) nor a raw POLLPRI
    // poll() ever wakes on it -- so this watches the udev "change" event
    // the amdgpu backlight driver emits instead: a persistent netlink
    // subscription, not a poll loop, reacting the instant brightnessctl
    // (or anything else) writes a new value rather than up to one polling
    // interval late, which is what made this noticeably laggier than
    // Volume's own live Pipewire binding. stdbuf -oL matters here --
    // udevadm's stdout is fully buffered rather than line-buffered once
    // it's a pipe instead of a terminal, so without it every "change" line
    // sits in that buffer until it happens to fill, arriving in delayed,
    // batched clumps instead of as they occur.
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
