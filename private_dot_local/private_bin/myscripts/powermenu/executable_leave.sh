#!/usr/bin/sh

choice=$(printf "  Lock\n󰍃  Logout\n󰅶  Suspend\n󰑓  Reboot\n󰐥  Shutdown" | fuzzel --dmenu)

case "$choice" in
    "  Lock")
        swaylock -f -c ffffff
        ;;
    "󰍃  Logout")
        swaymsg exit
        ;;
    "󰅶  Suspend")
        systemctl suspend
        ;;
    "󰑓  Reboot")
        /home/phil/.config/fuzzel/reboot.sh
        ;;
    "󰐥  Shutdown")
        /home/phil/.config/fuzzel/shutdown.sh
        ;;
esac



