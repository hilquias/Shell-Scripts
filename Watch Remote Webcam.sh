#!/bin/bash

#
# Watch Remote Webcam.sh
#

# This script is part of the UTILITIES package.

# TASK: Create a Bash script for watching a remote webcam stream. The
# script should prompt the user to enter the MAC address of the remote
# camera, find the corresponding IP address, prompt the user to enter
# connection details, and then connect to and display the video stream
# using mpv.

# Source environment constants
source .env

# Constants
readonly DIALOG_WIDTH=20
readonly DIALOG_HEIGHT=100

# Default connection details
UPSTREAM_USER=""
UPSTREAM_PASS=""
UPSTREAM_PORT="8554"
UPSTREAM_PATH="cam"
UPSTREAM_MAC="$REMOTE_WEBCAM"

# Function to prompt user to enter the MAC address of the remote camera
input_mac_address() {
    UPSTREAM_MAC=$(Xdialog --stdout --title "Enter MAC Address" \
        --inputbox "Enter the MAC address of the remote camera:" $DIALOG_WIDTH $DIALOG_HEIGHT "$UPSTREAM_MAC")
    
    if [ -z "$UPSTREAM_MAC" ]; then
        echo "No MAC address entered. Exiting."
        exit 1
    fi
}

# Function to find the IP address corresponding to the entered MAC address
find_upstream_host() {
    UPSTREAM_HOST=$(arp -n | grep -i "${UPSTREAM_MAC}" | cut -d ' ' -f 1 | tail -n 1)
    
    if [ -z "$UPSTREAM_HOST" ]; then
        echo "UPSTREAM HOST NOT FOUND"
        exit 1
    fi

    echo "UPSTREAM HOST FOUND: $UPSTREAM_HOST"
}

# Function to prompt user to enter connection details
input_connection_details() {
    while true; do
        INPUT=$(Xdialog --stdout --title "Enter Connection Details" \
            --inputbox "UPSTREAM_USER:" $DIALOG_WIDTH $DIALOG_HEIGHT "$UPSTREAM_USER" \
            --passwordbox "UPSTREAM_PASS:" $DIALOG_WIDTH $DIALOG_HEIGHT "$UPSTREAM_PASS" \
            --inputbox "UPSTREAM_PORT:" $DIALOG_WIDTH $DIALOG_HEIGHT "$UPSTREAM_PORT" \
            --inputbox "UPSTREAM_PATH:" $DIALOG_WIDTH $DIALOG_HEIGHT "$UPSTREAM_PATH")

        if [ $? -ne 0 ]; then
            break
        fi

        UPSTREAM_USER=$(echo "$INPUT" | awk 'NR==1{print $NF}')
        UPSTREAM_PASS=$(echo "$INPUT" | awk 'NR==2{print $NF}')
        UPSTREAM_PORT=$(echo "$INPUT" | awk 'NR==3{print $NF}')
        UPSTREAM_PATH=$(echo "$INPUT" | awk 'NR==4{print $NF}')

        # Assemble UPSTREAM_RTSP variable
        if [ -z "$UPSTREAM_USER" ] && [ -z "$UPSTREAM_PASS" ]; then
            UPSTREAM_RTSP="rtsp://$UPSTREAM_HOST:$UPSTREAM_PORT/$UPSTREAM_PATH"
        else
            UPSTREAM_RTSP="rtsp://$UPSTREAM_USER:$UPSTREAM_PASS@$UPSTREAM_HOST:$UPSTREAM_PORT/$UPSTREAM_PATH"
        fi

        # Connect and display video stream using mpv
        mpv --rtsp-transport=udp --profile=low-latency --cache=yes --untimed --no-demuxer-thread --force-seekable=yes --hr-seek=yes --hr-seek-framedrop=yes "$UPSTREAM_RTSP"

        # Check if the user wants to edit the fields again or exit
        if [ $? -eq 0 ]; then
            break
        fi
    done
}

main() {
    input_mac_address
    find_upstream_host
    input_connection_details
}

# Call the main function
main
