#!/bin/bash

#
# Pretty Json.sh
#

# This script is part of the UTILITIES package.

# TASK: You are tasked with creating a Bash script to prettify JSON
# strings provided by users. The script should utilize Xdialog to
# prompt users to input a JSON string and display the prettified JSON
# in an easily readable format. Implement error handling to gracefully
# handle cases where users cancel the input dialog. Ensure the script
# is user-friendly and provides clear feedback.

# Constants
readonly DIALOG_WIDTH=120
readonly DIALOG_HEIGHT=60

# Function to prompt user to input a JSON string
input_json() {
    # Prompt the user to input a JSON string using a text editor dialog
    local json_input
    json_input=$(Xdialog --stdout --title "Enter JSON" --editbox "" $DIALOG_HEIGHT $DIALOG_WIDTH)

    # Check if the user canceled or closed the dialog
    if [ -z "$json_input" ]; then
        echo "JSON input canceled. Exiting." >&2
        exit 1
    fi

    echo "$json_input"
}

# Function to prettify and display the JSON
prettify_json() {
    local json="$1"
    local prettified_json

    # Prettify JSON using Python's built-in json.tool
    prettified_json=$(echo "$json" | python3 -m json.tool)

    # Display the prettified JSON in an editbox
    Xdialog --title "Prettified JSON" --editbox <(echo "$prettified_json") $DIALOG_HEIGHT $DIALOG_WIDTH
}

# Main function to orchestrate the workflow
main() {
    # Prompt user for JSON input
    local json_input
    json_input=$(input_json)

    # Prettify and display the JSON
    prettify_json "$json_input"
}

# Start the script execution by calling the main function
main
