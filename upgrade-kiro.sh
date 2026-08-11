#!/bin/bash

# Exit on any error
set -e

echo "Starting Kiro upgrade process..."

# Stop Kiro if it's running
echo "Stopping any running Kiro instances..."
pkill -f "/opt/kiro" || true

# Run the community installation script to upgrade
echo "Running Kiro upgrade via installation script..."
curl -fsSL https://raw.githubusercontent.com/abhilashiig/kiro-ide-linux-installation/main/clone-and-install-kiro.sh | bash

# Verify the installation
if [ -x "/opt/kiro/kiro" ] || [ -x "/usr/local/bin/kiro" ]; then
    echo "Kiro upgrade completed successfully!"
    kiro --version 2>/dev/null || echo "Kiro is ready to use"
else
    echo "Warning: Kiro installation verification failed"
    exit 1
fi
