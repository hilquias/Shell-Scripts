#!/bin/bash

#
# View As Markdown.sh
#

# This script is part of the UTILITIES package.

# TASK: Create a Bash script that prompts the user to enter a URL,
# retrieves HTML content from the URL, converts it to Markdown using
# pandoc, and displays the converted Markdown content in an edit box
# using Xdialog.

# Constants
readonly DIALOG_WIDTH=160
readonly DIALOG_HEIGHT=60

# Function to convert HTML content to Markdown using pandoc
convert_to_markdown() {
    local url="$1"

    # Use pandoc to convert HTML content from the provided URL to Markdown
    local markdown_content
    markdown_content=$(pandoc -s -f html -t markdown "$url")

    # Check if conversion was successful
    if [ -z "$markdown_content" ]; then
        echo "Error: Failed to convert HTML content to Markdown." >&2
        exit 1
    fi

    echo "$markdown_content"
}

# Function to display Markdown content in an editbox
display_markdown_content() {
    local markdown_content="$1"
    local temp_file
    temp_file=$(mktemp)

    # Write Markdown content to a temporary file
    echo "$markdown_content" > "$temp_file"

    # Display the Markdown content in an editbox
    Xdialog --title "Markdown Content" --editbox "$temp_file" $DIALOG_HEIGHT $DIALOG_WIDTH

    # Remove the temporary file
    rm -f "$temp_file"
}

# Main function to orchestrate the workflow
main() {
    # Prompt user for URL input
    local url
    url=$(Xdialog --stdout --title "Enter URL" --inputbox "Enter the URL:" $DIALOG_HEIGHT $DIALOG_WIDTH)

    # Check if no URL is provided
    if [ -z "$url" ]; then
        echo "No URL provided. Exiting." >&2
        exit 1
    fi

    # Convert HTML content to Markdown
    local markdown_content
    markdown_content=$(convert_to_markdown "$url")

    # Display Markdown content
    display_markdown_content "$markdown_content"
}

# Start the script execution by calling the main function
main
