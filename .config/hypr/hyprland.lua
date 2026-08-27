-- Hyprland config (Hyprland >= 0.55, Lua).
-- Wiki: https://wiki.hypr.land/Configuring/Start/

-- The colour scheme is derived from the wallpaper by
-- scripts/m3-from-wallpaper.py, which writes this table alongside the matching
-- Colors.qml for Quickshell and colors.conf for hyprlock. Re-run it after
-- changing the wallpaper; do not edit colors.lua by hand.
local colors = require("colors")


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({ output = "eDP-1",    mode = "preferred", position = "0x0",     scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080", position = "-1920x0", scale = 1 })
-- hl.monitor({ output = "HDMI-A-1", disabled = true })


---------------------
---- MY PROGRAMS ----
---------------------

local terminal    = "kitty"
local fileManager = "dolphin"


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("QT_QPA_PLATFORM",      "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")

hl.env("XCURSOR_PATH",     "/usr/share/icons")
hl.env("XCURSOR_THEME",    "Nordzy-cursors")
hl.env("XCURSOR_SIZE",     "36")
hl.env("HYPRCURSOR_THEME", "Nordzy-hyprcursors")
hl.env("HYPRCURSOR_SIZE",  "36")
-- hl.env("XDG_SESSION_TYPE",     "wayland")
-- hl.env("XDG_CURRENT_DESKTOP",  "Hyprland")
-- hl.env("XDG_SESSION_DESKTOP",  "Hyprland")

hl.env("NVD_BACKEND", "direct")

-- fcitx5: https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
-- hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS",   "@im=fcitx")

hl.env("LIBVA_DRIVER_NAME", "nvidia")
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

hl.config({
    -- unscale XWayland
    xwayland = {
        force_zero_scaling = true,
    },

    cursor = {
        no_hardware_cursors = true,
    },
})


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- `exec-once = ...` becomes hl.exec_cmd() inside the hyprland.start event.
hl.on("hyprland.start", function()
    -- hl.exec_cmd(terminal)
    -- hl.exec_cmd("nm-applet")
    hl.exec_cmd("fcitx5")
    hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland")
    hl.exec_cmd("systemctl --user restart xdg-desktop-portal")
    hl.exec_cmd("hyprpm reload")
    -- Polkit.qml (quickshell) is the polkit agent now, replacing
    -- hyprpolkitagent -- AuthPrompt.qml renders its prompts.
    -- hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    -- LockScreen.qml (quickshell) is the lock now; see services/Menus.qml's
    -- power-menu entry and LockScreen.qml's GlobalShortcut.
    hl.exec_cmd("hyprctl reload")
    -- QS_LOCK_ON_START tells LockScreen.qml (Component.onCompleted) to lock
    -- itself the moment it's actually ready, rather than Hyprland guessing
    -- how long quickshell's startup takes and dispatching blind after a
    -- fixed delay -- that raced quickshell's real startup time, which
    -- varies with boot load, and lost often enough to matter. Only set on
    -- this genuine hyprland.start exec, never on a manual `qs -n` restart
    -- mid-session, so reloading the shell while iterating on it doesn't
    -- also lock the screen.
    hl.exec_cmd("QS_LOCK_ON_START=1 qs -n")
    -- Auto-boots the Windows VM if bind_and_boot left a pending marker
    -- (see /home/nekoconn/qemu/bin/boot_windows_aff_if_pending); a no-op
    -- on a normal login.
    hl.exec_cmd("/home/nekoconn/qemu/bin/boot_windows_aff_if_pending")
    -- NotificationPopup.qml (quickshell) is the notification server now;
    -- dunst competed with it for the org.freedesktop.Notifications DBus
    -- name and, whichever won the race, silently ate the other's toasts.
    -- Wallpaper.qml (quickshell) renders the background directly, too --
    -- no separate wallpaper daemon.

end)


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 4,
        gaps_out = 8,

        border_size = 4,

        col = {
            -- The focused window carries the same accent the bar uses for
            -- whatever is active; everything else recedes to the same quiet
            -- tone as the dot rail's inactive pips (onSurfaceVariant), not
            -- outlineVariant -- the two should read as the same "inactive"
            -- language, not two different neutrals.
            active_border   = colors.primary,
            inactive_border = colors.onSurfaceVariant,
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout           = "scrolling",
        no_focus_fallback = true,
    },

    ecosystem = {
        no_update_news = true,
    },

    decoration = {
        rounding = 10,
        -- active_opacity   = 0.9,
        -- inactive_opacity = 0.9,

        blur = {
            enabled  = true,
            size     = 8,
            passes   = 1,

            vibrancy = 0.1696,
            -- ignore_opacity = true,
        },

        shadow = {
            enabled = false,
        },
    },

    animations = {
        enabled = true,
    },
})

