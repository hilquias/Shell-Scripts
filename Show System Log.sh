#!/bin/bash

#
# Show System Logs.sh
#

# This script is part of the UTILITIES package.

# TASK: Create a Bash script that displays system logs in real-time
# using Xdialog.

# Constants
readonly DIALOG_TITLE="System Logs"
readonly DIALOG_WIDTH=60
readonly DIALOG_HEIGHT=240

# Function to display system logs in real-time using Xdialog
show_system_logs() {
    # Display system logs in real-time using Xdialog --tailbox
    pkexec journalctl --no-pager -f | Xdialog --title "$DIALOG_TITLE" --logbox - "$DIALOG_WIDTH" "$DIALOG_HEIGHT"
}

# Main function
main() {
    show_system_logs
}

# Call the main function
main
