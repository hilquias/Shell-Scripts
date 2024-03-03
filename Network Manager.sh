#!/bin/bash

#
# Network Manager.sh
#

# This file is part of the UTILITIES package.

# TASK: You are tasked with creating a Bash script to manage network
# interfaces on a Linux system. The script should provide
# functionality to start and stop networking on a specified network
# interface. Additionally, it should display the current network
# status (online or offline) and the ping time to a test IP address
# (e.g., 8.8.8.8). Implement a user-friendly interface using Xdialog
# to allow users to start or stop networking and view network
# status. Ensure the script handles errors gracefully and allows users
# to specify the network card. The script should continuously monitor
# the network status and provide real-time updates to the user
# interface.

# Constants
DIALOG_TITLE="Network Manager"
DIALOG_WIDTH=70
DIALOG_HEIGHT=20
DEFAULT_NETWORK_CARD="enp3s0"
TEST_IP="8.8.8.8"

# Function to check if the network interface is online
check_network_status() {
    if ping -c 1 -W 1 "$TEST_IP" &> /dev/null; then
        NETWORK_STATUS="Online"
    else
        NETWORK_STATUS="Offline"
    fi
}

# Function to bring up the network interface
start_networking() {
    if ! pkexec ip link set "$NETWORK_CARD" up; then
        echo "Error: Failed to start networking."
        exit 1
    fi
}

# Function to bring down the network interface
stop_networking() {
    if ! pkexec ip link set "$NETWORK_CARD" down; then
        echo "Error: Failed to stop networking."
        exit 1
    fi
}

# Function to display network status and ping time
display_network_info() {
    check_network_status
    PING_TIME=$(ping -c 1 -W 1 "$TEST_IP" | grep 'time=' | awk '{print $7}' | cut -d '=' -f 2)
    if [ "$NETWORK_STATUS" == "Online" ]; then
        DIALOG_TEXT="Network Status: $NETWORK_STATUS\nPing Time to $TEST_IP: $PING_TIME ms"
        DIALOG_BUTTON="Stop Networking"
        ACTION="stop_networking"
    else
        DIALOG_TEXT="Network Status: $NETWORK_STATUS\nCannot ping $TEST_IP"
        DIALOG_BUTTON="Start Networking"
        ACTION="start_networking"
    fi
}

# Function to display Xdialog with network information and buttons
show_dialog() {
    display_network_info

    Xdialog --stdout --title "$DIALOG_TITLE" \
        --ok-label "$DIALOG_BUTTON" --cancel-label "Close" \
        --yesno "$DIALOG_TEXT" $DIALOG_HEIGHT $DIALOG_WIDTH

    CHOICE=$?

    if [ "$CHOICE" == "0" ]; then
        $ACTION
        display_network_info
    elif [ "$CHOICE" == "1" ]; then
        exit 0
    fi
}

# Main function
main() {
    NETWORK_CARD=$(Xdialog --stdout --title "$DIALOG_TITLE" \
        --inputbox "Enter the network card (default: $DEFAULT_NETWORK_CARD):" $DIALOG_HEIGHT $DIALOG_WIDTH "$DEFAULT_NETWORK_CARD")

    while true; do
        show_dialog
    done
}

# Call the main function
main
