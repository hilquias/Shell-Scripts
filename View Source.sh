#!/bin/bash

#
# View Source.sh
#

# This script is part of the UTILITIES package.

# TASK: Create a Bash script that prompts the user to select a shell
# script file using Xdialog and then displays the contents of the
# selected file in a text box.

# Constants
readonly DIALOG_WIDTH=30
readonly DIALOG_HEIGHT=80

# Function to prompt user to select a shell script file
select_shell_file() {
    # Prompt the user to select a shell script file using a file selector dialog
    local selected_file
    selected_file=$(Xdialog --stdout --title "Select Shell Script File" --fselect "$PWD" $DIALOG_WIDTH $DIALOG_HEIGHT)

    # Check if no file is selected
    if [ -z "$selected_file" ]; then
        echo "No file selected. Exiting." >&2
        exit 1
    fi

    # Display the contents of the selected file
    display_file_content "$selected_file"
}

# Function to display the contents of the selected file
display_file_content() {
    local file="$1"
    
    # Check if the selected file is a valid file
    if [ ! -f "$file" ]; then
        echo "Error: $file is not a valid file." >&2
        exit 1
    fi

    # Display the sanitized file content in a text box
    Xdialog --title "File Content: $file" --textbox "$file" $DIALOG_WIDTH $DIALOG_HEIGHT
}

main() {
    # Call the function to select a shell script file
    select_shell_file
}

# Call the main function to start the script execution
main
