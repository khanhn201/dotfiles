local awful = require("awful")
local watch = awful.widget.watch
local wibox = require("wibox")
local beautiful = require("beautiful")

return function()
	local brightness = wibox.widget({
		{
			id = "icon",
			text = " 0",
			align = "center",
			valign = "center",
			widget = wibox.widget.textbox,
		},
		layout = wibox.layout.flex.horizontal,
	})
    local widget = wibox.widget({
        brightness,
		widget = wibox.container.background,
        fg = beautiful.color3
    })

	watch(
		[[sh -c "brightnessctl | grep Current | awk '{ print $4 }'"]],
		1,
		function(_, stdout)
            local level = tonumber(string.match(stdout, "%d+"))
            if level < 7 then
                brightness.icon:set_text(" "..level)
            elseif level < 14 then
                brightness.icon:set_text(" "..level)
            elseif level < 21 then
                brightness.icon:set_text(" "..level)
            elseif level < 28 then
                brightness.icon:set_text(" "..level)
            elseif level < 35 then
                brightness.icon:set_text(" "..level)
            elseif level < 42 then
                brightness.icon:set_text(" "..level)
            elseif level < 49 then
                brightness.icon:set_text(" "..level)
            elseif level < 56 then
                brightness.icon:set_text(" "..level)
            elseif level < 63 then
                brightness.icon:set_text(" "..level)
            elseif level < 70 then
                brightness.icon:set_text(" "..level)
            elseif level < 77 then
                brightness.icon:set_text(" "..level)
            elseif level < 84 then
                brightness.icon:set_text(" "..level)
            elseif level < 91 then
                brightness.icon:set_text(" "..level)
            elseif level < 98 then
                brightness.icon:set_text(" "..level)
            else
                brightness.icon:set_text(" "..level)
            end
		end
	)

	return widget
end

