#!/bin/bash

#
# Write Log.sh
#

# This script is part of the UTILITIES package.

# TASK: Create a Bash script for logging tasks and their rates into a
# CSV file. The script should prompt the user to enter a task and its
# rate, append this information to a log file named with the current
# date, and rotate log files to ensure that there are no more than a
# specified maximum number of log files in the log directory.

# Constants
readonly DIALOG_WIDTH=40
readonly DIALOG_HEIGHT=20
readonly LOG_DIR="log"
readonly MAX_LOG_FILES=10

# Function to prompt user to enter a TASK and RATE
prompt_task_and_rate() {
    # Prompt the user to enter a TASK
    local task
    task=$(Xdialog --stdout --title "Enter Task" --inputbox "Enter the TASK:" $DIALOG_HEIGHT $DIALOG_WIDTH)

    # Check if the user canceled or closed the dialog
    if [ -z "$task" ]; then
        echo "Task input canceled. Exiting." >&2
        exit 1
    fi

    # Prompt the user to enter a RATE
    local rate
    rate=$(Xdialog --stdout --title "Enter Rate" --inputbox "Enter the RATE:" $DIALOG_HEIGHT $DIALOG_WIDTH)

    # Check if the user canceled or closed the dialog
    if [ -z "$rate" ]; then
        echo "Rate input canceled. Exiting." >&2
        exit 1
    fi

    # Assemble the CSV line
    LINE="${task},${rate}"
}

# Function to append the line to the log file
append_to_log() {
    # Create log directory if it doesn't exist
    mkdir -p "$LOG_DIR"

    # Generate log file name based on date
    LOGFILE="${LOG_DIR}/log_$(date +%Y%m%d).csv"

    # Append the line to the log file
    echo "$LINE" >> "$LOGFILE"

    # Rotate log files
    rotate_logs
}

# Function to rotate log files
rotate_logs() {
    # Get the number of log files
    num_logs=$(ls -1 "$LOG_DIR" | wc -l)

    # If the number of log files exceeds the maximum, remove the oldest
    if [ "$num_logs" -gt "$MAX_LOG_FILES" ]; then
        oldest_log=$(ls -t "$LOG_DIR" | tail -n 1)
        rm "$LOG_DIR/$oldest_log"
    fi
}

main() {
    # Call the function to prompt user for task and rate
    prompt_task_and_rate

    # Append the line to the log file
    append_to_log

    # Debug message
    echo "Task and rate appended to log file."
}

# Call the main function to start the script execution
main
