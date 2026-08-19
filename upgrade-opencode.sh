#!/bin/bash

# Exit on any error
set -e

echo "Starting OpenCode upgrade process..."

# Stop OpenCode if it's running
echo "Stopping any running OpenCode instances..."
pkill -f "opencode" || true
pkill -f "/opt/OpenCode" || true

# Define variables
OPENCODE_REPO="anomalyco/opencode"
TEMP_DIR="/tmp/opencode-upgrade"

# Create temporary directory
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Get the latest release version and download URL
echo "Fetching latest OpenCode release information..."
LATEST_RELEASE=$(curl -s "https://api.github.com/repos/${OPENCODE_REPO}/releases/latest")
LATEST_VERSION=$(echo "$LATEST_RELEASE" | grep -Po '"tag_name": "\K.*?(?=")')
DEB_URL=$(echo "$LATEST_RELEASE" | grep -Po '"browser_download_url": "\K.*?(?=")' | grep "\.deb$" | grep -i "linux" | head -n 1)

if [ -z "$DEB_URL" ]; then
    echo "Error: Could not find .deb download URL"
    echo "Trying fallback method..."
    # Fallback: construct URL based on common pattern
    LATEST_VERSION=$(curl -s "https://api.github.com/repos/${OPENCODE_REPO}/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
    DEB_URL="https://github.com/${OPENCODE_REPO}/releases/download/${LATEST_VERSION}/opencode_${LATEST_VERSION#v}_amd64.deb"
fi

# Check current installed version
CURRENT_VERSION=""
if command -v opencode &> /dev/null; then
    CURRENT_VERSION=$(opencode --version 2>/dev/null | head -n 1 || echo "unknown")
    echo "Current OpenCode version: $CURRENT_VERSION"
fi

echo "Latest available version: $LATEST_VERSION"

# Download the .deb package
echo "Downloading OpenCode .deb package..."
wget -O opencode.deb "$DEB_URL" || {
    echo "Error: Failed to download OpenCode package"
    echo "Please check https://github.com/${OPENCODE_REPO}/releases for manual download"
    exit 1
}

# Upgrade the package
echo "Upgrading OpenCode..."
apt-get install -y --reinstall ./opencode.deb || {
    echo "Error: Failed to upgrade OpenCode package"
    exit 1
}

# Cleanup
cd /
rm -rf "$TEMP_DIR"

# Verify the upgrade
if command -v opencode &> /dev/null; then
    NEW_VERSION=$(opencode --version 2>/dev/null | head -n 1 || echo "installed")
    echo "OpenCode upgrade completed successfully!"
    echo "New version: $NEW_VERSION"
else
    echo "Warning: OpenCode upgrade verification failed"
    exit 1
fi

