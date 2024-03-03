#!/bin/bash

#
# Run Mozilla Firefox (Docker).sh
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
DEFAULT_TARGET_SHARE_DIR="/home/guest/.mozilla"
TARGET_SHARE_DIR=$(Xdialog --stdout --title "Target Share Path" --inputbox "Enter Target Share Path:" 0 60 "$DEFAULT_TARGET_SHARE_DIR")

# Export docker daemon to communicate with
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

# Define the Dockerfile content using a here document
DOCKERFILE_CONTENT=$(cat <<FINAL_EOF
FROM debian:bookworm-slim@sha256:b396b38adb888af839a4b967ba919c49086987126500d6cd8f662531e202d038

RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends alsa-utils
apt-get install -y --no-install-recommends ca-certificates
apt-get install -y --no-install-recommends dbus-x11
apt-get install -y --no-install-recommends ffmpeg
apt-get install -y --no-install-recommends firefox-esr
apt-get install -y --no-install-recommends fonts-liberation
apt-get install -y --no-install-recommends fonts-noto
apt-get install -y --no-install-recommends fonts-noto-cjk
apt-get install -y --no-install-recommends fonts-noto-color-emoji
apt-get install -y --no-install-recommends fonts-roboto
apt-get install -y --no-install-recommends fonts-symbola
apt-get install -y --no-install-recommends hicolor-icon-theme
apt-get install -y --no-install-recommends libexif-dev
apt-get install -y --no-install-recommends libfontconfig1
apt-get install -y --no-install-recommends libgl1-mesa-dri
apt-get install -y --no-install-recommends libgl1-mesa-glx
apt-get install -y --no-install-recommends libv4l-0
apt-get install -y --no-install-recommends pipewire
apt-get install -y --no-install-recommends pipewire-audio-client-libraries
rm -rf /var/lib/apt/lists/*
EOF

RUN <<EOF
useradd --create-home --home-dir /home/guest guest
mkdir -p /home/guest/.mozilla
chown -R guest:guest /home/guest /home/guest/.mozilla
EOF

USER guest

WORKDIR /home/guest

ENTRYPOINT ["firefox"]
FINAL_EOF
)

# Build the Docker image directly from the here document
echo "$DOCKERFILE_CONTENT" | docker build -t local/firefox - 2>&1

# Run the Docker container
docker run \
    --device /dev/dri \
    --env DISPLAY \
    --env GDK_SCALE \
    --env GDK_DPI_SCALE \
    --env XDG_RUNTIME_DIR=/tmp \
    --volume "/dev/shm:/dev/shm" \
    --volume "/tmp/.X11-unix:/tmp/.X11-unix" \
    --volume "$XDG_RUNTIME_DIR/pipewire-0:/tmp/pipewire-0" \
    --volume "$SOURCE_SHARE_DIR:$TARGET_SHARE_DIR" \
    local/firefox "$@"
