#!/bin/bash

#
# Run VK Cube (Docker).sh
#

# This file is part of the UTILITIES package.

# Set Bash strict mode
set -euo pipefail

# Export docker daemon to communicate with
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

# Define the Dockerfile content using a here document
DOCKERFILE_CONTENT=$(cat <<FINAL_EOF
FROM debian:bullseye-slim@sha256:ac707220fbd7b67fc19b112cee8170b41a9e97f703f588b2cdbbcdcecdd8af57

RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends mesa-vulkan-drivers
apt-get install -y --no-install-recommends vulkan-tools
rm -rf /var/lib/apt/lists/*
EOF

ENTRYPOINT ["vkcube"]
FINAL_EOF
)

# Build the Docker image directly from the here document
echo "$DOCKERFILE_CONTENT" | docker build -t local/vkcube - 2>&1

# Run the Docker container
docker run \
    --device=/dev/dri:/dev/dri \
    --env DISPLAY \
    --env GDK_SCALE \
    --env GDK_DPI_SCALE \
    --env XDG_RUNTIME_DIR=/tmp \
    --volume "/tmp/.X11-unix:/tmp/.X11-unix" \
    local/vkcube "$@"
