#!/bin/bash

# Exit on any error
set -e

echo "Starting Antigravity upgrade process..."

# Stop Antigravity if it's running
echo "Stopping any running Antigravity instances..."
pkill -f "antigravity" || true

# Update package list and upgrade Antigravity
echo "Updating package list..."
apt-get update

echo "Upgrading Antigravity..."
apt-get install -y --only-upgrade antigravity

# Clean up
echo "Cleaning up..."
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "Antigravity upgrade completed successfully!"
