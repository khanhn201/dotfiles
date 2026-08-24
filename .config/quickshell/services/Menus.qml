pragma Singleton
import Quickshell
import QtQuick

// The menus that used to be rofi scripts: the app launcher, the power
// menu and the screenshot menu. This holds only what they *are* -- which one is
// open, and what each entry does -- so Overlay.qml can stay presentation.
Singleton {
    id: root

    // "" | "launcher" | "power" | "screenshot" | "commands" | "wallpaperPicker"
    property string mode: ""

    readonly property string scripts: Quickshell.env("HOME") + "/.config/hypr/scripts"

    function toggle(which: string) {
        root.mode = (root.mode === which) ? "" : which;
    }

    function close() {
        root.mode = "";
    }

    // One step back rather than closing outright, for menus that are reached
    // through another menu (wallpaperPicker is opened from commands).
    function back() {
        if (root.mode === "wallpaperPicker")
            root.mode = "commands";
        else
            root.close();
    }

    // Same actions, icons and order the rofi powermenu had.
    readonly property var power: [
        { icon: "󰌾", label: "Lock",     exec: ["hyprlock"] },
        { icon: "󰜉", label: "Reboot",   exec: ["systemctl", "reboot"] },
        { icon: "󰐥", label: "Shutdown", exec: ["systemctl", "poweroff"] }
    ]

    readonly property var screenshot: [
        { icon: "󰍹", label: "Capture Desktop", exec: [root.scripts + "/screenshot.sh", "desktop"] },
        { icon: "󰆞", label: "Capture Area",    exec: [root.scripts + "/screenshot.sh", "area"] },
        { icon: "󰖲", label: "Capture Window",  exec: [root.scripts + "/screenshot.sh", "window"] }
    ]

    // The command palette (SUPER + `). Each entry runs its own action rather
    // than a fixed exec, so a command can do something other than spawn a
    // process -- Pick Wallpaper opens a second menu instead.
    readonly property var commands: [
        { icon: "🖼", label: "Pick Wallpaper", action: () => { root.mode = "wallpaperPicker"; } },
        {
            icon: ThemeMode.isDark ? "🌙" : "☀️",
            label: ThemeMode.isDark ? "Switch to Light" : "Switch to Dark",
            action: () => { root.close(); ThemeMode.toggle(); }
        }
    ]

    // Installed applications, filtered by a query and sorted by name. Matches
    // the same fields rofi's -drun-match-fields all did.
    function apps(query: string): var {
        const q = (query || "").trim().toLowerCase();
        const out = [];

        for (const entry of DesktopEntries.applications.values) {
            if (entry.noDisplay)
                continue;
            if (q !== "") {
                const hay = [entry.name, entry.genericName, entry.comment, (entry.keywords || []).join(" ")]
                    .filter(v => !!v).join(" ").toLowerCase();
                if (!hay.includes(q))
                    continue;
            }
            out.push(entry);
        }

        out.sort((a, b) => a.name.localeCompare(b.name));
        return out;
    }

    // What the overlay is currently listing.
    readonly property var entries: {
        if (root.mode === "power")
            return root.power;
        if (root.mode === "screenshot")
            return root.screenshot;
        if (root.mode === "commands")
            return root.commands;
        if (root.mode === "wallpaperPicker")
            return Wallpapers.files;
        return [];
    }

    function run(cmd: var) {
        root.close();
        Quickshell.execDetached(cmd);
    }

    function launch(entry: var) {
        root.close();
        // Terminal entries carry a bare command; give them one, as rofi did.
        if (entry.runInTerminal)
            Quickshell.execDetached(["kitty", "-e"].concat(entry.command));
        else
            Quickshell.execDetached(entry.command);
    }

    function runCommand(entry: var) {
        entry.action();
    }

    function pickWallpaper(entry: var) {
        root.close();
        Wallpapers.apply(entry.path);
    }
}
