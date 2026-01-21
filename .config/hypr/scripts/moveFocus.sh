#!/usr/bin/env bash

direction=$1
changeto=$2

pre=$(hyprctl -j activewindow | jq -r '.address')
hyprctl dispatch movefocus $direction
post=$(hyprctl -j activewindow | jq -r '.address')

if [[ $post = $pre ]]; then
  hyprctl dispatch workspace $changeto
fi

exit 0
