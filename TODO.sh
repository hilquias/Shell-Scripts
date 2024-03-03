#!/bin/bash

#
# TODO.sh
#

# This script is part of the UTILITIES package.

# TASK: Create a Bash script for managing a TODO list. The script
# should allow the user to open and edit a TODO file in an editable
# text box, and save any changes made to the file.

# Constants
readonly DIALOG_WIDTH=120
readonly DIALOG_HEIGHT=60
readonly TODO_FILE="$HOME/Desktop/TODO.txt"

# Function to open and edit the TODO file
edit_todo() {
    # Check if TODO file exists, create if not
    if [ ! -f "$TODO_FILE" ]; then
        touch "$TODO_FILE"
    fi

    # Open TODO file in an editable text box
    edited_content=$(Xdialog --stdout --title "TODO Editor" --editbox "$TODO_FILE" $DIALOG_HEIGHT $DIALOG_WIDTH)

    # Check if user clicked "Cancel"
    if [ $? -ne 0 ]; then
        echo "Editing canceled. Exiting."
        exit 1
    fi

    # Save edited content back to TODO file
    echo "$edited_content" > "$TODO_FILE"
    echo "Changes saved to TODO.txt."
}

# Main function
main() {
    while true; do
        edit_todo
    done
}

# Start the script execution by calling the main function
main
