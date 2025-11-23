#!/bin/bash

# Exit on any error
set -e

echo "Starting Antigravity upgrade process..."

# Check if package path is provided as argument
if [ -n "$1" ]; then
    echo "Using provided package: $1"
    ANTIGRAVITY_PACKAGE="$1"
    REMOVE_PACKAGE=false
else
    # Download the latest version
    echo "Downloading latest Antigravity..."
    
    LATEST_URL="https://antigravity.google/download/linux"
    
    echo "Found download URL: $LATEST_URL"
    wget -O /tmp/antigravity.app "$LATEST_URL"
    ANTIGRAVITY_PACKAGE="/tmp/antigravity.app"
    REMOVE_PACKAGE=true
fi

# Make it executable
chmod +x "$ANTIGRAVITY_PACKAGE"

# Stop Antigravity if it's running
echo "Stopping any running Antigravity instances..."
pkill -f "/usr/local/antigravity" || true

# Remove old installation
echo "Removing old installation..."
rm -rf /usr/local/antigravity/*

# Extract new version
echo "Installing new version..."
cd /tmp
"$ANTIGRAVITY_PACKAGE" --appimage-extract
mv squashfs-root/* /usr/local/antigravity

# Set permissions
echo "Setting permissions..."
chown -R coder:coder /usr/local/antigravity

# Clean up
echo "Cleaning up..."
if [ "$REMOVE_PACKAGE" = true ]; then
    rm "$ANTIGRAVITY_PACKAGE"
fi
rm -rf /tmp/squashfs-root

echo "Antigravity upgrade completed successfully!"
