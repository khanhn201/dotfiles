#!/usr/bin/env bash
# Set a new wallpaper live and rederive the desktop's colour scheme from it.
#
#   apply-wallpaper.sh /path/to/image
#
# Three steps: push the image to hyprpaper on every connected monitor (no
# restart -- explicit per-monitor IPC calls, since the broadcast form only
# reliably reaches monitors that don't already have an active wallpaper),
# regenerate colors.lua/colors.conf/Colors.qml from it, then reload Hyprland
# and restart Quickshell so the new colours actually take effect.
#
# Mode (dark/light) is not passed explicitly -- m3-from-wallpaper.py resolves
# it from theme-state.json: this wallpaper's own last-used mode if it has one,
# otherwise whatever the previous wallpaper was in. That is what makes
# switching wallpapers remember each one's own mode.
set -euo pipefail

img="${1:?usage: apply-wallpaper.sh <image>}"
[ -f "$img" ] || { echo "no such file: $img" >&2; exit 1; }
img="$(readlink -f "$img")"

for mon in $(hyprctl -j monitors | jq -r '.[].name'); do
    hyprctl hyprpaper wallpaper "$mon,$img" >/dev/null
done

python3 "$HOME/.config/hypr/scripts/m3-from-wallpaper.py" "$img"

hyprctl reload >/dev/null

pkill -x qs 2>/dev/null || true
sleep 0.3
hyprctl dispatch 'hl.dsp.exec_cmd("qs -n")' >/dev/null
