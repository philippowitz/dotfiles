#!/usr/bin/sh

choice=$(printf "Inhibit view when focused\nInhibit view when fullscreen\nInhibit when view is open\nInhibit view when visible\nRemove inhibition" | fuzzel --dmenu)

case "$choice" in
    "Inhibit view when focused")
        l:
        ;;
    "Inhibit view when fullscreen")
        ;;
    "Inhibit when view is open")
        ;;
    "Inhibit view when visible")
        ;;
    "Remove inhibition")
        ;;
esac



