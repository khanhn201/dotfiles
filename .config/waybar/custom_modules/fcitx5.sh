#!/bin/bash

input_method=$(fcitx5-remote -n)

if [[ $input_method == *"us"* ]]; then
    echo '{"text": "󰌌 en"}'
elif [[ $input_method == *"mozc"* ]]; then
    echo '{"text": "󰌌 jp"}'
elif [[ $input_method == *"unikey"* ]]; then
    echo '{"text": "󰌌 vn"}'
fi
    
