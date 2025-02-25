#!/bin/bash
# Define the directory to search

directory="/home/phil"
args=""
cache=""

while [[ "$#" -gt 0 ]]; do
    echo "Processing argument: $1"
    case $1 in
        --dir) directory="$2"; shift ;;
        --args) args="$2"; shift ;;
        --cache) cache="$2"; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done


if [[ -n "$cache" ]]; then
    result=$(fd . "$directory" $args | fuzzel --dmenu -w 200 -l 45 --counter --cache "$cache")
else
    result=$(fd . "$directory" $args | fuzzel --dmenu -w 200 -l 45 --counter)
fi

if [[ -z "$result" ]]; then
    echo "No result selected or command failed."
    exit 1
fi

/home/phil/.config/fuzzel/lopen.sh "$result"
