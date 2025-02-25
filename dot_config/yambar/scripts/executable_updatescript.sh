#!/bin/bash
paru

# Get the process ID of the main script
MAIN_SCRIPT_PID=$(pgrep -f "my-pacman.sh")

if [ -n "$MAIN_SCRIPT_PID" ]; then
  # Send SIGUSR1 signal to the main script
  kill -SIGUSR1 $MAIN_SCRIPT_PID
  echo "Signal sent to the main script (PID: $MAIN_SCRIPT_PID)"
else
  echo "Main script is not running."
fi
