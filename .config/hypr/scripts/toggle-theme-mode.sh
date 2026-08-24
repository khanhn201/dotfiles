#!/usr/bin/env bash
# Persist a dark/light toggle and update Hyprland's border colours + the next
# hyprlock launch to match.
#
#   toggle-theme-mode.sh dark|light
#
# Quickshell is deliberately not touched here: ThemeMode.qml flips its own
# live isDark property before this script even runs, so the bar has already
# repainted by the time this starts -- this only catches up the two things
# that cannot hot-reload (Hyprland's border colour is read from colors.lua at
# `hyprctl reload` time; hyprlock reads colors.conf at its own next launch)
# and Colors.qml's initialIsDark on disk, so a future restart boots into the
# mode you actually left things in rather than reverting.
set -euo pipefail

mode="${1:?usage: toggle-theme-mode.sh dark|light}"
case "$mode" in
    dark|light) ;;
    *) echo "mode must be 'dark' or 'light', got: $mode" >&2; exit 1 ;;
esac

python3 "$HOME/.config/hypr/scripts/m3-from-wallpaper.py" --mode "$mode"

hyprctl reload >/dev/null
