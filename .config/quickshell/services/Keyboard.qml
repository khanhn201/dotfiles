pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

Singleton {
    id: root

    // Two-letter language of the active fcitx5 input method.
    property string layout: "en"

    // Material Symbols' "language_X" family is its own keyboard-layout
    // glyph set (a short text abbreviation per layout), not a flag --
    // language_us for en, language_japanese_kana (kana/romaji input) for
    // jp. No Vietnamese entry exists in it, so vn gets the family's own
    // generic "INTL" glyph instead of a language-specific one.
    readonly property string icon: {
        if (root.layout === "en") return "keyboard_us";
        if (root.layout === "jp") return "keyboard_jp";
        if (root.layout === "vn") return "keyboard_vn";
        return "keyboard";
    }

    // Reads the engine name and maps it to a label, matching the waybar
    // custom_modules/fcitx5.sh mapping.
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

    // fcitx5 exposes no DBus signal or property for a switch (confirmed via
    // dbus-monitor/busctl -- it just isn't there), so this can't watch fcitx5
    // itself the way Volume watches Pipewire. But Super+space is Hyprland's
    // own bind now rather than fcitx5's own hotkey (see hyprland.lua) --
    // Hyprland is the thing deciding a switch happened, so it nudges this the
    // same tick via hl.dsp.global, an immediate re-read instead of waiting on
    // a poll interval.
    GlobalShortcut {
        appid: "quickshell"
        name: "keyboard"
        onPressed: proc.running = true
    }
}
