#!/bin/bash

# Exit on any error
set -e

echo "Starting Antigravity IDE upgrade process..."

# Stop Antigravity if it's running
echo "Stopping any running Antigravity instances..."
pgrep -f "^/usr/share/antigravity/" | grep -v "^$$\$" | xargs -r kill || true

# Fetch latest Antigravity IDE release metadata from official updater API
echo "Fetching latest Antigravity IDE release information..."
RELEASE_JSON=$(curl -fsSL "https://antigravity-ide-auto-updater-974169037036.us-central1.run.app/releases")
VERSION=$(echo "$RELEASE_JSON" | jq -r '.[0].version')
EXEC_ID=$(echo "$RELEASE_JSON" | jq -r '.[0].execution_id')
DOWNLOAD_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/${VERSION}-${EXEC_ID}/linux-x64/Antigravity%20IDE.tar.gz"

echo "Downloading Antigravity IDE ${VERSION} (${EXEC_ID})..."
curl -fsSL "$DOWNLOAD_URL" -o /tmp/antigravity-ide.tar.gz

echo "Installing Antigravity IDE ${VERSION} to /usr/share/antigravity..."
rm -rf /tmp/antigravity-ide-extract
mkdir -p /tmp/antigravity-ide-extract
tar -xzf /tmp/antigravity-ide.tar.gz -C /tmp/antigravity-ide-extract --strip-components=1
rm -rf /usr/share/antigravity
mv /tmp/antigravity-ide-extract /usr/share/antigravity
rm -f /tmp/antigravity-ide.tar.gz

# Create compatibility symlinks and desktop icon
ln -sf /usr/share/antigravity/bin/antigravity-ide /usr/share/antigravity/bin/antigravity
ln -sf /usr/share/antigravity/antigravity-ide /usr/share/antigravity/antigravity
ln -sf /usr/share/antigravity/bin/antigravity-ide /usr/bin/antigravity
ln -sf /usr/share/antigravity/bin/antigravity-ide /usr/bin/antigravity-ide
if [ -f /usr/share/antigravity/resources/app/resources/linux/code.png ]; then
    cp -f /usr/share/antigravity/resources/app/resources/linux/code.png /usr/share/pixmaps/antigravity.png
fi

# Update the agy CLI backend binary
echo "Updating agy CLI backend..."
if id "coder" >/dev/null 2>&1; then
    su - coder -c "curl -fsSL https://antigravity.google/cli/install.sh | bash -s -- --dir /home/coder/.gemini/bin"
    ln -sf /home/coder/.gemini/bin/agy /usr/local/bin/agy
else
    curl -fsSL https://antigravity.google/cli/install.sh | bash -s -- --dir /usr/local/bin
fi

echo "Antigravity IDE ${VERSION} upgrade completed successfully!"