-- `animation = <leaf>, <enabled>, <speed>, <curve>[, <style>]`
hl.animation({ leaf = "windows",    enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 2, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "default", style = "slidevert" })

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
        column_width             = 0.5,
        explicit_column_widths   = "0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0",
        focus_fit_method         = 1,
        follow_min_visible       = 1.0,
    },
})


----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper   = 0,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo     = true, -- If true disables the random hyprland logo / anime girl background. :(
        disable_splash_rendering  = true,
        initial_workspace_tracking = 2,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse  = 1,
        accel_profile = "flat",
        sensitivity   = 0.5, -- -1.0 - 1.0, 0 means no modification.

        focus_on_close = 1,

        touchpad = {
            natural_scroll = true,
            scroll_factor  = 0.25,
        },
    },
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- split-monitor-workspaces (hyprpm plugin) dispatchers have no hl.dsp binding,
-- so they went through hyprctl. Superseded by the dynamic workspace strip below.
-- NOTE: the plugin also rewrites workspace ids and names behind your back, so it
-- fights the strip. Disable it: hyprpm disable split-monitor-workspaces
-- local function pluginDispatch(dispatcher, arg)
--     return hl.dsp.exec_cmd("hyprctl dispatch " .. dispatcher .. " " .. arg)
-- end

-- The launcher, power menu and screenshot menu are Quickshell overlays now,
-- reached through Hyprland's global-shortcut protocol rather than by spawning
-- rofi -- the shell is already running, so nothing new starts.
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C",      hl.dsp.window.close())
hl.bind(mainMod .. " + M",      hl.dsp.exit())
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd("brave"))
hl.bind(mainMod .. " + V",      hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R",      hl.dsp.global("quickshell:launcher"))
hl.bind(mainMod .. " + X",      hl.dsp.global("quickshell:power"))
hl.bind(mainMod .. " + S",      hl.dsp.global("quickshell:screenshot"))

-- Built-in shell commands (currently just "pick a wallpaper"); the list lives
-- in Quickshell's Menus.qml, not here, so adding another command needs no
-- Hyprland change.
hl.bind(mainMod .. " + grave",  hl.dsp.global("quickshell:commands"))
hl.bind(mainMod .. " + F",      hl.dsp.window.fullscreen({ mode = "fullscreen" }))

-- Two dispatchers on one key: use a lua function and dispatch both.
hl.bind(mainMod .. " + Q", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end)

-- Input method cycling. This used to be fcitx5's own Super+space hotkey
-- (~/.config/fcitx5/config), invisible to Hyprland entirely -- fcitx5
-- intercepts its trigger keys from the raw input stream itself, so Hyprland
-- never saw a "switch" happen and Quickshell's Keyboard.qml had nothing to
-- react to but a 1s poll of `fcitx5-remote -n`. Owning the bind here means
-- Hyprland *is* the thing deciding the switch, so it can nudge Quickshell
-- (services/Keyboard.qml's GlobalShortcut) the same tick, same pattern as
-- the volume/brightness keys already used for their OSD pop.
hl.bind(mainMod .. " + space", function()
    hl.dispatch(hl.dsp.exec_cmd(
        "bash -c 'case \"$(fcitx5-remote -n)\" in " ..
        "keyboard-us) n=mozc;; mozc) n=unikey;; *) n=keyboard-us;; " ..
        "esac; fcitx5-remote -s \"$n\"'"
    ))
    hl.dispatch(hl.dsp.global("quickshell:keyboard"))
end)

-- Move focus with mainMod + arrow keys
-- One dispatcher for all four directions. movefocus walks the scrolling layout
-- on its own -- columns with left/right, the windows stacked in a column with
-- up/down -- and once there is nothing left to walk to, carries on to the
-- monitor in that direction. Workspace switching is SUPER + Tab.
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Rearranging the scrolling layout is invisible over IPC: swapping two columns
-- emits no Hyprland event at all, so a bar tracking the layout has no way to
-- know it happened and goes stale. Fire a custom event alongside these, which
-- reaches clients as ("custom", "columns").
local function announced(dispatcher)
    return function()
        hl.dispatch(dispatcher)
        hl.dispatch(hl.dsp.event("columns"))
    end
end

hl.bind(mainMod .. " + SHIFT + CTRL + left",  announced(hl.dsp.window.swap({ direction = "left" })))
hl.bind(mainMod .. " + SHIFT + CTRL + right", announced(hl.dsp.window.swap({ direction = "right" })))
hl.bind(mainMod .. " + SHIFT + left",         announced(hl.dsp.layout("swapcol l")))
hl.bind(mainMod .. " + SHIFT + right",        announced(hl.dsp.layout("swapcol r")))
hl.bind(mainMod .. " + SHIFT + up",           announced(hl.dsp.window.swap({ direction = "up" })))
hl.bind(mainMod .. " + SHIFT + down",         announced(hl.dsp.window.swap({ direction = "down" })))

-- Old numeric, plugin-backed workspace binds. Replaced by the strip below.
-- for i = 1, 10 do
--     local key = i % 10 -- 10 maps to key 0
--     hl.bind(mainMod .. " + " .. key,         pluginDispatch("split-workspace", i))
--     hl.bind(mainMod .. " + SHIFT + " .. key, pluginDispatch("split-movetoworkspacesilent", i))
-- end
-- hl.bind(mainMod .. " + mouse_down", pluginDispatch("split-workspace", "e+1"))
-- hl.bind(mainMod .. " + mouse_up",   pluginDispatch("split-workspace", "e-1"))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + equal", hl.dsp.layout("colresize +0.1"))
hl.bind(mainMod .. " + minus", hl.dsp.layout("colresize -0.1"))

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+"),            { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"),            { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),           { locked = true })

