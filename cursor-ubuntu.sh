#!/bin/bash

export APPDIR=/usr/local/cursor

# start app with stability flags for containerized environment
$APPDIR/AppRun \
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
