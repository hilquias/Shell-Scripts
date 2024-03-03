#!/bin/bash

#
# List System Units.sh
#

# This file is part of the UTILITIES package.

# TASK: You are developing a Bash script to list system units on a
# Linux system. The script should utilize the systemctl command to
# retrieve the list of units and display them in a user-friendly
# manner. Implement a loop that continuously displays the system units
# list in a dialog box using Xdialog. Ensure the script handles user
# cancellation gracefully. The script should have a simple interface
# and provide clear feedback to the user.

# Constants
readonly DIALOG_WIDTH=120
readonly DIALOG_HEIGHT=60

# Function to display system units list
display_system_units() {
    local units_content
    units_content=$(systemctl list-units --no-pager)

    # Display the units content in a text area
    Xdialog --title "System Units" --textbox - $DIALOG_HEIGHT $DIALOG_WIDTH <<< "$units_content"
    return $?
}

# Main function
main() {
    while true; do
        display_system_units

        # Check if user clicked "Cancel"
        if ! display_system_units; then
            echo "Exiting System List Units." >&2
            exit 0
        fi
    done
}

# Call the main function to start the script execution
main
