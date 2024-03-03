#!/bin/bash

#
# System Status.sh
#

# This script is part of the UTILITIES package.

# TASK: Create a Bash script that continuously displays the system
# status using systemctl status command in a dialog box, allowing the
# user to exit when desired.

# Constants
readonly DIALOG_WIDTH=120
readonly DIALOG_HEIGHT=60

# Function to display system status
display_system_status() {
    local status_content
    status_content=$(systemctl status --no-pager)

    # Display the status content in a text area
    Xdialog --title "System Status" --textbox - $DIALOG_HEIGHT $DIALOG_WIDTH <<< "$status_content"
}

# Main function
main() {
    while true; do
        display_system_status

        # Check if user clicked "Cancel"
        if [ $? -ne 0 ]; then
            echo "Exiting System Status." >&2
            exit 0
        fi
    done
}

# Call the main function to start the script execution
main
