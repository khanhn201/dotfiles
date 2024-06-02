local wibox = require("wibox")
local beautiful = require("beautiful")

return function()
    local clock = wibox.widget.textclock('󰥔 %H:%M')
    local widget = wibox.widget({
        clock,
		widget = wibox.container.background,
        fg = beautiful.palette.sapphire.hex
    })
    return widget
end
