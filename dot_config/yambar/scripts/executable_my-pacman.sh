#!/usr/bin/env bash
#
# pacman.sh - display number of packages update available
#             by default check every hour
#
# USAGE: pacman.sh
#
# TAGS:
#  Name      Type  Return
#  -------------------------------------------
#  {pacman}  int   number of pacman packages
#  {aur}     int   number of aur packages
#  {pkg}     int   sum of both
#
# Examples configuration:
#  - script:
#      path: /absolute/path/to/pacman.sh
#      args: []
#      content: { string: { text: "{pacman} + {aur} = {pkg}" } }
#
# To display a message when there is no update:
#  - script:
#      path: /absolute/path/to/pacman.sh
#      args: []
#      content:
#        map:
#          default: { string: { text: "{pacman} + {aur} = {pkg}" } }
#          conditions:
#            pkg == 0: {string: {text: no updates}}


# Error message in STDERR
_err() {
  printf -- '%s\n' "[$(date +'%Y-%m-%d %H:%M:%S')]: $*" >&2
}

# Display initial tags before yambar fetches the updates number
printf -- '%s\n' "pacman|int|0"
printf -- '%s\n' "aur|int|0"
printf -- '%s\n' "pkg|int|0"
printf -- '%s\n' ""

# Signal handler function
signal_handler() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')]: Signal received, rerunning the script..." >&2
  kill "$SLEEP_PID" 2>/dev/null
}

# Function to run the script logic once
run_once() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')]: Running update check..." >&2

  # Change interval
  # NUMBER[SUFFIXE]
  # Possible suffix:
  #  "s" seconds / "m" minutes / "h" hours / "d" days
  interval="10m"

  # Change your AUR manager
  aur_helper="paru"

  # Get number of packages to update
  pacman_num=$(checkupdates | wc -l)

  if ! hash "${aur_helper}" >/dev/null 2>&1; then
    _err "AUR helper not found, change it in the script"
    exit 1
  else
    aur_num=$("${aur_helper}" -Qmu | wc -l)
  fi

  pkg_num=$(( pacman_num + aur_num ))

  printf -- '%s\n' "pacman|int|${pacman_num}"
  printf -- '%s\n' "aur|int|${aur_num}"
  printf -- '%s\n' "pkg|int|${pkg_num}"
  printf -- '%s\n' ""
}

# Main function to handle the interval sleep and signal trap
run() {
  while true; do
    run_once
    sleep "${interval}" &  # Run sleep in the background
    SLEEP_PID=$!
    wait $SLEEP_PID  # Wait for the sleep to finish or be interrupted
  done
}

# Set up the trap to catch SIGUSR1 and call signal_handler
trap 'signal_handler' SIGUSR1

# Initial run before entering the loop
run

unset -v interval aur_helper pacman_num aur_num pkg_num SLEEP_PID
unset -f _err signal_handler run run_once
