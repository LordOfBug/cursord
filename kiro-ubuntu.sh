#!/bin/bash

export APPDIR=/opt/kiro

# Set environment variables for Chinese text rendering
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export FONTCONFIG_PATH=/etc/fonts

# Ensure D-Bus session bus is available
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax)
fi

# Disable accessibility bus warnings
export NO_AT_BRIDGE=1

# Detect proxy settings if configured
PROXY_FLAGS=""
if [ -n "$ALL_PROXY" ]; then
    PROXY_FLAGS="--proxy-server=$ALL_PROXY"
elif [ -n "$all_proxy" ]; then
    PROXY_FLAGS="--proxy-server=$all_proxy"
elif [ -n "$http_proxy" ]; then
    PROXY_FLAGS="--proxy-server=$http_proxy"
elif [ -n "$HTTP_PROXY" ]; then
    PROXY_FLAGS="--proxy-server=$HTTP_PROXY"
fi

# Common stability flags for containerized environment
STABILITY_FLAGS="$PROXY_FLAGS --no-sandbox \
    --disable-gpu \
    --password-store=basic \
    --disable-dev-shm-usage \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --js-flags=--max-old-space-size=4096"

# Check if a URL parameter was passed
if [ $# -gt 0 ]; then
    # URL was passed, launch with the URL parameter
    $APPDIR/kiro $STABILITY_FLAGS --reuse-window --open-url "$1"
else
    # No URL, normal launch
    $APPDIR/kiro $STABILITY_FLAGS
fi
