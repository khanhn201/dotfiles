pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// The menus that used to be rofi scripts: the app launcher, the power
// menu and the screenshot menu. This holds only what they *are* -- which one is
// open, and what each entry does -- so Overlay.qml can stay presentation.
Singleton {
    id: root

    // "" | "launcher" | "power" | "screenshot" | "commands" | "wallpaperPicker"
    property string mode: ""

    readonly property string scripts: Quickshell.env("HOME") + "/.config/quickshell/scripts"

    // How many times each launcher entry (by desktop-entry id) has been
    // launched -- survives restarts, same JSON-file-under-config pattern
    // Wallpapers.qml's own state uses. JsonAdapter writes this back to disk
    // on every property change, so bumping a count is just reassigning the
    // whole object (a nested mutation alone wouldn't notify it).
    FileView {
        path: Quickshell.env("HOME") + "/.config/quickshell/launch-counts.json"
        printErrors: false

        JsonAdapter {
            id: usage
            property var counts: ({})
        }
    }

    function launchCount(id: string): int {
        return usage.counts[id] ?? 0;
    }

    function recordLaunch(id: string): void {
        const counts = Object.assign({}, usage.counts);
        counts[id] = (counts[id] ?? 0) + 1;
        usage.counts = counts;
    }

    // Subsequence fuzzy match, fzf-lite: -1 when query's characters don't
    // all appear in text in order, otherwise a score where higher is a
    // better match. Consecutive runs and matches right after a word
    // boundary score best, same shape as fzf's own simplified scoring, so
    // "fx" ranks "firefox" above "some other app with an f and an x in it".
    function fuzzyScore(text: string, query: string): real {
        if (query === "")
            return 0;
        const t = text.toLowerCase();
        const q = query.toLowerCase();
        let ti = 0, run = 0, score = 0;
        for (let qi = 0; qi < q.length; qi++) {
            const idx = t.indexOf(q[qi], ti);
            if (idx === -1)
                return -1;
            run = (idx === ti) ? run + 1 : 1;
            score += run * 2 - (idx - ti);
            if (idx === 0 || t[idx - 1] === " " || t[idx - 1] === "-")
                score += 5;
            ti = idx + 1;
        }
        // Reward a tightly-packed match and a shorter overall haystack --
        // an exact short name beats a long description containing the same
        // scattered letters.
        score -= (ti - q.length);
        score -= t.length * 0.01;
        return score;
    }

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

    // Same actions, icons and order the rofi powermenu had. Lock goes
    // through Session rather than an exec -- LockScreen.qml is our own lock
    // now, not a separate hyprlock process to spawn.
    readonly property var power: [
        { icon: "lock",     label: "Lock",     action: () => { root.close(); Session.lockRequested(); } },
        { icon: "reboot",   label: "Reboot",   exec: ["systemctl", "reboot"] },
        { icon: "shutdown", label: "Shutdown", exec: ["systemctl", "poweroff"] }
    ]

    readonly property var screenshot: [
        { icon: "screenshot_desktop", label: "Capture Desktop", exec: [root.scripts + "/screenshot.sh", "desktop"] },
        { icon: "screenshot_area",    label: "Capture Area",    exec: [root.scripts + "/screenshot.sh", "area"] },
        { icon: "screenshot_window",  label: "Capture Window",  exec: [root.scripts + "/screenshot.sh", "window"] }
    ]

    // The command palette (SUPER + `). Each entry runs its own action rather
    // than a fixed exec, so a command can do something other than spawn a
    // process -- Pick Wallpaper opens a second menu instead.
    readonly property var commands: [
        { icon: "wallpaper", label: "Pick Wallpaper", action: () => { root.mode = "wallpaperPicker"; } },
        {
            icon: ThemeMode.isDark ? "theme_dark" : "theme_light",
            label: ThemeMode.isDark ? "Switch to Light" : "Switch to Dark",
            action: () => { root.close(); ThemeMode.toggle(); }
        },
        // pkexec refuses to elevate a script sitting in a user-writable
        // directory (bind_and_boot lives in ~/qemu/bin), so this goes
        // through Sudo.qml -- its own prompt, not Polkit.qml's -- rather
        // than the system polkit agent every other privileged action here
        // would use.
        {
            icon: "boot_vm",
            label: "Boot Windows (VM)",
            action: () => {
                root.close();
                Sudo.request(["/home/nekoconn/qemu/bin/bind_and_boot"], "Authenticate to bind the GPU and boot the Windows VM");
            }
        }
    ]

    // Installed applications, filtered by a fuzzy query and ranked by match
    // quality, then how often each one gets launched. Matches the same
    // fields rofi's -drun-match-fields all did, just fuzzily instead of by
    // plain substring.
    function apps(query: string): var {
        const q = (query || "").trim();
        const scored = [];

        for (const entry of DesktopEntries.applications.values) {
            if (entry.noDisplay)
                continue;

            if (q === "") {
                scored.push({ entry, score: 0 });
                continue;
            }

            // Matching the name itself always outranks only matching a
            // keyword/description -- otherwise an app whose blurb happens
            // to contain the query reads as equally relevant as one whose
            // actual name does.
            const nameScore = root.fuzzyScore(entry.name, q);
            const otherHay = [entry.genericName, entry.comment, (entry.keywords || []).join(" ")]
                .filter(v => !!v).join(" ");
            const otherScore = root.fuzzyScore(otherHay, q);
            if (nameScore === -1 && otherScore === -1)
                continue;

            scored.push({ entry, score: nameScore !== -1 ? nameScore + 1000 : otherScore });
        }

        scored.sort((a, b) => {
            // Frequency only breaks ties between comparably-good matches --
            // a much better text match should still win over a more-used
            // app that barely matches at all, and with no query at all it's
            // the only signal there is.
            const scoreDiff = b.score - a.score;
            if (q !== "" && Math.abs(scoreDiff) > 0.5)
                return scoreDiff;
            const freqDiff = root.launchCount(b.entry.id) - root.launchCount(a.entry.id);
            if (freqDiff !== 0)
                return freqDiff;
            return a.entry.name.localeCompare(b.entry.name);
        });

        return scored.map(s => s.entry);
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

    // Single-quotes each argument, escaping any embedded ' -- the standard
    // "close, escape, reopen" trick, since single quotes admit no escape
    // sequences of their own.
    function shellQuote(args: var): string {
        return args.map(a => "'" + String(a).replace(/'/g, "'\\''") + "'").join(" ");
    }

    // A window-opening launch has to go through Hyprland's own exec, not
    // Quickshell.execDetached: only Hyprland's executor stamps the spawned
    // process with HL_INITIAL_WORKSPACE_TOKEN, which is what lets the
    // window land on the workspace it was launched *from* once it actually
    // maps -- which can be well after this call returns, and well after
    // whatever was the active workspace at that moment. Skip that token and
    // Hyprland falls back to "wherever's active when the window shows up",
    // which for anything slow to start is a coin flip -- most often
    // whichever workspace happens to be active by then, workspace 1 if nothing
    // else has changed it. hyprctl itself, not a script -- same as the
    // hyprctl reload calls elsewhere in this shell.
    function launch(entry: var) {
        root.close();
        root.recordLaunch(entry.id);
        // Terminal entries carry a bare command; give them one, as rofi did.
        const argv = entry.runInTerminal ? ["kitty", "-e"].concat(entry.command) : entry.command;
        const shellCmd = root.shellQuote(argv);
        const luaExpr = 'hl.dsp.exec_cmd("' + shellCmd.replace(/\\/g, "\\\\").replace(/"/g, '\\"') + '")';
        Quickshell.execDetached(["hyprctl", "dispatch", luaExpr]);
    }

    function runCommand(entry: var) {
        entry.action();
    }

    function pickWallpaper(entry: var) {
        root.close();
        Wallpapers.apply(entry.path);
    }
}
