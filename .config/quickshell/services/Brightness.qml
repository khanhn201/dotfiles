pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    property int percentage: 0

    // Material Symbols has no graduated brightness-sun ramp (its brightness_N
    // glyphs are unrelated circle icons), so this reads the same way Cpu and
    // Memory do: one static glyph, the number carries the value.
    readonly property string icon: "brightness"

    // No native Quickshell API for backlight, so poll brightnessctl.
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
        interval: 200
        running: true
        repeat: true
        onTriggered: brightnessctl.running = true
    }
}
