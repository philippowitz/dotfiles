#!/bin/bash

# Define the path to your binary and a lock file location
BINARY_PATH="/bin/grimshot"
LOCK_FILE="/tmp/grimshot.lock"

# Attempt to acquire an exclusive lock
exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    echo "Another instance of the binary is already running."
    exit 1
fi

trap 'rm -f "$LOCK_FILE"; exit' INT TERM EXIT

# Run the binary
"$BINARY_PATH" "$@"
