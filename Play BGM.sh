#!/bin/bash

#
# Play BGM.sh
#

# This script is part of the UTILITIES package.

# TASK: You are tasked with creating a Bash script to play background
# music (BGM) files using the `mpv` media player. The script should
# provide a user-friendly interface using Xdialog to allow users to
# select a BGM file from a specified folder and adjust the volume
# level before playing. Implement error handling to handle cases where
# Xdialog or mpv is not installed or no BGM files are found. Ensure
# the script provides clear feedback to the user and allows for the
# cancellation of operations. Additionally, include debug information
# to display the selected BGM file and volume level before playing.


# Constants
readonly BGM_FOLDER="bgm"
readonly DIALOG_TITLE="Play Background Music"
readonly MPV_FLAGS="--vo=null"

# Function to print debug information
print_debug_info() {
    echo "Debug Information:"
    echo "------------------"
    echo "Selected BGM File: $selected_bgm"
    echo "Volume Level: $volume_level"
}

# Ensure no command line arguments are provided
if [[ $# -gt 0 ]]; then
    echo "Error: This script does not accept command line arguments." >&2
    exit 1
fi

# Set Bash strict mode
set -euo pipefail

# Check if Xdialog and mpv are installed
if ! command -v Xdialog &> /dev/null || ! command -v mpv &> /dev/null; then
    echo "Error: Xdialog or mpv is not installed. Please install them to run this script." >&2
    exit 1
fi

# Get a list of BGM files
bgm_files=("$BGM_FOLDER"/*)

# Check if there are any BGM files
if [ ${#bgm_files[@]} -eq 0 ]; then
    echo "Error: No BGM files found in the '$BGM_FOLDER' directory." >&2
    exit 1
fi

# Display a menu to select a BGM file
selected_bgm=$(Xdialog --stdout --title "$DIALOG_TITLE" --menubox "Select a background music file:" 20 80 "${bgm_files[@]}")

# Check if the user cancelled the selection
if [ -z "$selected_bgm" ]; then
    echo "User cancelled the operation."
    exit 0
fi

# Prompt the user to enter the volume level
volume_level=$(Xdialog --stdout --title "$DIALOG_TITLE" --inputbox "Enter the volume level (0-100):" 0 0 100)

# Validate the volume level input
if ! [[ "$volume_level" =~ ^[0-9]+$ ]] || [ "$volume_level" -lt 0 ] || [ "$volume_level" -gt 100 ]; then
    echo "Invalid input. Please enter a valid volume level (0-100)." >&2
    exit 1
fi

# Print debug information
print_debug_info

# Play the selected BGM file with the specified volume level using mpv
mpv --volume="$volume_level" $MPV_FLAGS "$selected_bgm"
