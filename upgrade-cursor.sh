#!/bin/bash

# Exit on any error
set -e

echo "Starting Cursor upgrade process..."

# Check if package path is provided as argument
if [ -n "$1" ]; then
    echo "Using provided package: $1"
    CURSOR_PACKAGE="$1"
    REMOVE_PACKAGE=false
else
    # Download the latest version
    echo "Downloading latest Cursor..."
    
    # Get the latest download link from the repository
    echo "Fetching latest download link..."
    README_URL="https://raw.githubusercontent.com/oslook/cursor-ai-downloads/main/README.md"
    LATEST_URL=$(wget -q -O- "$README_URL" | grep -m 1 "linux-x64.*AppImage" | grep -o 'https://[^)]*' | head -n 1)
    
    if [ -z "$LATEST_URL" ]; then
        echo "Error: Could not find download link. Please check https://github.com/oslook/cursor-ai-downloads"
        exit 1
    fi
    
    echo "Found download URL: $LATEST_URL"
    wget -O /tmp/cursor.app "$LATEST_URL"
    CURSOR_PACKAGE="/tmp/cursor.app"
    REMOVE_PACKAGE=true
fi

# Make it executable
chmod +x "$CURSOR_PACKAGE"

# Stop Cursor if it's running
echo "Stopping any running Cursor instances..."
pkill -f "/usr/local/cursor" || true

# Remove old installation
echo "Removing old installation..."
rm -rf /usr/local/cursor/*

# Extract new version
echo "Installing new version..."
cd /tmp
"$CURSOR_PACKAGE" --appimage-extract
mv squashfs-root/* /usr/local/cursor

# Set permissions
echo "Setting permissions..."
chown -R coder:coder /usr/local/cursor

# Clean up
echo "Cleaning up..."
if [ "$REMOVE_PACKAGE" = true ]; then
    rm "$CURSOR_PACKAGE"
fi
rm -rf /tmp/squashfs-root

echo "Cursor upgrade completed successfully!"

# Note: For the latest version links, please check:
# https://github.com/oslook/cursor-ai-downloads/blob/main/README.md