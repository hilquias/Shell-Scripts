#!/bin/bash

#
# Run Speaker Test (Docker).sh
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
ARGUMENTS=$(Xdialog --inputbox "Enter arguments for speaker-test:" 10 50 "-Dpipewire -c2 -l1" 2>&1 >/dev/tty)

# Export docker daemon to communicate with
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

# Define the Dockerfile content using a here document
DOCKERFILE_CONTENT=$(cat <<FINAL_EOF
FROM debian:bullseye-slim@sha256:ac707220fbd7b67fc19b112cee8170b41a9e97f703f588b2cdbbcdcecdd8af57

RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends alsa-utils
apt-get install -y --no-install-recommends pipewire
apt-get install -y --no-install-recommends pipewire-audio-client-libraries
rm -rf /var/lib/apt/lists/*
EOF

ENTRYPOINT ["speaker-test"]
FINAL_EOF
)

# Build the Docker image directly from the here document
echo "$DOCKERFILE_CONTENT" | docker build -t local/speaker-test - 2>&1

# Run the Docker container with provided arguments
docker run \
    --env XDG_RUNTIME_DIR=/tmp \
    --volume "$XDG_RUNTIME_DIR/pipewire-0:/tmp/pipewire-0" \
    local/speaker-test "$ARGUMENTS"
