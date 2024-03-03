#!/bin/bash

#
# Ping Subnet.sh
#

# This file is part of the UTILITIES package.

# TASK: You are developing a Bash script to ping every IP address
# within a specified subnet. The script should prompt the user to
# enter the upstream mask (e.g., 192.168.1.0/24) representing the
# subnet to be pinged. Utilize the fping command to efficiently ping
# each IP address within the subnet. Implement a user-friendly
# interface using Xdialog to prompt the user for input and display
# debug information. Ensure the script handles errors gracefully and
# provides clear feedback to the user.

# Ensure no command line arguments are provided
if [[ $# -gt 0 ]]; then
    echo "Error: This script does not accept command line arguments." >&2
    exit 1
fi

# Set Bash strict mode
set -euo pipefail

# Constants
DIALOG_TITLE="Enter Upstream Mask"
DIALOG_PROMPT="Enter the upstream mask (e.g., 192.168.1.0/24):"
DIALOG_HEIGHT=0
DIALOG_WIDTH=40
DEFAULT_UPSTREAM_MASK="192.168.1.0/24"

# Function to prompt the user to enter the upstream mask
prompt_user() {
    # Prompt the user to enter the upstream mask
    UPSTREAM_MASK=$(Xdialog --stdout --title "$DIALOG_TITLE" \
        --inputbox "$DIALOG_PROMPT" $DIALOG_HEIGHT $DIALOG_WIDTH "$DEFAULT_UPSTREAM_MASK")
}

# Function to ping each IP address in the specified subnet using fping
ping_subnet() {
    # Ping each IP address in the specified subnet
    fping -c 1 -g "${UPSTREAM_MASK}"
}

# Function to print debug information
print_debug_info() {
    echo "Debug Information:"
    echo "------------------"
    echo "Upstream Mask: $UPSTREAM_MASK"
}

# Main function
main() {
    prompt_user
    print_debug_info
    ping_subnet
}

# Call the main function
main
