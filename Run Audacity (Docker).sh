#!/bin/bash

#
# Run Audacity (Docker).sh
#

# This file is part of the UTILITIES package.

# Set Bash strict mode
set -euo pipefail

# Check if Xdialog is installed
if ! command -v Xdialog &> /dev/null; then
    echo "Error: Xdialog is not installed. Please install Xdialog."
    exit 1
fi

# Ask for source share directory using Xdialog directory selector
SOURCE_SHARE_DIR=$(Xdialog --stdout --title "Select Source Share Directory" --dselect . 40 60)

# Ask for target share path using Xdialog input box
DEFAULT_TARGET_SHARE_DIR="/root/$(basename "$SOURCE_SHARE_DIR")"
TARGET_SHARE_DIR=$(Xdialog --stdout --title "Target Share Path" --inputbox "Enter Target Share Path:" 0 60 "$DEFAULT_TARGET_SHARE_DIR")

# Export docker daemon to communicate with
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

# Define the Dockerfile content using a here document
DOCKERFILE_CONTENT=$(cat <<FINAL_EOF
FROM debian:bookworm-slim@sha256:b396b38adb888af839a4b967ba919c49086987126500d6cd8f662531e202d038

RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends audacity
apt-get install -y --no-install-recommends pipewire
apt-get install -y --no-install-recommends pipewire-audio-client-libraries
rm -rf /var/lib/apt/lists/*
EOF

WORKDIR /root

ENTRYPOINT ["audacity"]
FINAL_EOF
)

# Build the Docker image directly from the here document
echo "$DOCKERFILE_CONTENT" | docker build -t local/audacity - 2>&1

# Run the Docker container
docker run \
    --device /dev/dri \
    --env DISPLAY \
    --env XDG_RUNTIME_DIR=/tmp \
    --volume "/tmp/.X11-unix:/tmp/.X11-unix" \
    --volume "$XDG_RUNTIME_DIR/pipewire-0:/tmp/pipewire-0" \
    --volume "$SOURCE_SHARE_DIR:$TARGET_SHARE_DIR" \
    local/audacity "$@"
