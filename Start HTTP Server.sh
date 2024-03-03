#!/bin/bash

#
# Start HTTP Server.sh
#

# This script is part of the UTILITIES package.

# TASK: Create a Bash script that prompts the user to select a working
# directory and enter a port number, then starts an HTTP server using
# darkhttpd with the specified directory and port, and displays the
# server log in a dialog box.

# Function to display logbox with given text
show_logbox() {
    Xdialog --title "HTTP Server Log" --logbox "$1" 0 0
    # Kill darkhttpd process when logbox is closed
    pkill darkhttpd
}

# Ask user to select working directory
working_dir=$(Xdialog --stdout --title "Select Working Directory" --dselect . 0 0)

# If user cancels, exit program
if [ $? -ne 0 ]; then
    exit 0
fi

# Ask user to enter port number
port=$(Xdialog --stdout --title "Enter Port Number" --inputbox "Enter port number:" 0 0)

# If user cancels, exit program
if [ -z "$port" ]; then
    exit 0
fi

# Create a temporary file to store darkhttpd output
log_file=$(mktemp)

# Start darkhttpd server with selected directory and port number, redirecting output to the log file
echo "Starting darkhttpd server with wwwroot: $working_dir and port: $port" >&2
echo "DEBUG: Starting darkhttpd server with wwwroot: $working_dir and port: $port" # Debug message
darkhttpd "$working_dir" --port "$port" >> "$log_file" 2>&1 &

# Display the contents of the log file in a logbox
sleep 5
show_logbox "$log_file"

# Remove the temporary log file
rm "$log_file"
