#!/bin/bash

response=$(echo -e "Cancel\nShutdown" | fuzzel --prompt="Are you sure you want to shut down? " --lines=2 --dmenu)

if [ "$response" = "Shutdown" ]; then
    # If confirmed, initiate shutdown
    systemctl poweroff
fi
