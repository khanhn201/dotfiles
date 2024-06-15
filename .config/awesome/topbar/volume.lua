local awful = require("awful")
local watch = awful.widget.watch
local wibox = require("wibox")
local beautiful = require("beautiful")

return function()
	local volume = wibox.widget({
		{
			id = "icon",
			text = "󰝟 off",
			align = "center",
			valign = "center",
			widget = wibox.widget.textbox,
		},
		layout = wibox.layout.flex.horizontal,
	})
    local widget = wibox.widget({
        volume,
		widget = wibox.container.background,
        fg = beautiful.color6
    })

	watch(
		[[sh -c "wpctl get-volume @DEFAULT_AUDIO_SINK@"]],
		1,
		function(_, stdout)
            if stdout:find("MUTED") then
               volume.icon:set_text("󰝟 muted")
            else
                if tonumber(string.match(stdout, "%d+%.%d+")) then
                    local level = math.floor(tonumber(string.match(stdout, "%d+%.%d+"))*100)
                    if level < 34 then
                        volume.icon:set_text("󰕿 "..level)
                    elseif level < 67 then
                        volume.icon:set_text("󰖀 "..level)
                    else
                        volume.icon:set_text("󰕾 "..level)
                    end
                end
            end
		end
	)

	return widget
end

