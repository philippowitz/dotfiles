#!/bin/bash

# Get the current state of the touchpad
STATE=$(riverctl list-input-configs | grep "keyboard-1-1-AT_Translated_Set_2_keyboard" -A 1 | grep -q "events: enabled" && echo "enabled" || echo "disabled")

if [ "$STATE" == "disabled" ]; then
    # Enable touchpad
    riverctl input keyboard-1-1-AT_Translated_Set_2_keyboard events enabled
    notify-send "Builtin Keyboard Enabled"
else
    # Disable touchpad
    riverctl input keyboard-1-1-AT_Translated_Set_2_keyboard events disabled
    notify-send "Builtin Keyboard Disabled"
fi
