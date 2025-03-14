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
    wget -O /tmp/cursor.app https://downloader.cursor.sh/linux
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