local awful = require("awful")
local watch = awful.widget.watch
local wibox = require("wibox")
local beautiful = require("beautiful")

return function()
	local bluetooth = wibox.widget({
		{
			id = "icon",
			text = "󰂲 off",
			align = "center",
			valign = "center",
			widget = wibox.widget.textbox,
		},
		layout = wibox.layout.flex.horizontal,
	})
    local widget = wibox.widget({
        bluetooth,
		widget = wibox.container.background,
        fg = beautiful.color4
    })
	
    watch(
		[[sh -c "bluetoothctl show | grep Powered"]],
		10,
		function(_, stdout)
			local enabled = stdout

			if enabled:find("yes") then
				local getcount = [[bluetoothctl devices Connected | wc -l]]
				awful.spawn.easy_async_with_shell(getcount, function(stdout)
					if not tonumber(stdout) then
						return
					end
                    if tonumber(stdout) == 0 then
                        bluetooth.icon:set_text("󰂯 on")
				    else
                        bluetooth.icon:set_text(string.format("󰂱 %d", tonumber(stdout)))
                    end
                end)
			else
				bluetooth.icon:set_text("󰂲 off")
			end
		end
	)

	return widget
end
