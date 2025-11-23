#!/bin/bash

# Set environment variables for Chinese text rendering
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export FONTCONFIG_PATH=/etc/fonts

# start app with stability flags for containerized environment
/usr/bin/antigravity \
    --no-sandbox \
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
    --js-flags="--max-old-space-size=4096" \
    "$@"
