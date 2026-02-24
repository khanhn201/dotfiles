#!/usr/bin/env bash

direction=$1
changeto=$2

pre=$(hyprctl -j activewindow | jq -r '.address')
hyprctl dispatch layoutmsg focus $direction
post=$(hyprctl -j activewindow | jq -r '.address')

if [[ $post = $pre ]]; then
  if [[ $changeto = "left" ]]; then
    hyprctl dispatch movefocus l
  elif [[ $changeto = "right" ]]; then
    hyprctl dispatch movefocus r
  else
    hyprctl dispatch workspace $changeto
  fi
fi

exit 0
