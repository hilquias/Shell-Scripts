#!/bin/bash

#
# Run GParted (Docker).sh
#

# This file is part of the UTILITIES package.

# Set Bash strict mode
set -euo pipefail

# Export docker daemon to communicate with
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

# Define the Dockerfile content using a here document
DOCKERFILE_CONTENT=$(cat <<FINAL_EOF
FROM debian:bookworm-slim@sha256:b396b38adb888af839a4b967ba919c49086987126500d6cd8f662531e202d038

RUN <<EOF
set -e
apt-get update
apt-get install -y --no-install-recommends dosfstools
apt-get install -y --no-install-recommends gparted
apt-get install -y --no-install-recommends mtools
rm -rf /var/lib/apt/lists/*
EOF

WORKDIR /root

ENTRYPOINT ["gparted"]
FINAL_EOF
)

# Build the Docker image directly from the here document
echo "$DOCKERFILE_CONTENT" | docker build -t local/gparted - 2>&1

# Run the Docker container
docker run \
    --env DISPLAY \
    --env GDK_SCALE \
    --env GDK_DPI_SCALE \
    --cap-add SYS_RAWIO \
    --device /dev/sda \
    --device /dev/sdb \
    --device /dev/mem \
    --volume /tmp/.X11-unix:/tmp/.X11-unix \
    local/gparted
