#!/bin/bash

# Get the current state of the touchpad
STATE=$(swaymsg -t get_inputs | grep -A 4 "Touchpad" | grep -o "disabled")

if [ "$STATE" == "disabled" ]; then
    # Enable touchpad
    swaymsg input type:touchpad events enabled
    notify-send "Touchpad Enabled"
else
    # Disable touchpad
    swaymsg input type:touchpad events disabled
    notify-send "Touchpad Disabled"
fi
