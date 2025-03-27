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
mkdir -p "/home/coder/.config/google-chrome/Default/Extensions/${UBLOCK_ID}"
curl -L "https://github.com/gorhill/uBlock/releases/download/1.52.2/uBlock0_1.52.2.chromium.zip" -o /tmp/ublock.zip

# Extract to a temporary directory first to check structure
rm -rf /tmp/ublock_ext
mkdir -p /tmp/ublock_ext
unzip -o /tmp/ublock.zip -d /tmp/ublock_ext

# Check if manifest.json exists directly or in a subdirectory
if [ -f "/tmp/ublock_ext/manifest.json" ]; then
  # Manifest exists at root, move everything to version directory
  mkdir -p "/home/coder/.config/google-chrome/Default/Extensions/${UBLOCK_ID}/${UBLOCK_VERSION}"
  cp -r /tmp/ublock_ext/* "/home/coder/.config/google-chrome/Default/Extensions/${UBLOCK_ID}/${UBLOCK_VERSION}/"
  echo "uBlock Origin manifest found at root level"
else
  # Look for subdirectory with manifest.json
  MANIFEST_DIR=$(find /tmp/ublock_ext -name "manifest.json" -exec dirname {} \; | head -n 1)
  if [ -n "$MANIFEST_DIR" ]; then
    # Found manifest in subdirectory, copy that directory's contents
    mkdir -p "/home/coder/.config/google-chrome/Default/Extensions/${UBLOCK_ID}/${UBLOCK_VERSION}"
    cp -r "$MANIFEST_DIR"/* "/home/coder/.config/google-chrome/Default/Extensions/${UBLOCK_ID}/${UBLOCK_VERSION}/"
    echo "uBlock Origin manifest found in subdirectory: $MANIFEST_DIR"
  else
    echo "ERROR: No manifest.json found for uBlock Origin"
  fi
fi

# Verify manifest exists in final location
if [ -f "/home/coder/.config/google-chrome/Default/Extensions/${UBLOCK_ID}/${UBLOCK_VERSION}/manifest.json" ]; then
  echo "uBlock Origin manifest.json verified in final location"
else
  echo "WARNING: manifest.json not found in final uBlock Origin location"
fi

echo "Downloading Dark Reader..."
mkdir -p "/home/coder/.config/google-chrome/Default/Extensions/${DARKREADER_ID}"
curl -L "https://github.com/darkreader/darkreader/releases/download/v4.9.67/darkreader-chrome.zip" -o /tmp/darkreader.zip

# Extract to a temporary directory first to check structure
rm -rf /tmp/darkreader_ext
mkdir -p /tmp/darkreader_ext
unzip -o /tmp/darkreader.zip -d /tmp/darkreader_ext

# Check if manifest.json exists directly or in a subdirectory
if [ -f "/tmp/darkreader_ext/manifest.json" ]; then
  # Manifest exists at root, move everything to version directory
  mkdir -p "/home/coder/.config/google-chrome/Default/Extensions/${DARKREADER_ID}/${DARKREADER_VERSION}"
  cp -r /tmp/darkreader_ext/* "/home/coder/.config/google-chrome/Default/Extensions/${DARKREADER_ID}/${DARKREADER_VERSION}/"
  echo "Dark Reader manifest found at root level"
else
  # Look for subdirectory with manifest.json
  MANIFEST_DIR=$(find /tmp/darkreader_ext -name "manifest.json" -exec dirname {} \; | head -n 1)
  if [ -n "$MANIFEST_DIR" ]; then
    # Found manifest in subdirectory, copy that directory's contents
    mkdir -p "/home/coder/.config/google-chrome/Default/Extensions/${DARKREADER_ID}/${DARKREADER_VERSION}"
    cp -r "$MANIFEST_DIR"/* "/home/coder/.config/google-chrome/Default/Extensions/${DARKREADER_ID}/${DARKREADER_VERSION}/"
    echo "Dark Reader manifest found in subdirectory: $MANIFEST_DIR"
  else
    echo "ERROR: No manifest.json found for Dark Reader"
  fi
fi

# Verify manifest exists in final location
if [ -f "/home/coder/.config/google-chrome/Default/Extensions/${DARKREADER_ID}/${DARKREADER_VERSION}/manifest.json" ]; then
  echo "Dark Reader manifest.json verified in final location"
else
  echo "WARNING: manifest.json not found in final Dark Reader location"
fi

echo "Downloading Proxy SwitchyOmega..."
mkdir -p "/home/coder/.config/google-chrome/Default/Extensions/${SWITCHYOMEGA_ID}"

# Try alternative source for SwitchyOmega
# First attempt: Direct CRX download from GitHub
curl -L "https://github.com/FelisCatus/SwitchyOmega/releases/download/v2.5.20/SwitchyOmega_Chromium.crx" -o /tmp/switchyomega.crx

# Check if download was successful
if [ -s "/tmp/switchyomega.crx" ] && [ $(stat -c%s "/tmp/switchyomega.crx") -gt 1000 ]; then
  echo "Successfully downloaded SwitchyOmega CRX, converting to ZIP..."
  # Convert CRX to ZIP by removing the header (first 307 bytes for CRX3)
  dd if=/tmp/switchyomega.crx of=/tmp/switchyomega.zip bs=307 skip=1
  
  # Extract to a temporary directory first to check structure
  rm -rf /tmp/switchyomega_ext
  mkdir -p /tmp/switchyomega_ext
  unzip -o /tmp/switchyomega.zip -d /tmp/switchyomega_ext
  
  # Check if manifest.json exists directly or in a subdirectory
  if [ -f "/tmp/switchyomega_ext/manifest.json" ]; then
    # Manifest exists at root, move everything to version directory
    mkdir -p "/home/coder/.config/google-chrome/Default/Extensions/${SWITCHYOMEGA_ID}/${SWITCHYOMEGA_VERSION}"
    cp -r /tmp/switchyomega_ext/* "/home/coder/.config/google-chrome/Default/Extensions/${SWITCHYOMEGA_ID}/${SWITCHYOMEGA_VERSION}/"
    echo "SwitchyOmega manifest found at root level"
  else
    # Look for subdirectory with manifest.json
    MANIFEST_DIR=$(find /tmp/switchyomega_ext -name "manifest.json" -exec dirname {} \; | head -n 1)
    if [ -n "$MANIFEST_DIR" ]; then
      # Found manifest in subdirectory, copy that directory's contents
      mkdir -p "/home/coder/.config/google-chrome/Default/Extensions/${SWITCHYOMEGA_ID}/${SWITCHYOMEGA_VERSION}"
      cp -r "$MANIFEST_DIR"/* "/home/coder/.config/google-chrome/Default/Extensions/${SWITCHYOMEGA_ID}/${SWITCHYOMEGA_VERSION}/"
      echo "SwitchyOmega manifest found in subdirectory: $MANIFEST_DIR"
    else
      echo "ERROR: No manifest.json found for SwitchyOmega"
    fi
  fi
  
  # Verify manifest exists in final location
  if [ -f "/home/coder/.config/google-chrome/Default/Extensions/${SWITCHYOMEGA_ID}/${SWITCHYOMEGA_VERSION}/manifest.json" ]; then
    echo "SwitchyOmega manifest.json verified in final location"
    
    # Check if icon files exist, create them if they don't
    ICON_DIR="/home/coder/.config/google-chrome/Default/Extensions/${SWITCHYOMEGA_ID}/${SWITCHYOMEGA_VERSION}/img/icons"
    mkdir -p "$ICON_DIR"
    
    # Check for each icon file and create if missing
    for ICON_SIZE in 16 32 48 128; do
      if [ ! -f "$ICON_DIR/omega-$ICON_SIZE.png" ]; then
        echo "Creating missing icon: omega-$ICON_SIZE.png"
        # Base64 encoded 1x1 transparent PNG
        TRANSPARENT_PNG="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII="
        echo "$TRANSPARENT_PNG" | base64 -d > "$ICON_DIR/omega-$ICON_SIZE.png"
      fi
    done
  else
    echo "WARNING: manifest.json not found in final SwitchyOmega location"
  fi
else
  echo "Direct download failed, no switchyomega available ..."
fi

# Set permissions
chown -R coder:coder /home/coder/.config

# Cleanup
rm -f /tmp/ublock.zip /tmp/darkreader.zip /tmp/switchyomega.zip /tmp/switchyomega.crx

# Now ask chrome to load switchyometa extention by default. We re-create google-chrome-stable created in Dockerfile
echo '#!/bin/bash' > /usr/bin/google-chrome-stable
echo 'exec /opt/google/chrome/chrome --no-sandbox --test-type --load-extension=~/.config/google-chrome/Default/Extensions/padekgcemlokbadohgkifijomclgjgif/2.5.21_0/ "$@"' >> /usr/bin/google-chrome-stable
chmod +x /usr/bin/google-chrome-stable
