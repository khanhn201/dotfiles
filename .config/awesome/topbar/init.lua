local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")


return function(s)
    s.network = require("topbar.network")()
    s.battery = require("topbar.battery")()
    s.clock = require("topbar.clock")()
    s.calendar = require("topbar.calendar")()
    s.bluetooth = require("topbar.bluetooth")()
    s.volume = require("topbar.volume")()
    s.brightness = require("topbar.brightness")()
    s.player = require("topbar.player")()
    s.fcitx5 = require("topbar.fcitx5")()

    local taglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
    }

    s.topbar = awful.wibar({
        screen = s,
        position = "top",
        width = 1920 - 4*beautiful.useless_gap
    })
    s.topbar_container = wibox.widget({
        {
            layout = wibox.layout.align.horizontal,
            expand = "inside",
            taglist,
            s.player,
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = 20,
                -- wibox.widget.systray(),
                s.fcitx5,
                s.volume,
                s.brightness,
                s.battery,
                s.bluetooth,
                s.network,
                s.calendar,
                s.clock
            },
        },
		widget = wibox.container.margin,
        left = 10,
        right = 10
    })
    s.topbar:setup {
        layout = wibox.layout.flex.horizontal,
        s.topbar_container
    }

end
