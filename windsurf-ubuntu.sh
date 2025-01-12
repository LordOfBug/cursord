#!/bin/bash

export APPDIR=/usr/local/windsurf

# Check if a URL parameter was passed
if [ $# -gt 0 ]; then
    # URL was passed, launch with the URL parameter
    $APPDIR/windsurf --no-sandbox --reuse-window --open-url "$1"
else
    # No URL, normal launch
    $APPDIR/windsurf --no-sandbox
fi
