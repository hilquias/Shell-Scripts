#!/bin/bash

#
# Sanitize Prompt.sh
#

# This script is part of the UTILITIES package.

# TASK: Create a Bash script that prompts the user to enter a string,
# sanitizes it based on predefined rules, and displays the sanitized
# string.

# Constants
readonly DIALOG_WIDTH=160
readonly DIALOG_HEIGHT=60

# Function to prompt user to enter a string
prompt_string() {
    # Prompt the user to enter a string using an editbox
    local input_string
    input_string=$(Xdialog --stdout --title "Enter String" --editbox "" $DIALOG_HEIGHT $DIALOG_WIDTH)

    # Check if no string is entered
    if [ -z "$input_string" ]; then
        echo "No string entered. Exiting." >&2
        exit 1
    fi

    # Display the sanitized input string
    display_sanitized_string "$input_string"
}

# Function to sanitize the input string
sanitize_string() {
    local string="$1"

    # Sanitization for UPSTREAM_MAC
    string=$(awk '/^(readonly )?UPSTREAM_MAC/{gsub(/=.*/, "=\"\"")}1' <<< "$string")

    # Sanitization for UPSTREAM_ADDR_1
    string=$(awk '/^(readonly )?UPSTREAM_ADDR_1/{gsub(/=.*/, "=\"\"")}1' <<< "$string")

    # Sanitization for UPSTREAM_ADDR_2
    string=$(awk '/^(readonly )?UPSTREAM_ADDR_2/{gsub(/=.*/, "=\"\"")}1' <<< "$string")

    # Sanitization for UPSTREAM_ADDR_3
    string=$(awk '/^(readonly )?UPSTREAM_ADDR_3/{gsub(/=.*/, "=\"\"")}1' <<< "$string")

    # Sanitization for UPSTREAM_USER
    string=$(awk '/^(readonly )?UPSTREAM_USER/{gsub(/=.*/, "=\"\"")}1' <<< "$string")

    # Sanitization for UPSTREAM_PASS
    string=$(awk '/^(readonly )?UPSTREAM_PASS/{gsub(/=.*/, "=\"\"")}1' <<< "$string")

    # Sanitization for UPSTREAM_PORT
    string=$(awk '/^(readonly )?UPSTREAM_PORT/{gsub(/=.*/, "=\"\"")}1' <<< "$string")

    # Sanitization for UPSTREAM_PATH
    string=$(awk '/^(readonly )?UPSTREAM_PATH/{gsub(/=.*/, "=\"\"")}1' <<< "$string")

    echo "$string"
}

# Function to display the sanitized string
display_sanitized_string() {
    local input_string="$1"

    # Call the function to sanitize the input string
    local sanitized_string
    sanitized_string=$(sanitize_string "$input_string")
    
    # Display the sanitized string in an editbox
    Xdialog --title "Sanitized String" --editbox <(echo "$sanitized_string") $DIALOG_HEIGHT $DIALOG_WIDTH
}

main() {
    # Call the function to prompt user to enter a string
    prompt_string
}

# Call the main function to start the script execution
main
