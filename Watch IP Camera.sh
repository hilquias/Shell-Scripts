#!/bin/bash

#
# Watch IP Camera.sh
#

# This script is part of the UTILITIES package.

# TASK: Create a Bash script for watching an IP camera stream. The
# script should prompt the user to choose from available camera
# sources, find the corresponding IP address, prompt the user to enter
# connection details, and then connect to and display the video stream
# using mpv.

# Source environment constants
source .env

# Constants
readonly DIALOG_WIDTH=20
readonly DIALOG_HEIGHT=100
readonly MPV_VOLUME=50

# Function to prompt user to choose upstream address
select_upstream_addr() {
    UPSTREAM_ADDR=$(Xdialog --stdout --title "Choose UPSTREAM_ADDR" \
        --radiolist "Choose UPSTREAM_ADDR:" $DIALOG_WIDTH $DIALOG_HEIGHT 3 \
        "${UPSTREAM_ADDR_1}" "Camera 1" on \
        "${UPSTREAM_ADDR_2}" "Camera 2" off \
        "${UPSTREAM_ADDR_3}" "Camera 3" off)
    
    if [ -z "$UPSTREAM_ADDR" ]; then
        echo "No UPSTREAM_ADDR selected. Exiting."
        exit 1
    fi
}

# Function to find the IP address corresponding to the selected MAC address
find_upstream_host() {
    UPSTREAM_HOST=$(arp -n | grep -i "${UPSTREAM_ADDR}" | cut -d ' ' -f 1 | tail -n 1)
    
    if [ -z "$UPSTREAM_HOST" ]; then
        Xdialog --title "Error" --msgbox "UPSTREAM HOST NOT FOUND" $DIALOG_WIDTH $DIALOG_HEIGHT
        exit 1
    fi

    Xdialog --title "Success" --msgbox "UPSTREAM HOST FOUND:\n$UPSTREAM_HOST" $DIALOG_WIDTH $DIALOG_HEIGHT
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
        UPSTREAM_RTSP="rtsp://$UPSTREAM_USER:$UPSTREAM_PASS@$UPSTREAM_HOST:$UPSTREAM_PORT/$UPSTREAM_PATH"

        # Connect and display video stream using mpv
        mpv --rtsp-transport=udp --volume=$MPV_VOLUME --profile=low-latency --cache=yes --untimed --no-demuxer-thread --force-seekable=yes --hr-seek=yes --hr-seek-framedrop=yes "$UPSTREAM_RTSP"

        # Check if the user wants to edit the fields again or exit
        if [ $? -eq 0 ]; then
            break
        fi
    done
}

main() {
    select_upstream_addr
    find_upstream_host
    input_connection_details
}

# Call the main function
main
