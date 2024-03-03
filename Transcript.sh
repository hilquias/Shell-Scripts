#!/bin/bash

#
# Transcript.sh
#

# This script is part of the UTILITIES package.

# TASK: Create a Bash script for generating a transcript of commands
# and their outputs. The script should prompt the user to input text
# using Xdialog, execute the input as a command, capture the output,
# and display both the input and output in a transcript using Xdialog.

# Constants
readonly PROMPT_WIDTH=60
readonly PROMPT_HEIGHT=10
readonly TRANSCRIPT_WIDTH=80
readonly TRANSCRIPT_HEIGHT=20

TRANSCRIPT_FILE=$(mktemp)
COMMAND_FILE=$(mktemp)

# Function to display the Prompt dialog
display_prompt() {
    # Prompt the user to input text using a text field dialog
    local prompt_text
    prompt_text=$(Xdialog --stdout --title "Prompt" --inputbox "Enter text:" $PROMPT_HEIGHT $PROMPT_WIDTH 2>&1)

    # Debug: Print the prompt text before evaluation
    echo "Debug: Prompt text before evaluation: $prompt_text"

    # Check if the user canceled or closed the dialog
    if [ -z "$prompt_text" ]; then
        echo "User canceled. Exiting." >&2
        cleanup_and_exit 1
    fi

    # Write the prompt text to the command file
    echo "$prompt_text" > "$COMMAND_FILE"
}

# Function to execute the command from the file and append the output to the transcript
execute_command() {
    # Execute the command file and append the output to the transcript file
    bash "$COMMAND_FILE" >> "$TRANSCRIPT_FILE" 2>&1
}

# Function to display the Transcript dialog
display_transcript() {
    # Display the transcript content in an edit box without buttons
    Xdialog --title "Transcript" --editbox "$TRANSCRIPT_FILE" $TRANSCRIPT_HEIGHT $TRANSCRIPT_WIDTH
}

# Function to clean up and exit
cleanup_and_exit() {
    # Clean up temporary files
    rm -f "$TRANSCRIPT_FILE" "$COMMAND_FILE"
    exit "$1"
}

# Main function to orchestrate the workflow
main() {
    while true; do
        # Display Prompt dialog
        display_prompt || cleanup_and_exit 1
        
        # Execute the command from the file
        execute_command
        
        # Display Transcript dialog
        display_transcript || cleanup_and_exit 1
    done
}

# Check if Xdialog is available
if ! command -v Xdialog &> /dev/null; then
    echo "Error: Xdialog is not installed. Please install it to run this script." >&2
    exit 1
fi

# Start the script execution by calling the main function
main
