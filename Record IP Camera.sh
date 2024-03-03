#!/bin/bash

#
# Record IP Camera.sh
#

# TASK: This script is designed to record video from an IP camera. It
# prompts the user to choose an upstream address, finds the
# corresponding host, and then prompts the user to input connection
# details such as username, password, port, and path. It then records
# the video using ffmpeg with the specified connection details.

# Source environment constants
source .env

# Constants
readonly DIALOG_WIDTH=20
readonly DIALOG_HEIGHT=100
readonly LOG_DIR="log"
readonly MAX_LOG_FILES=10

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

        if ! [ $? -eq 0 ]; then
            break
        fi

        # Extract values from INPUT
        UPSTREAM_USER=$(echo "$INPUT" | awk 'NR==1{print $NF}')
        UPSTREAM_PASS=$(echo "$INPUT" | awk 'NR==2{print $NF}')
        UPSTREAM_PORT=$(echo "$INPUT" | awk 'NR==3{print $NF}')
        UPSTREAM_PATH=$(echo "$INPUT" | awk 'NR==4{print $NF}')

        # Assemble UPSTREAM_RTSP variable
        UPSTREAM_RTSP="rtsp://$UPSTREAM_USER:$UPSTREAM_PASS@$UPSTREAM_HOST:$UPSTREAM_PORT/$UPSTREAM_PATH"

        # Record the video using ffmpeg with specified connection details
        record_video

        # Check if the user wants to edit the fields again or exit
        if ! [ $? -eq 0 ]; then
            break
        fi
    done
}

# Function to record video using ffmpeg
record_video() {
    # Create log directory if it doesn't exist
    mkdir -p "$LOG_DIR"

    # Generate log file name based on timestamp
    LOGFILE="camera_$(date +%Y%m%d_%H%M%S).ts"

    # Record the video to disk using ffmpeg with specified connection details
    ffmpeg -i "$UPSTREAM_RTSP" -c:v copy -c:a aac -y "$LOG_DIR/$LOGFILE"

    # Rotate log files
    rotate_logs
}

# Function to rotate log files
rotate_logs() {
    # Get the number of log files
    num_logs=$(find "$LOG_DIR" -maxdepth 1 -type f | wc -l)

    # If the number of log files exceeds the maximum, remove the oldest
    if [ "$num_logs" -gt "$MAX_LOG_FILES" ]; then
        oldest_log=$(find "$LOG_DIR" -maxdepth 1 -type f -printf "%T@ %p\n" | sort -n | head -n 1 | cut -d' ' -f2-)
        rm "$oldest_log"
    fi
}

main() {
    select_upstream_addr
    find_upstream_host
    input_connection_details
}

# Call the main function
main
