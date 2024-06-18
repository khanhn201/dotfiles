-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")

local top_panel = require("topbar")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}


-- Autostart
require("autostart")
require("topbar")

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/theme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    -- awful.layout.suit.floating
    awful.layout.suit.spiral.dwindle
}
-- }}}

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)
	  top_panel(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.suit.spiral.dwindle)
end)
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    -- Prompt
    awful.key({ modkey },            "r",     function ()
        awful.util.spawn("bash /home/nekoconn/.config/rofi/bin/launcher", false)
    end,{description = "run prompt", group = "launcher"}),

    awful.key({ modkey },            "x",     function ()
        awful.util.spawn("bash /home/nekoconn/.config/rofi/bin/powermenu", false)
    end,{description = "powermenu", group = "launcher"}),
    
    awful.key({ modkey },            "s",     function ()
        awful.util.spawn("bash /home/nekoconn/.config/rofi/bin/screenshot", false)
    end,{description = "screenshot", group = "launcher"}),
    -- Navigation
    awful.key({ modkey, }, "Left",  function () awful.client.focus.global_bydirection("left") end,
              {description = "focus left", group = "client"}),
    awful.key({ modkey, }, "Right",  function () awful.client.focus.global_bydirection("right") end,
              {description = "focus right", group = "client"}),
    awful.key({ modkey, }, "Up",  function () awful.client.focus.global_bydirection("up") end,
              {description = "focus up", group = "client"}),
    awful.key({ modkey, }, "Down",  function () awful.client.focus.global_bydirection("down") end,
              {description = "focus down", group = "client"}),

    -- Media Control
    awful.key({}, "XF86AudioLowerVolume", function ()
      awful.util.spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-", false) end),
    awful.key({}, "XF86AudioRaiseVolume", function ()
      awful.util.spawn("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 1%+", false) end),
    awful.key({}, "XF86AudioMute", function ()
      awful.util.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle", false) end),
     -- Media Keys
    awful.key({}, "XF86AudioPlay", function()
      awful.util.spawn("playerctl play-pause", false) end),
    awful.key({}, "XF86AudioNext", function()
      awful.util.spawn("playerctl next", false) end),
    awful.key({}, "XF86AudioPrev", function()
      awful.util.spawn("playerctl previous", false) end),
     -- Brightness Keys
    awful.key({}, "XF86MonBrightnessDown", function()
      awful.util.spawn("brightnessctl --min-value=40 set 5%-", false) end),
    awful.key({}, "XF86MonBrightnessUp", function()
      awful.util.spawn("brightnessctl set +5%", false) end)
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,   }, "c",      function (c) c:kill() end,
              {description = "close", group = "client"}),
    awful.key({ modkey, }, "v", function (c)
        awful.client.floating.toggle(c)
        c:raise()
    end,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    
    -- Swapping
    awful.key({ modkey, "Shift"}, "Left",  function () awful.client.swap.global_bydirection("left") end,
              {description = "focus left", group = "client"}),
    awful.key({ modkey, "Shift"}, "Right",  function () awful.client.swap.global_bydirection("right") end,
              {description = "focus right", group = "client"}),
    awful.key({ modkey, "Shift"}, "Up",  function () awful.client.swap.global_bydirection("up") end,
              {description = "focus up", group = "client"}),
    awful.key({ modkey, "Shift"}, "Down",  function () awful.client.swap.global_bydirection("down") end,
              {description = "focus down", group = "client"})


)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = {
                    border_width = beautiful.border_width,
                    border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }}
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
