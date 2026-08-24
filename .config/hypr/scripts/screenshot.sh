#!/usr/bin/env bash
# Capture the screen. The menu that used to front this lives in Quickshell now;
# this is just the capture, kept in shell because grim/slurp/wl-copy is a pipe.
#
#   screenshot.sh desktop | area | window
#
# Note the cursor is hidden via `hyprctl eval`, not `hyprctl keyword`: keyword
# does not work under the Lua config parser ("keyword can't work with
# non-legacy parsers"), which had silently broken this since the migration.
set -euo pipefail

mode="${1:-desktop}"
dir="$HOME/Pictures/Screenshots"
file="$dir/Screenshot_$(date +%Y%m%d-%H%M%S).png"
mkdir -p "$dir"

cursor() { hyprctl eval "hl.config({ cursor = { invisible = $1 } })" >/dev/null; }

geometry=""
case "$mode" in
    desktop) ;;
    window)  geometry=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"') ;;
    area)    geometry=$(slurp -d) || exit 0
             [ -n "$geometry" ] || exit 0 ;;
    *)       echo "usage: screenshot.sh desktop|area|window" >&2; exit 2 ;;
esac

cursor true
trap 'cursor false' EXIT
sleep 0.1

if [ -n "$geometry" ]; then
    grim -g "$geometry" - | tee "$file" | wl-copy --type image/png
else
    grim - | tee "$file" | wl-copy --type image/png
fi

sleep 0.1
echo "$file"
