#!/bin/bash

#
# Random Text File.sh
#

# This script is part of the UTILITIES package.

# TASK: This Bash script randomly selects a text file from the "txt"
# directory (including subdirectories) and displays its contents in an
# Xdialog edit box.  The script provides a simple interface for users
# to view random text files and is designed to be executed within a
# desktop environment.

# Constants
readonly TXT_FOLDER="txt"
readonly DIALOG_WIDTH=80
readonly DIALOG_HEIGHT=20

# Function to print debug information
print_debug_info() {
    echo "Debug Information:"
    echo "------------------"
    echo "Selected Text File: $selected_txt"
}

# Ensure no command line arguments are provided
if [[ $# -gt 0 ]]; then
    echo "Error: This script does not accept command line arguments." >&2
    exit 1
fi

# Set Bash strict mode
set -euo pipefail

# Check if Xdialog is installed
if ! command -v Xdialog &> /dev/null; then
    echo "Error: Xdialog is not installed. Please install it to run this script." >&2
    exit 1
fi

# Get a list of text files
readarray -d '' txt_files < <(find "$TXT_FOLDER" -type f -name "*.txt" -print0)

# Check if there are any text files
if [ ${#txt_files[@]} -eq 0 ]; then
    echo "Error: No text files found in the '$TXT_FOLDER' directory." >&2
    exit 1
fi

# Select a random text file
selected_txt=${txt_files[$RANDOM % ${#txt_files[@]}]}

# Print debug information
print_debug_info

# Display the content of the selected text file in an Xdialog edit box
Xdialog --title "Random Text File" --editbox "$selected_txt" $DIALOG_HEIGHT $DIALOG_WIDTH
