if [[ $(xdotool getactivewindow getwindowname) =~ ^emacs(:.*)?@.* ]]; then
    command="(my/emacs-sway-integration \"$@\")"
    emacsclient -e "$command"
else
    swaymsg $@
fi
