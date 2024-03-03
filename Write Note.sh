#!/bin/bash

#
# Write Note.sh
#

# This script is part of the UTILITIES package.

# TASK: Create a Bash script for writing and saving notes. The script
# should prompt the user to write a note using a text editor dialog,
# then ask the user to specify a filename for the note and save it to
# a file on the desktop.

# Constants
readonly DIALOG_WIDTH=120
readonly DIALOG_HEIGHT=60

# Function to prompt user to write a note and save it to a file
write_note() {
    # Prompt the user to write a note using a text editor dialog
    local note_content
    note_content=$(Xdialog --stdout --title "Write Note" --editbox "" $DIALOG_HEIGHT $DIALOG_WIDTH)

    # Check if the user canceled or closed the dialog
    if [ -z "$note_content" ]; then
        echo "Note writing canceled. Exiting." >&2
        exit 1
    fi

    # Prompt the user to specify a filename for the note
    local filename
    filename=$(Xdialog --stdout --title "Save Note As" --inputbox "Enter filename for the note:" 0 0)

    # Check if the user canceled or closed the dialog
    if [ -z "$filename" ]; then
        echo "Note saving canceled. Exiting." >&2
        exit 1
    fi

    # Save the note content to a file on the desktop
    local desktop_path="$HOME/Desktop"
    local filepath="$desktop_path/$filename"

    echo "$note_content" > "$filepath"
    echo "Note saved as $filename on the desktop."
}

main() {
    # Call the function to write and save a note
    write_note
}

# Call the main function to start the script execution
main
