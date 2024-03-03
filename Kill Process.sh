#!/bin/bash

#
# Kill Process.sh
#

# This file is part of the UTILITIES package.

# TASK: You are developing a Bash script to create a process
# termination utility. The script should prompt the user to input a
# regular expression to search for processes. It should then search
# for processes matching the provided regular expression and display
# them in a menu box. The user should be able to select a process from
# the menu and confirm its termination. Upon confirmation, the script
# should terminate the selected process using the SIGKILL signal and
# display a confirmation message. Additionally, display a notification
# using OSD (On-Screen Display) indicating the termination of the
# process. Ensure the script handles cancellation gracefully.

# Constants
TITLE="Kill Process"
DIALOG_WIDTH=220
DIALOG_HEIGHT=60
FONT="-*-iosevka slab-*-*-*-*-34-*-*-*-*-*-*-*"
SHADOW=2
OUTLINE=1
DELAY=2

# Function to display an Xdialog prompt for entering the regular expression
get_regular_expression() {
    REGULAR_EXPRESSION=$(Xdialog --stdout --title "$TITLE" --inputbox "Enter a regular expression to search for processes:" 0 0)
    if [ -z "$REGULAR_EXPRESSION" ]; then
        echo "Operation canceled. Exiting." >&2
        exit 0
    fi
}

# Function to search for processes matching the regular expression and display them in a menu box
search_and_display_processes() {
    processes=$(pgrep -f -a "$REGULAR_EXPRESSION")
    if [ -z "$processes" ]; then
        echo "No processes found matching the regular expression: $REGULAR_EXPRESSION" >&2
        exit 0
    fi
    local menu_items=()
    while IFS= read -r process_line; do
        process_id=$(echo "$process_line" | awk '{print $1}')
        command_with_args=$(echo "$process_line" | awk '{$1=""; print $0}')
        menu_items+=("$process_id" "$command_with_args")
    done <<< "$processes"
    local selected_process
    selected_process=$(Xdialog --stdout --title "$TITLE" --menu "Select a process to terminate:" "$DIALOG_HEIGHT" "$DIALOG_WIDTH" 0 "${menu_items[@]}")
    if [ -z "$selected_process" ]; then
        echo "Operation canceled. Exiting." >&2
        exit 0
    fi
    confirm_termination "$selected_process"
}

# Function to confirm the termination of the selected process
confirm_termination() {
    local selected_process="$1"
    local confirmation_message="Are you sure you want to terminate the following process?\n\n$selected_process"
    if Xdialog --stdout --title "$TITLE" --yesno "$confirmation_message" 0 0; then
        echo "Terminating process: $selected_process"
        kill_pid=$(echo "$selected_process" | awk '{print $1}')
        kill -s SIGKILL "$kill_pid"
        echo "Process terminated successfully."
        osd_cat --color=red --align=center --font="$FONT" --shadow="$SHADOW" --outline="$OUTLINE" --delay="$DELAY" <<< "KILLED $kill_pid"
    else
        echo "Termination canceled by user. Exiting." >&2
    fi
}

# Main function
main() {
    get_regular_expression
    search_and_display_processes
}

# Call the main function
main
