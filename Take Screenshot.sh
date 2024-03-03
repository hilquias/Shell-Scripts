#!/bin/bash

#
# Take Screenshot.sh
#

# This script is part of the UTILITIES package.

# TASK: Create a Bash script that prompts the user to enter a delay in
# seconds before taking a screenshot, captures a screenshot after the
# specified delay, and saves it with a timestamped filename.

# Prompt the user for delay in seconds
delay=$(Xdialog --stdout --inputbox "Enter delay in seconds before taking screenshot:" 0 0)

# Debug: Display delay entered by the user
echo "Delay entered by user: $delay seconds"

# Wait for the specified delay
sleep "$delay"

# Capture screenshot of primary display and save with timestamped filename
timestamp=$(date +"%Y%m%d_%H%M%S")
screenshot_filename="screenshot_$timestamp.png"

# Get the resolution and position of the primary display
primary_info=$(xrandr | grep primary)
resolution=$(echo "$primary_info" | awk '{print $4}')
position=$(echo "$primary_info" | awk '{print $3}')

# Extract width and height from the resolution
width=$(echo "$resolution" | awk -F 'x' '{print $1}')
height=$(echo "$resolution" | awk -F 'x' '{print $2}')

# Extract x and y coordinates from the position
x=$(echo "$position" | awk -F '+' '{print $2}')
y=$(echo "$position" | awk -F '+' '{print $3}')

# Capture screenshot of primary display and save with timestamped filename
import -window root -crop "${width}x${height}+${x}+${y}" "log/$screenshot_filename"

# Debug: Display the filename of the captured screenshot
echo "Screenshot saved as: $screenshot_filename"
