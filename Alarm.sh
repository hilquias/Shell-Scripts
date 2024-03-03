#!/bin/bash

#
# Alarm.sh
#

# This file is part of the UTILITIES package.

# TASK: You are developing a Bash script to create a simple alarm
# utility. The script should prompt the user to set an alarm by
# entering the hour and minute. Upon setting the alarm, the script
# should wait until the specified time and then play an alarm sound
# effect. Additionally, display an on-screen message when the alarm
# goes off. Ensure the script handles invalid input gracefully and
# checks if the required dependencies are installed.

# Function to print debug information
print_debug_info() {
    echo "Debug Info:"
    echo "Current Time: $(date)"
    echo "Alarm Time: $hour:$minute"
    echo "Seconds until Alarm: $seconds"
}

# Ensure no command line arguments are provided
if [[ $# -gt 0 ]]; then
    echo "Error: This script does not accept command line arguments." >&2
    exit 1
fi

# Set Bash strict mode
set -euo pipefail

# Constants
ALARM_SFX="sfx/Alarm SFX.m4a"
HOURS_MAX=23
MINUTES_MAX=59
VOLUME_LEVEL=100
SLEEP_DURATION=1
OSD_CAT_COMMAND="osd_cat"
OSD_COLOR="green"
OSD_POSITION="bottom"
OSD_ALIGNMENT="right"
OSD_FONT="-*-iosevka slab-*-*-*-*-34-*-*-*-*-*-*-*"
INPUTBOX_WIDTH=20
INPUTBOX_HEIGHT=0

# Function to display an Xdialog prompt for setting the timer
set_timer() {
    # Prompt the user to enter the hour and minute for the alarm
    hour=$(Xdialog --stdout --title "Set Alarm" --inputbox "Enter the hour (00-$HOURS_MAX):" "$INPUTBOX_HEIGHT" "$INPUTBOX_WIDTH")
    minute=$(Xdialog --stdout --title "Set Alarm" --inputbox "Enter the minute (00-$MINUTES_MAX):" "$INPUTBOX_HEIGHT" "$INPUTBOX_WIDTH")

    # Validate input
    if ! [[ "$hour" =~ ^[0-9]+$ && "$minute" =~ ^[0-9]+$ && "$hour" -ge 0 && "$hour" -le $HOURS_MAX && "$minute" -ge 0 && "$minute" -le $MINUTES_MAX ]]; then
        echo "Invalid input. Please enter valid hour (0-$HOURS_MAX) and minute (0-$MINUTES_MAX)." >&2
        exit 1
    fi

    # Remove leading zeros
    hour=${hour#0}
    minute=${minute#0}

    seconds=$(date -d "$hour:$minute" +%s)

    if [ "$seconds" -lt 0 ]; then
        # If the alarm time is in the past, add 24 hours to seconds to get the time until the next occurrence
        seconds=$((seconds + 24 * 3600))
    fi

    local current_time
    current_time=$(date +%s)

    # Calculate the time difference
    seconds=$((seconds - current_time))
}

# Function to check if mpv is installed
check_mpv() {
    if ! command -v mpv &> /dev/null; then
        echo "Error: mpv is not installed. Please install it to play sound effects." >&2
        exit 1
    fi
}

# Function to play the alarm sound effect using mpv
play_alarm() {
    mpv --vo=null --volume="$VOLUME_LEVEL" "$ALARM_SFX"
}

# Function to wait until the alarm time
wait_until_alarm_time() {
    local remaining_seconds="$seconds"
    while (( remaining_seconds > 0 )); do
        display_alarm_message "$remaining_seconds"
        sleep "$SLEEP_DURATION"
        (( remaining_seconds-- ))
    done
}

# Function to display the alarm message
display_alarm_message() {
    local remaining_seconds="$1"
    local hours=$(( remaining_seconds / 3600 ))
    local minutes=$(( (remaining_seconds % 3600) / 60 ))
    local seconds=$(( remaining_seconds % 60 ))
    local message
    message="ALARM: $(printf "%02d:%02d:%02d" "$hours" "$minutes" "$seconds")"
    if command -v "$OSD_CAT_COMMAND" &>/dev/null; then
        echo "$message" | "$OSD_CAT_COMMAND" -c "$OSD_COLOR" -d "$SLEEP_DURATION" -p "$OSD_POSITION" -A "$OSD_ALIGNMENT" -l 1 -f "$OSD_FONT"
    else
        echo "$message"
    fi
}

# Main function
main() {
    set_timer
    check_mpv
    print_debug_info
    wait_until_alarm_time
    play_alarm
}

# Call the main function
main
