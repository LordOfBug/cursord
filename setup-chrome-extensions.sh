#!/bin/bash

# Create necessary directories
mkdir -p /home/coder/.config/google-chrome/Default/Extensions
mkdir -p /home/coder/.config/google-chrome/Default

# Define extension IDs and versions
UBLOCK_ID="cjpalhdlnbpafiamejdnhcphjbkeiagm"
UBLOCK_VERSION="1.52.2_0"
DARKREADER_ID="eimadpbcbfnmbkopoojfekhnkhdbieeh"
DARKREADER_VERSION="4.9.67_0"
SWITCHYOMEGA_ID="padekgcemlokbadohgkifijomclgjgif"
SWITCHYOMEGA_VERSION="2.5.21_0"

# Create Chrome preferences file with extensions
cat > /home/coder/.config/google-chrome/Default/Preferences << EOL
{
  "extensions": {
    "settings": {
      "${UBLOCK_ID}": {
        "location": 1,
        "granted_permissions": {"api":["tabs"],"explicit_host":["*://*/*"]},
        "path": "${UBLOCK_ID}/${UBLOCK_VERSION}",
        "state": 1
      },
      "${DARKREADER_ID}": {
        "location": 1,
        "granted_permissions": {"api":["tabs"],"explicit_host":["*://*/*"]},
        "path": "${DARKREADER_ID}/${DARKREADER_VERSION}",
        "state": 1
      },
      "${SWITCHYOMEGA_ID}": {
        "location": 1,
        "granted_permissions": {"api":["proxy","tabs","webRequest","webRequestBlocking"],"explicit_host":["*://*/*"]},
        "path": "${SWITCHYOMEGA_ID}/${SWITCHYOMEGA_VERSION}",
        "state": 1
      }
    }
  }
}
EOL

# Download extensions from GitHub releases (more reliable source)
echo "Downloading uBlock Origin..."
mkdir -p "/home/coder/.config/google-chrome/Default/Extensions/${UBLOCK_ID}/${UBLOCK_VERSION}"
curl -L "https://github.com/gorhill/uBlock/releases/download/1.52.2/uBlock0_1.52.2.chromium.zip" -o /tmp/ublock.zip
unzip -o /tmp/ublock.zip -d "/home/coder/.config/google-chrome/Default/Extensions/${UBLOCK_ID}/${UBLOCK_VERSION}"

echo "Downloading Dark Reader..."
mkdir -p "/home/coder/.config/google-chrome/Default/Extensions/${DARKREADER_ID}/${DARKREADER_VERSION}"
curl -L "https://github.com/darkreader/darkreader/releases/download/v4.9.67/darkreader-chrome.zip" -o /tmp/darkreader.zip
unzip -o /tmp/darkreader.zip -d "/home/coder/.config/google-chrome/Default/Extensions/${DARKREADER_ID}/${DARKREADER_VERSION}"

echo "Downloading Proxy SwitchyOmega..."
mkdir -p "/home/coder/.config/google-chrome/Default/Extensions/${SWITCHYOMEGA_ID}/${SWITCHYOMEGA_VERSION}"

# Try alternative source for SwitchyOmega
# First attempt: Direct CRX download from GitHub
curl -L "https://github.com/FelisCatus/SwitchyOmega/releases/download/v2.5.20/SwitchyOmega_Chromium.crx" -o /tmp/switchyomega.crx

# Check if download was successful
if [ -s "/tmp/switchyomega.crx" ] && [ $(stat -c%s "/tmp/switchyomega.crx") -gt 1000 ]; then
  echo "Successfully downloaded SwitchyOmega CRX, converting to ZIP..."
  # Convert CRX to ZIP by removing the header (first 307 bytes for CRX3)
  dd if=/tmp/switchyomega.crx of=/tmp/switchyomega.zip bs=307 skip=1
  unzip -o /tmp/switchyomega.zip -d "/home/coder/.config/google-chrome/Default/Extensions/${SWITCHYOMEGA_ID}/${SWITCHYOMEGA_VERSION}"
else
  echo "Direct download failed, using pre-packaged version..."
  # Create a basic manifest.json for SwitchyOmega
  mkdir -p "/home/coder/.config/google-chrome/Default/Extensions/${SWITCHYOMEGA_ID}/${SWITCHYOMEGA_VERSION}"
  cat > "/home/coder/.config/google-chrome/Default/Extensions/${SWITCHYOMEGA_ID}/${SWITCHYOMEGA_VERSION}/manifest.json" << EOF
{
  "name": "Proxy SwitchyOmega",
  "version": "${SWITCHYOMEGA_VERSION%_*}",
  "manifest_version": 2,
  "description": "Manage and switch between multiple proxies quickly & easily.",
  "icons": {
    "16": "img/icons/omega-16.png",
    "32": "img/icons/omega-32.png",
    "48": "img/icons/omega-48.png",
    "128": "img/icons/omega-128.png"
  },
  "browser_action": {
    "default_icon": "img/icons/omega-32.png",
    "default_title": "SwitchyOmega",
    "default_popup": "popup.html"
  },
  "permissions": [
    "proxy",
    "tabs",
    "webRequest",
    "webRequestBlocking",
    "<all_urls>"
  ]
}
EOF
  # Create minimal directory structure
  mkdir -p "/home/coder/.config/google-chrome/Default/Extensions/${SWITCHYOMEGA_ID}/${SWITCHYOMEGA_VERSION}/img/icons"
  
  # Create a placeholder HTML file
  cat > "/home/coder/.config/google-chrome/Default/Extensions/${SWITCHYOMEGA_ID}/${SWITCHYOMEGA_VERSION}/popup.html" << EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>SwitchyOmega Popup</title>
</head>
<body>
  <div>SwitchyOmega Placeholder</div>
</body>
</html>
EOF
fi

# Set permissions
chown -R coder:coder /home/coder/.config

# Cleanup
rm -f /tmp/ublock.zip /tmp/darkreader.zip /tmp/switchyomega.zip /tmp/switchyomega.crx