#!/bin/bash

#
# Timer.sh
#

# This file is part of the UTILITIES package.

# TASK: Create a Bash script for a timer utility that prompts the user
# to set a timer in seconds, plays an alarm sound effect when the
# timer expires, and displays a message indicating the expiration time
# on the screen.

# Ensure no command line arguments are provided
if [[ $# -gt 0 ]]; then
    echo "Error: This script does not accept command line arguments." >&2
    exit 1
fi

# Set Bash strict mode
set -euo pipefail

# Constants
ALARM_SFX="sfx/Alarm SFX.m4a"
SECONDS_MAX=3600
VOLUME_LEVEL=100
SLEEP_DURATION=1
OSD_CAT_COMMAND="osd_cat"
OSD_COLOR="green"
OSD_POSITION="bottom"
OSD_ALIGNMENT="right"
OSD_FONT="-*-iosevka slab-*-*-*-*-34-*-*-*-*-*-*-*"

# Function to display an Xdialog prompt for setting the timer
# This function prompts the user to enter the number of seconds to wait before the timer goes off.
# It validates the input and ensures the entered value is within the valid range.
set_timer() {
    # Prompt the user to enter the number of seconds to wait
    seconds=$(Xdialog --stdout --title "Set Timer" --inputbox "Enter the number of seconds to wait (1-$SECONDS_MAX):" 0 0)
    
    # Validate input
    if ! [[ "$seconds" =~ ^[0-9]+$ && "$seconds" -ge 1 && "$seconds" -le $SECONDS_MAX ]]; then
        echo "Invalid input. Please enter a valid number of seconds (1-$SECONDS_MAX)." >&2
        exit 1
    fi
}

# Function to check if mpv is installed
# This function checks if the mpv command is installed on the system.
check_mpv() {
    if ! command -v mpv &> /dev/null; then
        echo "Error: mpv is not installed. Please install it to play sound effects." >&2
        exit 1
    fi
}

# Function to play the alarm sound effect using mpv
# This function plays the alarm sound effect using mpv.
play_alarm() {
    mpv --vo=null --volume=$VOLUME_LEVEL "$ALARM_SFX"
}

# Function to wait until the alarm time
# This function waits for the specified number of seconds before triggering the alarm.
# It also displays the remaining time on the screen once per second.
wait_until_alarm_time() {
    local remaining_seconds="$seconds"
    while (( remaining_seconds > 0 )); do
        display_alarm_message "$remaining_seconds"
        sleep "$SLEEP_DURATION"
        (( remaining_seconds-- ))
    done
}

# Function to display the alarm message
# This function displays the alarm message on the screen.
display_alarm_message() {
    local remaining_seconds="$1"
    local hours=$(( remaining_seconds / 3600 ))
    local minutes=$(( (remaining_seconds % 3600) / 60 ))
    local seconds=$(( remaining_seconds % 60 ))
    local message
    message="TIMER: $(printf "%02d:%02d:%02d" "$hours" "$minutes" "$seconds")"
    if command -v "$OSD_CAT_COMMAND" &>/dev/null; then
        echo "$message" | "$OSD_CAT_COMMAND" -c "$OSD_COLOR" -d "$SLEEP_DURATION" -p "$OSD_POSITION" -A "$OSD_ALIGNMENT" -l 1 -f "$OSD_FONT"
    else
        echo "$message"
    fi
}

# Function to print debug information
# This function prints debug information such as the alarm time and remaining time.
print_debug_info() {
    echo "Debug Information:"
    echo "Alarm Sound Effect: $ALARM_SFX"
    echo "Seconds to Wait: $seconds"
}

# Main function
# This is the main entry point of the script.
main() {
    set_timer
    check_mpv
    print_debug_info
    wait_until_alarm_time
    play_alarm
}

# Call the main function
main
