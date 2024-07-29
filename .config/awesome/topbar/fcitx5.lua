local awful = require("awful")
local watch = awful.widget.watch
local wibox = require("wibox")
local beautiful = require("beautiful")

return function()
	local fcitx5 = wibox.widget({
		{
			id = "icon",
			text = "",
			align = "center",
			valign = "center",
			widget = wibox.widget.textbox,
		},
		layout = wibox.layout.flex.horizontal,
	})
    local widget = wibox.widget({
        fcitx5,
		widget = wibox.container.background,
        fg = beautiful.palette.pink.hex
    })

	watch(
		[[sh -c "fcitx5-remote -n"]],
		1,
		function(_, stdout)
            if stdout:find("us") then
                fcitx5.icon:set_text("󰌌 en")
            elseif stdout:find("mozc") then
                fcitx5.icon:set_text("󰌌 jp")
            elseif stdout:find("unikey") then
                fcitx5.icon:set_text("󰌌 vn")
		    end
		end
	)

	return widget
end

