---------------------------
-- Default awesome theme --
---------------------------
local palette = require("theme.mocha")
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local theme = {}

theme.font          = "JetBrainsMonoNerdFont 13"

theme.palette = palette

theme.bg_normal     = palette.base.hex
theme.bg_focus      = palette.overlay0.hex
theme.bg_urgent     = palette.red.hex
theme.bg_minimize   = "#444444"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = palette.text.hex
theme.fg_focus      = palette.green.hex
theme.fg_urgent     = palette.crust.hex
theme.fg_minimize   = palette.crust.hex
theme.taglist_fg_empty = palette.surface2.hex
theme.taglist_bg_focus = theme.bg_normal

theme.useless_gap   = dpi(3)
theme.snapper_gap   = dpi(3)
theme.border_width  = dpi(3)
theme.border_normal = palette.base.hex
theme.border_focus  = palette.green.hex
theme.border_marked = palette.maroon.hex

--- Black
theme.color0 = palette.surface1.hex
theme.color8 = palette.surface2.hex

--- Red
theme.color1 = palette.red.hex
theme.color9 = palette.red.hex

--- Green
theme.color2 = palette.green.hex
theme.color10 = palette.green.hex

--- Yellow
theme.color3 = palette.yellow.hex
theme.color11 = palette.yellow.hex

--- Blue
theme.color4 = palette.blue.hex
theme.color12 = palette.blue.hex

--- Magenta
theme.color5 = palette.pink.hex
theme.color13 = palette.pink.hex

--- Cyan
theme.color6 = palette.teal.hex
theme.color14 = palette.teal.hex

--- White
theme.color7 = palette.subtext1.hex
theme.color15 = palette.subtext0.hex


theme.wallpaper = "~/.config/awesome/theme/wallpaper.jpg"
-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
