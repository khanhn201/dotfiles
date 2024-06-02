local awful = require("awful")


awful.spawn("autorandr -c", false)
awful.spawn("xset s off", false)
awful.spawn("xset -dpms", false)
awful.spawn("picom", false)
