#!/bin/bash

response=$(echo -e "Cancel\nReboot" | fuzzel --prompt="Are you sure you want to reboot? " --lines=2 --dmenu)

if [ "$response" = "Reboot" ]; then
    # If confirmed, initiate shutdown
    systemctl reboot
fi
