#!/bin/bash

# Exit on any error
set -e

echo "Starting Windsurf upgrade process..."

# Check if package path is provided as argument
if [ -n "$1" ]; then
    echo "Using provided package: $1"
    WINDSURF_PACKAGE="$1"
    REMOVE_PACKAGE=false
else
    # Download the latest version
    echo "Downloading latest Windsurf..."
    
    # Get the latest download link from the Windsurf releases
    echo "Fetching latest download link..."
    # This URL should be replaced with the actual Windsurf releases or equivalent
    RELEASES_URL="https://api.github.com/repos/windsurfapp/windsurf/releases/latest"
    
    # Parse the GitHub API response to find Linux x64 AppImage asset
    # Adjust this based on the actual naming convention used by Windsurf
    LATEST_URL=$(wget -q -O- "$RELEASES_URL" | grep -o "https://github.com/windsurfapp/windsurf/releases/download/[^\"]*\\.AppImage" | head -n 1)
    
    if [ -z "$LATEST_URL" ]; then
        echo "Error: Could not find download link. Please check https://github.com/windsurfapp/windsurf/releases"
        exit 1
    fi
    
    echo "Found download URL: $LATEST_URL"
    wget -O /tmp/windsurf.app "$LATEST_URL"
    WINDSURF_PACKAGE="/tmp/windsurf.app"
    REMOVE_PACKAGE=true
fi

# Make it executable
chmod +x "$WINDSURF_PACKAGE"

# Stop Windsurf if it's running
echo "Stopping any running Windsurf instances..."
pkill -f "/usr/local/windsurf" || true

# Remove old installation
echo "Removing old installation..."
rm -rf /usr/local/windsurf/*

# Extract new version
echo "Installing new version..."
cd /tmp
"$WINDSURF_PACKAGE" --appimage-extract
mv squashfs-root/* /usr/local/windsurf

# Set permissions
echo "Setting permissions..."
chown -R coder:coder /usr/local/windsurf

# Clean up
echo "Cleaning up..."
if [ "$REMOVE_PACKAGE" = true ]; then
    rm "$WINDSURF_PACKAGE"
fi
rm -rf /tmp/squashfs-root

echo "Windsurf upgrade completed successfully!"
