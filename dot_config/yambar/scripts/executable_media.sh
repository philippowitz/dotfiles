#!/usr/bin/sh

while true; do
    status=$(pgrep -c spotify_player)
    if [ "$status" -eq 1 ]; then
        printf "state|bool|true\n"
        playerctl -p spotify_player metadata -f "status|string|{{status}}"
        playerctl -p spotify_player metadata -f "artist|string|{{artist}}"
        playerctl -p spotify_player metadata -f "title|string|{{title}}"
    else
        printf "state|bool|false\n"
    fi
    printf "\n"
    sleep 1s
done
