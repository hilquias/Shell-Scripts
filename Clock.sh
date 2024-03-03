#!/bin/bash

#
# Clock.sh
#

# This file is part of the UTILITIES package.

# TASK: You are tasked with creating a Bash script for a clock utility
# that displays the current time and plays a sound effect at each
# whole hour. The script should continuously update the displayed time
# and play a bell sound effect corresponding to the current
# hour. Ensure the script handles errors gracefully, including
# checking for the existence of required sound effect files and the
# installation of necessary dependencies. Additionally, provide debug
# information to aid in troubleshooting.

# Ensure no command line arguments are provided
if [[ $# -gt 0 ]]; then
    echo "Error: This script does not accept command line arguments." >&2
    exit 1
fi

# Set Bash strict mode
# -e: Exit immediately if a command returns a non-zero status.
# -u: Treat unset variables as an error and exit immediately.
# -o pipefail: Causes a pipeline to return the exit status of the last command in the pipe that returned a non-zero status.
set -euo pipefail

# Constants
SFX_FILE="sfx/Clock Bell SFX.m4a"
DIALOG_TITLE="Clock"
DIALOG_WIDTH=10
DIALOG_HEIGHT=40
MPV_VOLUME=50

# Function to print debug information
print_debug_info() {
    echo "Debug Information:"
    echo "------------------"
    echo "Current Time: $(date)"
    echo "Remaining Seconds Until Next Whole Hour: $remaining_seconds"
    echo "SFX File: $SFX_FILE"
    echo "Dialog Title: $DIALOG_TITLE"
    echo "MPV Volume: $MPV_VOLUME"
}

# Function to calculate remaining seconds until the next whole hour
calculate_remaining_seconds() {
    # Calculate remaining seconds by subtracting current minutes from 60 and converting to seconds
    current_minute=$(date +%M)
    remaining_seconds=$(( (60 - current_minute) * 60 ))
}

# Function to update the clock display using Xdialog
update_clock_display() {
    # Display the current time in a dialog box with specified title, width, and height
    Xdialog --title "$DIALOG_TITLE" --infobox "Current Time: $(date +%H:%M)" $DIALOG_WIDTH $DIALOG_HEIGHT
}

# Function to play the SFX file N times using mpv
play_bell_sfx() {
    # Check if mpv is installed
    if ! command -v mpv &> /dev/null; then
        echo "Error: mpv is not installed. Please install it to play sound effects." >&2
        exit 1
    fi

    # Get the current hour without leading zeros
    current_hour=$(date +%H | sed 's/^0*//')

    # Check if the SFX file exists
    if [ ! -f "$SFX_FILE" ]; then
        echo "Error: SFX file '$SFX_FILE' not found." >&2
        exit 1
    fi

    # Play the SFX file N times, where N is the current whole hour
    for ((i = 1; i <= current_hour; i++)); do
        mpv --vo=null --volume=$MPV_VOLUME "$SFX_FILE"
    done
}

# Main loop to continuously update the clock at every whole hour
while true; do
    # Reset state at midnight to handle transition past midnight
    current_hour=$(date +%H)
    if [ "$current_hour" -eq 00 ]; then
        calculate_remaining_seconds
        sleep "$remaining_seconds"
        continue
    fi

    # Calculate remaining seconds until the next whole hour
    calculate_remaining_seconds

    # Print debug information
    print_debug_info

    # Update the clock display
    update_clock_display
    
    # Play the SFX file corresponding to the current hour
    play_bell_sfx

    # Sleep until the next whole hour
    sleep "$remaining_seconds"
done
