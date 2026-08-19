#!/bin/bash

# OpenCode Desktop Installation Script for Ubuntu
# This script downloads and installs OpenCode desktop application from GitHub releases

set -e

echo "=========================================="
echo "Installing OpenCode Desktop"
echo "=========================================="

# Define variables
OPENCODE_REPO="anomalyco/opencode"
TEMP_DIR="/tmp/opencode-install"
DESKTOP_FILE="/usr/share/applications/opencode.desktop"
ICON_DIR="/usr/share/icons/hicolor"

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

echo "Latest version: $LATEST_VERSION"
echo "Download URL: $DEB_URL"

# Download the .deb package
echo "Downloading OpenCode .deb package..."
wget -O opencode.deb "$DEB_URL" || {
    echo "Error: Failed to download OpenCode package"
    echo "Please check https://github.com/${OPENCODE_REPO}/releases for manual download"
    exit 1
}

# Install the package
echo "Installing OpenCode..."
apt-get install -y ./opencode.deb || {
    echo "Error: Failed to install OpenCode package"
    exit 1
}

# Verify installation
if command -v opencode &> /dev/null; then
    echo "OpenCode CLI installed successfully!"
    opencode --version
else
    echo "Warning: OpenCode CLI not found in PATH"
fi

# Check if desktop application was installed
if [ -f "/opt/OpenCode/opencode" ] || [ -f "/usr/bin/opencode-desktop" ] || [ -f "/usr/share/applications/opencode.desktop" ]; then
    echo "OpenCode Desktop application installed successfully!"
else
    echo "Desktop application may not be installed. Creating desktop entry..."
    
    # Try to locate the OpenCode executable
    OPENCODE_EXEC=$(find /opt -name "opencode" -type f 2>/dev/null | head -n 1)
    if [ -z "$OPENCODE_EXEC" ]; then
        OPENCODE_EXEC=$(which opencode 2>/dev/null || echo "/usr/bin/opencode")
    fi
    
    # Create desktop entry if it doesn't exist
    if [ ! -f "$DESKTOP_FILE" ]; then
        cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=OpenCode
GenericName=AI Coding Agent
Comment=Open source AI coding agent built for the terminal
Exec=$OPENCODE_EXEC
Icon=opencode
Terminal=false
Categories=Development;IDE;
Keywords=code;development;ai;coding;agent;
StartupWMClass=OpenCode
EOF
        chmod 644 "$DESKTOP_FILE"
        echo "Desktop entry created at $DESKTOP_FILE"
    fi
    
    # Try to extract and install icon if available
    if [ -f "./opencode.deb" ]; then
        dpkg-deb -x ./opencode.deb extracted/
        
        # Look for icon files in the extracted package
        ICON_FILE=$(find extracted/ -name "opencode*.png" -o -name "icon.png" | head -n 1)
        if [ -n "$ICON_FILE" ]; then
            # Determine icon size (default to 512x512 if unknown)
            ICON_SIZE="512x512"
            mkdir -p "$ICON_DIR/$ICON_SIZE/apps"
            cp "$ICON_FILE" "$ICON_DIR/$ICON_SIZE/apps/opencode.png"
            echo "Icon installed at $ICON_DIR/$ICON_SIZE/apps/opencode.png"
        fi
    fi
    
    # Update desktop database
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database /usr/share/applications/ 2>/dev/null || true
    fi
    
    # Update icon cache
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache -f -t "$ICON_DIR" 2>/dev/null || true
    fi
fi

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo "=========================================="
echo "OpenCode installation completed!"
echo "=========================================="
echo ""
echo "You can now:"
echo "  1. Run 'opencode' in the terminal"
echo "  2. Find 'OpenCode' in your application menu"
echo ""
echo "First time setup:"
echo "  Run 'opencode' and configure your AI provider"
echo ""
