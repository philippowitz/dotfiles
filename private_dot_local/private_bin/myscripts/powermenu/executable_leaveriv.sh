#!/usr/bin/sh

choice=$(printf "  Lock\n󰍃  Logout\n󰅶  Suspend\n󰑓  Reboot\n󰐥  Shutdown" | fuzzel --dmenu)

case "$choice" in
    "  Lock")
        waylock -fork-on-lock -init-color 0xfdf6e3 -input-color 0xb58900
        ;;
    "󰍃  Logout")
        pkill -KILL -u "$USER" #riverctl exit 
        ;;
    "󰅶  Suspend")
        systemctl suspend
        ;;
    "󰑓  Reboot")
        which reboot.sh >> ~/debug.log
        reboot.sh
        ;;
    "󰐥  Shutdown")
        shutdown.sh
        ;;
esac



