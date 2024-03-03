#!/bin/bash

#
# Clipboard Manager.sh
#

# This script is part of the UTILITIES package.

# TASK: You are developing a Bash script to create a clipboard manager
# utility. The script should allow users to view the current content
# of the clipboard and edit it if necessary. Upon editing, the script
# should update the clipboard with the edited content. The script
# should handle errors gracefully and provide a user-friendly
# interface for interacting with clipboard content. Ensure the script
# utilizes common clipboard utilities and a graphical interface
# library for user interaction.

# Constants
readonly DIALOG_WIDTH=80
readonly DIALOG_HEIGHT=20

# Function to copy text to clipboard
copy_to_clipboard() {
    local text="$1"
    echo -n "$text" | xclip -selection clipboard
}

# Function to display clipboard content and allow user to copy it
clipboard_manager() {
    # Get clipboard content
    local clipboard_content
    clipboard_content=$(xclip -o -selection clipboard)

    # Create a temporary file to store edited content
    local temp_file
    temp_file=$(mktemp)

    # Save clipboard content to the temporary file
    echo "$clipboard_content" > "$temp_file"

    # Display clipboard content in an editable text box
    if ! edited_content=$(Xdialog --title "Clipboard Manager" --editbox "$temp_file" $DIALOG_HEIGHT $DIALOG_WIDTH 2>&1); then
        echo "Error: Xdialog encountered an error."
        rm "$temp_file"
        exit 1
    fi

    # Check if the user clicked OK or Cancel
    if [[ -n "$edited_content" ]]; then
        copy_to_clipboard "$edited_content"
        echo "Content copied to clipboard."
    fi

    # Remove the temporary file
    rm "$temp_file"
}

# Main function
main() {
    clipboard_manager
}

# Start the script execution by calling the main function
main