-- Brightness steps 5% where volume steps 1%, because the two keys repeat at very
-- different rates. Hyprland arms its own repeat timer on key press and cancels
-- it on release (KeybindManager.cpp), so a key that is genuinely held down ticks
-- at repeat_rate, 25/s. The brightness keys come from the laptop's ACPI hotkey
-- device rather than the keyboard, and that reports each press as a tap, so the
-- 600ms repeat delay never elapses and the only ticks are the firmware's own,
-- much slower. The bigger step is what makes a held key cover ground at roughly
-- the same speed as volume. Tune this number, not repeat_rate -- repeat_rate
-- never gets a chance to apply here.
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 1%+"),                               { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl --min-value=10 set 1%-"),               { locked = true, repeating = true })


-----------------------------------
---- DYNAMIC WORKSPACES (TABS) ----
-----------------------------------

-- Workspaces behave like browser tabs: an ordered strip you push onto, close,
-- reorder and cycle. Nothing is pinned to a number.
--
-- Order is the workspace id, ascending, within one monitor. It has to be the id
-- and nothing softer, because Hyprland picks its slide direction by comparing
-- ids (Monitor.cpp: pWorkspace->m_id > POLDWORKSPACE->m_id) -- order the strip
-- any other way and switching animates the wrong way after a reorder.
--
-- Ids are otherwise left alone. Only an explicit reorder moves one, and gaps
-- sort fine, so nothing renumbers behind your back. That matters: an id change
-- is announced as "changeworkspaceid", which many bars do not track, and each
-- one knocks them out of sync until they re-read. Keeping the churn to just the
-- reorder keeps that rare.

-- Each monitor gets its own independent strip: every operation below acts on the
-- strip of the monitor you are looking at, and never touches the other one.
-- Set false for a single strip shared by all monitors.
local WORKSPACES_PER_MONITOR = true

