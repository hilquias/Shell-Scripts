#!/bin/bash

#
# Run API File Search (Docker).sh
#

# This file is part of the UTILITIES package.

# Set Bash strict mode
set -euo pipefail

# Check if Xdialog is installed
if ! command -v Xdialog &> /dev/null; then
    echo "Error: Xdialog is not installed. Please install Xdialog."
    exit 1
fi

# Prompt user for speaker-test arguments using Xdialog
PATTERN=$(Xdialog --inputbox "Enter the pattern for apt-file search:" 10 50 "bin/ping" 2>&1 >/dev/tty)

# Export docker daemon to communicate with
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

# Define the Dockerfile content using a here document
DOCKERFILE_CONTENT=$(cat <<FINAL_EOF
FROM debian:bullseye-slim@sha256:ac707220fbd7b67fc19b112cee8170b41a9e97f703f588b2cdbbcdcecdd8af57

RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends apt-file
rm -rf /var/lib/apt/lists/*
EOF

RUN apt-file update

ENTRYPOINT ["apt-file"]
FINAL_EOF
)

# Build the Docker image directly from the here document
echo "$DOCKERFILE_CONTENT" | docker build -t local/apt-file - 2>&1

temp_file=$(mktemp)

# Run the Docker container with provided arguments
docker run local/apt-file search "$PATTERN" > "$temp_file"

# Display the search results content in an editbox
Xdialog --title "APT File Search Results" --editbox "$temp_file" 60 160 || true

# Remove the temporary file
rm -f "$temp_file"
