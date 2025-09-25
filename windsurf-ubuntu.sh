#!/bin/bash

export APPDIR=/usr/local/windsurf

# Set environment variables for Chinese text rendering
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export FONTCONFIG_PATH=/etc/fonts

# Common stability flags for containerized environment
STABILITY_FLAGS="--no-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-software-rasterizer \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-features=VizDisplayCompositor \
    --disable-ipc-flooding-protection \
    --memory-pressure-off \
    --max_old_space_size=4096 \
    --js-flags=--max-old-space-size=4096"

# Check if a URL parameter was passed
if [ $# -gt 0 ]; then
    # URL was passed, launch with the URL parameter
    $APPDIR/windsurf $STABILITY_FLAGS --reuse-window --open-url "$1"
else
    # No URL, normal launch
    $APPDIR/windsurf $STABILITY_FLAGS
fi