-- The strip for one monitor, or every normal workspace when strips are shared.
-- Defaults to the monitor you are looking at.
local function strip(mon)
    if WORKSPACES_PER_MONITOR then
        mon = mon or hl.get_active_monitor()
    else
        mon = nil
    end

    local list = {}
    for _, ws in ipairs(hl.get_workspaces()) do
        if ws.id > 0 and not ws.special and (not mon or (ws.monitor and ws.monitor.id == mon.id)) then
            list[#list + 1] = ws
        end
    end

    table.sort(list, function(a, b) return a.id < b.id end)
    return list
end

-- Position of the focused workspace in its own strip, plus that strip.
local function here()
    local cur = hl.get_active_workspace()
    if not cur then
        return nil, nil
    end

    local list = strip()
    for i, ws in ipairs(list) do
        if ws.id == cur.id then
            return list, i
        end
    end

    return list, nil
end

-- One past the highest id in use, so a new workspace always sorts to the end of
-- its monitor's strip and never collides with an id that already exists.
local function freeID()
    local max = 0
    for _, ws in ipairs(hl.get_workspaces()) do
        if ws.id > max then
            max = ws.id
        end
    end
    return max + 1
end

-- New workspace at the end of this monitor's strip, focused. Focusing an id that
-- does not exist yet creates it on the monitor you are looking at.
local function newWorkspace()
    hl.dispatch(hl.dsp.focus({ workspace = freeID() }))
end

-- Close this workspace, spilling its windows onto the previous one (or the next,
-- if this is the first). Hyprland reaps the workspace once it is empty, which
-- leaves a gap in the ids -- harmless, the order still reads the same.
local function closeWorkspace()
    local list, i = here()
    if not i then
        return
    end

    local target = list[i - 1] or list[i + 1]
    if not target then
        return -- last workspace standing, nothing to fold into
    end

    for _, w in ipairs(hl.get_workspace_windows(list[i].id)) do
        hl.dispatch(hl.dsp.window.move({ window = w, workspace = target.id, follow = false }))
    end

    hl.dispatch(hl.dsp.focus({ workspace = target.id }))
end

-- Slide this workspace along the strip by swapping ids with its neighbour. This
-- is the one place ids move. change_id refuses an id that is taken, so the swap
-- goes via a spare above the high-water mark.
local function shiftWorkspace(delta)
    local list, i = here()
    if not i or not list[i + delta] then
        return
    end

    local a, b  = list[i].id, list[i + delta].id
    local spare = freeID()

    hl.dispatch(hl.dsp.workspace.change_id({ workspace = b,     id = spare }))
    hl.dispatch(hl.dsp.workspace.change_id({ workspace = a,     id = b }))
    hl.dispatch(hl.dsp.workspace.change_id({ workspace = spare, id = a }))
end

-- Step along the strip, wrapping at both ends.
local function cycleWorkspace(delta)
    local list, i = here()
    if not i or #list < 2 then
        return
    end

    hl.dispatch(hl.dsp.focus({ workspace = list[((i - 1 + delta) % #list) + 1].id }))
end

local function gotoIndex(n)
    local ws = strip()[n]
    if ws then
        hl.dispatch(hl.dsp.focus({ workspace = ws.id }))
    end
end

-- Send the focused window along the strip. follow rides along with it.
local function sendWindow(delta, follow)
    local list, i = here()
    if not i or #list < 2 then
        return
    end

    hl.dispatch(hl.dsp.window.move({ workspace = list[((i - 1 + delta) % #list) + 1].id, follow = follow }))
end

local function sendToIndex(n, follow)
    local ws = strip()[n]
    if ws then
        hl.dispatch(hl.dsp.window.move({ workspace = ws.id, follow = follow }))
    end
end

-- Pop the focused window out into a fresh workspace at the end of the strip.
local function popWindow(follow)
    hl.dispatch(hl.dsp.window.move({ workspace = freeID(), follow = follow }))
end

-- Hand a window, or this whole workspace, to another monitor.
local function sendWindowToMonitor(dir)
    hl.dispatch(hl.dsp.window.move({ monitor = dir }))
end

local function sendWorkspaceToMonitor(dir)
    hl.dispatch(hl.dsp.workspace.move({ monitor = dir }))
end


-- Lifecycle
hl.bind(mainMod .. " + T",         newWorkspace)                        -- new workspace, focused
hl.bind(mainMod .. " + W",         closeWorkspace)                      -- close, windows fold onto the previous one
hl.bind(mainMod .. " + SHIFT + T", function() popWindow(true) end)      -- pop window into a new workspace

-- Page Up / Page Down, in both spellings: the keypad sends KP_Prior / KP_Next
-- from numpad 9 and 3. Hyprland resolves bind keysyms through an xkb state with
-- no modifiers applied, so those are what the numpad sends whether NumLock is on
-- or off -- KP_9 / KP_3 never reach a bind.
local PGUP = { "Page_Up",   "KP_Prior" }
local PGDN = { "Page_Down", "KP_Next" }

local function bindKeys(mods, keys, action)
    for _, key in ipairs(keys) do
        hl.bind(mods .. " + " .. key, action)
    end
end

-- Cycle
hl.bind(mainMod .. " + Tab",         function() cycleWorkspace(1) end)
hl.bind(mainMod .. " + SHIFT + Tab", function() cycleWorkspace(-1) end)
hl.bind(mainMod .. " + mouse_down",  function() cycleWorkspace(1) end)
hl.bind(mainMod .. " + mouse_up",    function() cycleWorkspace(-1) end)
bindKeys(mainMod, PGDN, function() cycleWorkspace(1) end)
bindKeys(mainMod, PGUP, function() cycleWorkspace(-1) end)

-- Only reachable if a keyboard sets resolve_binds_by_sym, where SHIFT + Tab
-- arrives as ISO_Left_Tab instead. Harmless otherwise: it can never fire.
hl.bind(mainMod .. " + SHIFT + ISO_Left_Tab", function() cycleWorkspace(-1) end)

-- Reorder the strip
bindKeys(mainMod .. " + SHIFT", PGUP, function() shiftWorkspace(-1) end)
bindKeys(mainMod .. " + SHIFT", PGDN, function() shiftWorkspace(1) end)

-- Move the focused window along the strip. Add SHIFT to send it without following.
bindKeys(mainMod .. " + CTRL",         PGUP, function() sendWindow(-1, true) end)
bindKeys(mainMod .. " + CTRL",         PGDN, function() sendWindow(1, true) end)
bindKeys(mainMod .. " + CTRL + SHIFT", PGUP, function() sendWindow(-1, false) end)
bindKeys(mainMod .. " + CTRL + SHIFT", PGDN, function() sendWindow(1, false) end)

-- Across monitors: CTRL moves the window, ALT moves the whole workspace
hl.bind(mainMod .. " + CTRL + left",  function() sendWindowToMonitor("l") end)
hl.bind(mainMod .. " + CTRL + right", function() sendWindowToMonitor("r") end)
hl.bind(mainMod .. " + ALT + left",   function() sendWorkspaceToMonitor("l") end)
hl.bind(mainMod .. " + ALT + right",  function() sendWorkspaceToMonitor("r") end)

-- Numbers, kept only as the alternative: positional, not id-based.
-- SUPER + 3 is "the third workspace in the strip", whatever its id happens to be.
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         function() gotoIndex(i) end)
    hl.bind(mainMod .. " + SHIFT + " .. key, function() sendToIndex(i, false) end)
end


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

hl.layer_rule({
    name  = "blur-rofi",
    match = { namespace = "rofi" },

    blur = true,
})

hl.window_rule({
    name  = "persistent-size",
    match = { class = ".*" },

    persistent_size = true,
})

-- Specific window rules
hl.window_rule({
    name  = "float-portal-gtk",
    match = { class = "xdg-desktop-portal-gtk" },
    float = true,
})
hl.window_rule({
    name  = "float-portal-kde",
    match = { class = "org.freedesktop.impl.portal.desktop.kde" },
    float = true,
})
hl.window_rule({
    name  = "float-xwayland",
    match = { xwayland = true },
    float = true,
})
hl.window_rule({
    name  = "float-octave",
    match = { class = "octave-gui" },
    float = true,
})
hl.window_rule({
    name  = "float-python",
    match = { class = "python" },
    float = true,
})

hl.window_rule({
    name       = "looking-glass",
    match      = { class = "looking-glass-client" },
    fullscreen = true,
})
hl.window_rule({
    name             = "looking-glass-render-unfocused",
    match            = { class = "looking-glass-client" },
    render_unfocused = true,
})

hl.window_rule({
    name  = "move-kitty",
    match = { class = "kitty" },

    size  = "900 600",
    move  = "100 100",
    float = true,
})

hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- hl.window_rule({
--     name  = "move-hyprland-run",
--     match = { class = "hyprland-run" },
--
--     move  = "20 monitor_h-120",
--     float = true,
-- })
