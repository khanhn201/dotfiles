local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local function rounded_wibar(cr, width, height)
    gears.shape.partially_rounded_rect(cr, width, height, true, true, true, true, 12)
end

return function(s)
    s.network = require("topbar.network")()
    s.battery = require("topbar.battery")()
    s.clock = require("topbar.clock")()
    s.calendar = require("topbar.calendar")()
    s.bluetooth = require("topbar.bluetooth")()
    s.volume = require("topbar.volume")()
    s.brightness = require("topbar.brightness")()
    s.player = require("topbar.player")()

    local taglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
    }

    s.topbar = awful.wibar({
        screen = s,
        position = "top",
        width = 1920 - 4*beautiful.useless_gap,
        shape = rounded_wibar
    })
    s.topbar_container = wibox.widget({
        bg = "#00ff00ff",
        {
            layout = wibox.layout.align.horizontal,
            expand = "inside",
            taglist,
            s.player,
            {
                layout = wibox.layout.fixed.horizontal,
                spacing = 20,
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
