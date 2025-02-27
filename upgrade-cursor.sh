#!/bin/bash

# Exit on any error
set -e

echo "Starting Cursor upgrade process..."

# Download the latest version
echo "Downloading latest Cursor..."
wget -O /tmp/cursor.app https://downloader.cursor.sh/linux

# Make it executable
chmod +x /tmp/cursor.app

# Stop Cursor if it's running
echo "Stopping any running Cursor instances..."
pkill -f "/usr/local/cursor" || true

# Remove old installation
echo "Removing old installation..."
rm -rf /usr/local/cursor/*

# Extract new version
echo "Installing new version..."
cd /tmp
./cursor.app --appimage-extract
mv squashfs-root/* /usr/local/cursor

# Set permissions
echo "Setting permissions..."
chown -R coder:coder /usr/local/cursor

# Clean up
echo "Cleaning up..."
rm /tmp/cursor.app
rm -rf /tmp/squashfs-root

echo "Cursor upgrade completed successfully!"