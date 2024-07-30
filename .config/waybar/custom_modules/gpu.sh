#!/bin/bash

gpu=$(check_gpu)

if [[ $gpu == "on" ]]; then
    echo '{"text": "󰾲 on"}'
else
    echo '{"text": "󰾲 off"}'
fi
    
