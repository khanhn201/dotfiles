local awful = require("awful")
local watch = awful.widget.watch
local wibox = require("wibox")
local beautiful = require("beautiful")

return function()
	local network = wibox.widget({
		{
			id = "icon",
			text = "󰤮 off",
			align = "center",
			valign = "center",
			widget = wibox.widget.textbox,
		},
		layout = wibox.layout.flex.horizontal,
	})
    local widget = wibox.widget({
        network,
		widget = wibox.container.background,
        fg = beautiful.palette.mauve.hex
    })
	
    watch(
		[[sh -c "nmcli -t -f active,ssid dev wifi | grep 'yes' | cut -d\: -f2"]],
		1,
		function(_, stdout)
			local net_ssid = stdout
			net_ssid = string.gsub(net_ssid, "^%s*(.-)%s*$", "%1")

            if net_ssid ~= "" then
				local getstrength = [[awk '/^\s*w/ { print  int($3 * 100 / 70) }' /proc/net/wireless]]
				awful.spawn.easy_async_with_shell(getstrength, function(stdout)
					if not tonumber(stdout) then
						return
					end
					local strength = tonumber(stdout)
					if strength <= 20 then
						network.icon:set_text("󰤯 "..net_ssid)
					elseif strength <= 40 then
						network.icon:set_text("󰤟 "..net_ssid)
					elseif strength <= 60 then
						network.icon:set_text("󰤢 "..net_ssid)
					elseif strength <= 80 then
						network.icon:set_text("󰤥 "..net_ssid)
					else
						network.icon:set_text("󰤨 "..net_ssid)
					end
				end)
			else
				network.icon:set_text("󰤮 off")
			end
		end
	)

	return widget
end
