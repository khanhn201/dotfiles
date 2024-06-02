local wibox = require("wibox")
local beautiful = require("beautiful")

return function()
    local calendar = wibox.widget.textclock('󰃭 %a %b %d %Y')
    local widget = wibox.widget({
        calendar,
		widget = wibox.container.background,
        fg = beautiful.color1
    })
    return widget
end
