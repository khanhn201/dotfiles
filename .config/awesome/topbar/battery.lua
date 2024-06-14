local awful = require("awful")
local watch = awful.widget.watch
local wibox = require("wibox")
local beautiful = require("beautiful")

return function()
	local battery = wibox.widget({
		{
			id = "icon",
			text = "󰂎 ",
			align = "center",
			valign = "center",
			widget = wibox.widget.textbox,
		},
		layout = wibox.layout.flex.horizontal,
	})
    local widget = wibox.widget({
        battery,
		widget = wibox.container.background,
        fg = beautiful.color2
    })

	watch(
		[[sh -c "upower -i \"$(upower -e | grep BAT)\" | grep state"]],
		60,
		function(_, stdout)
            if string.find(stdout, "discharging") then
				local getstrength = [[upower -i "$(upower -e | grep BAT)" | grep percentage | awk '{print int($2)}']]
                awful.spawn.easy_async_with_shell(getstrength, function(stdout)
					if not tonumber(stdout) then
						return
					end
					local strength = tonumber(stdout)
					if strength <= 10 then
						battery.icon:set_text(string.format("󰁺 %d", strength))
					elseif strength <= 20 then
						battery.icon:set_text(string.format("󰁻 %d", strength))
					elseif strength <= 30 then
						battery.icon:set_text(string.format("󰁼 %d", strength))
					elseif strength <= 40 then
						battery.icon:set_text(string.format("󰁽 %d", strength))
					elseif strength <= 50 then
						battery.icon:set_text(string.format("󰁾 %d", strength))
					elseif strength <= 60 then
						battery.icon:set_text(string.format("󰁿 %d", strength))
					elseif strength <= 70 then
						battery.icon:set_text(string.format("󰂀 %d", strength))
					elseif strength <= 80 then
						battery.icon:set_text(string.format("󰂁 %d", strength))
					elseif strength <= 90 then
						battery.icon:set_text(string.format("󰂂 %d", strength))
					else
						battery.icon:set_text(string.format("󰁹 %d", strength))
					end
				end)
            elseif string.find(stdout, "fully") then
                battery.icon:set_text("󰂅 100")
            else
                local getstrength = [[upower -i "$(upower -e | grep BAT)" | grep percentage | awk '{print int($2)}']]
				awful.spawn.easy_async_with_shell(getstrength, function(stdout)
					if not tonumber(stdout) then
						return
					end
					local strength = tonumber(stdout)
					if strength <= 10 then
						battery.icon:set_text(string.format("󰢜 %d", strength))
					elseif strength <= 20 then
						battery.icon:set_text(string.format("󰂆 %d", strength))
					elseif strength <= 30 then
						battery.icon:set_text(string.format("󰂇 %d", strength))
					elseif strength <= 40 then
						battery.icon:set_text(string.format("󰂈 %d", strength))
					elseif strength <= 50 then
						battery.icon:set_text(string.format("󰢝 %d", strength))
					elseif strength <= 60 then
						battery.icon:set_text(string.format("󰂉 %d", strength))
					elseif strength <= 70 then
						battery.icon:set_text(string.format("󰢞 %d", strength))
					elseif strength <= 80 then
						battery.icon:set_text(string.format("󰂊 %d", strength))
					elseif strength <= 90 then
						battery.icon:set_text(string.format("󰂋 %d", strength))
					else
						battery.icon:set_text(string.format("󰂅 %d", strength))
					end
				end)

			end
		end
	)

	return widget
end

