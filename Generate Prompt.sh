#!/bin/bash

set -euo pipefail

#
# Generate Prompt.sh
#

# This file is part of the UTILITIES package.

# TASK: You are developing a Bash script to generate a prompt document
# for a coding task. The script should prompt the user to choose
# reference files and example files from the project directory. It
# should then allow the user to edit the prompt text, incorporating
# specific guidelines and instructions for the task. The generated
# document should include the content of the selected reference and
# example files, along with the edited prompt text. Ensure that the
# script sanitizes sensitive information in the reference and example
# files before displaying the final output. Provide a user-friendly
# interface for selecting files and editing the prompt text.

# Constants
readonly DIALOG_WIDTH=160
readonly DIALOG_HEIGHT=60

# Assign values to variables
TEMP_REFERENCE=$(mktemp)
TEMP_EXAMPLE=$(mktemp)
TEMP_PROMPT=$(mktemp)
TEMP_OUTPUT=$(mktemp)

# Function to prompt user to choose reference files
choose_reference_files() {
    local reference_files=(doc/*)  # Get all markdown files in doc folder
    local choices=()
    local dialog_width=80
    local dialog_height=20
    for file in "${reference_files[@]}"; do
        choices+=( "$file" "" "on" )  # Add them as choices with initial state on
    done

    Xdialog --stdout --title "Choose Reference Files" --separator "\n" --checklist "Select reference files:" "$dialog_height" "$dialog_width" $((dialog_height - 2)) "${choices[@]}" > "$TEMP_REFERENCE"
}

# Function to prompt user to choose example files
choose_example_files() {
    local example_files=( *.sh )
    local choices=()
    local dialog_width=120
    local dialog_height=30
    for file in "${example_files[@]}"; do
        choices+=( "$file" "" off )
    done

    Xdialog --stdout --title "Choose Example Files" --separator "\n" --checklist "Select example files:" "$dialog_height" "$dialog_width" $((dialog_height - 2)) "${choices[@]}" > "$TEMP_EXAMPLE"
}

# Function to prompt user to edit the prompt text
edit_prompt() {
    local prompt_content
    local dialog_width=100
    local dialog_height=40
    prompt_content=$(Xdialog --stdout --title "Edit Prompt" --editbox - "$dialog_height" "$dialog_width" <<EOF
Write 'Hello World.sh'.

1. Follow the conventions in the style guide and the given examples.
2. The program must be based in Xdialog and all terminal output must be only for debug purposes.
3. Do not forget to write the TASK commentary section. Word it carefully to reflect what the script actually does.

EOF
)
    echo "$prompt_content" > "$TEMP_PROMPT"
}

# Function to assemble final output
assemble_final_output() {
    {
        # Add reference files content
        while IFS= read -r ref_file; do
            echo "$ref_file:"
            echo ""
            echo '```'
            cat "$ref_file"
            echo '```'
            echo ""
        done < "$TEMP_REFERENCE"

        # Add example files content
        while IFS= read -r ex_file; do
            echo "$ex_file:"
            echo ""
            echo '```'
            cat "$ex_file"
            echo '```'
            echo ""
        done < "$TEMP_EXAMPLE"

        # Add user-defined prompt content
        echo ""
        echo -n "TASK: "
        cat "$TEMP_PROMPT"
    } > "$TEMP_OUTPUT"
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

# Function to display the final output after sanitizing it
show_final_output() {
    # Sanitize the content of the temporary output file
    sanitized_output=$(sanitize_string "$(cat "$TEMP_OUTPUT")")

    # Display the sanitized final output using Xdialog
    echo "$sanitized_output" | Xdialog --title "Final Output" --textbox - "$DIALOG_HEIGHT" "$DIALOG_WIDTH"
}

# Main function
main() {
    choose_reference_files
    choose_example_files
    edit_prompt
    assemble_final_output

    # Display the final output in the console
    cat "$TEMP_OUTPUT"

    # Display the final output using Xdialog
    show_final_output

    # Clean up temporary files
    rm "$TEMP_REFERENCE" "$TEMP_EXAMPLE" "$TEMP_PROMPT" "$TEMP_OUTPUT"
}

# Call the main function to start the script execution
main
