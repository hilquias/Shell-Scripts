#!/bin/bash

#
# Run Loop.sh
#

# This script is part of the UTILITIES package.

# TASK: Create a Bash script that allows the user to select and
# execute multiple scripts from a specified directory.

set -euo pipefail
IFS=$'\n\t'

# Constants
readonly SCRIPTS_DIRECTORY="."
readonly SCRIPT_EXTENSION=".sh"
readonly DIALOG_TITLE="Select Scripts to Execute"
readonly DIALOG_HEIGHT=20
readonly DIALOG_WIDTH=80

# Function to retrieve script filenames
get_script_filenames() {
    scripts=()
    while IFS= read -r -d '' file; do
        scripts+=("$(basename "$file")" "$file" "off")
    done < <(find "$SCRIPTS_DIRECTORY" -maxdepth 1 -type f -name "*$SCRIPT_EXTENSION" -print0)
}

# Function to display a buildlist of script filenames
display_buildlist() {
    selected_scripts=$(Xdialog --separator="\n" --stdout --title "$DIALOG_TITLE" --buildlist "" $DIALOG_HEIGHT $DIALOG_WIDTH 0 "${scripts[@]}")
    if [[ -z "$selected_scripts" ]]; then
        echo "No scripts selected. Exiting."
        exit 0
    fi

    # Convert newline-separated string to array
    readarray -t selected_scripts_array <<<"$selected_scripts"

    # Debug output
    echo "Selected Scripts:"
    for selected_script in "${selected_scripts_array[@]}"; do
        echo "$selected_script"
    done

    while true; do
        # Execute selected scripts
        execute_scripts
        prompt_continue
    done
}

# Function to execute selected scripts
execute_scripts() {
    for selected_script in "${selected_scripts_array[@]}"; do
        script_path=$(find "$SCRIPTS_DIRECTORY" -type f -name "$selected_script")
        echo "Executing $selected_script..."
        "$script_path"
        echo "Script execution complete: $selected_script"
    done
}


# Function to prompt user to continue or exit
prompt_continue() {
    local choice
    Xdialog --title "Continue or Exit?" --yesno "Continue executing selected scripts?" 0 0
    choice=$?
    case $choice in
        0) # Yes, continue
            return ;;
        1) # No, exit
            echo "Exiting."
            exit 0 ;;
        255) # Esc or dialog closed
            echo "Dialog closed. Exiting."
            exit 0 ;;
    esac
}

# Main function
main() {
    get_script_filenames
    display_buildlist
}

# Call the main function to start the script execution
main
