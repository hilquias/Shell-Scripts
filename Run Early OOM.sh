#!/bin/bash

#
# Run Early OOM.sh
#

# This script is part of the UTILITIES package.

# TASK: Create a Bash script that runs earlyoom using Xdialog.

# Constants
readonly DIALOG_TITLE="Early OOM"
readonly DIALOG_WIDTH=60
readonly DIALOG_HEIGHT=240

# Function to display early oom in real-time using Xdialog
show_early_oom() {
    # Display earlyoom output in real-time using Xdialog --tailbox
    earlyoom | Xdialog --title "$DIALOG_TITLE" --logbox - "$DIALOG_WIDTH" "$DIALOG_HEIGHT"
}

# Main function
main() {
    show_early_oom
}

# Call the main function
main
