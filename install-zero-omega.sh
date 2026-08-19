#!/bin/bash

# ZeroOmega Proxy Extension Auto-Installation Script for Microsoft Edge
# This script configures Microsoft Edge to automatically install the ZeroOmega extension
# using Edge's enterprise policy system (ExtensionInstallForcelist)

echo "=========================================="
echo "ZeroOmega Extension Auto-Install for Edge"
echo "=========================================="
echo ""
echo "This script will configure Microsoft Edge to automatically install"
echo "the ZeroOmega proxy extension on every startup."
echo ""

# Step 1: Check for required tools
if ! command -v curl &> /dev/null; then
    echo "Error: 'curl' is required but not found."
    echo "Please install it: sudo apt update && sudo apt install curl"
    exit 1
fi

# Step 2: Get the ZeroOmega extension ID from Edge Add-ons store
# The ZeroOmega extension ID in Edge Add-ons store
EXTENSION_ID="fnbemgdobbciiofjfaoaajboakejkdbo"
UPDATE_URL="https://edge.microsoft.com/extensionwebstorebase/v1/crx"

echo "Extension ID: $EXTENSION_ID"
echo "Update URL: $UPDATE_URL"
echo ""

# Step 3: Create Edge policies directory
POLICIES_DIR="/etc/opt/edge/policies/managed"
echo "Creating Edge policies directory: $POLICIES_DIR"
mkdir -p "$POLICIES_DIR"

# Step 4: Create policies.json with ExtensionInstallForcelist
POLICIES_FILE="$POLICIES_DIR/policies.json"
echo "Creating policy file: $POLICIES_FILE"

tee "$POLICIES_FILE" > /dev/null << EOF
{
  "ExtensionInstallForcelist": [
    "${EXTENSION_ID};${UPDATE_URL}"
  ],
  "ExtensionSettings": {
    "${EXTENSION_ID}": {
      "installation_mode": "force_installed",
      "update_url": "${UPDATE_URL}"
    }
  }
}
EOF

# Verify the file was created
if [ -f "$POLICIES_FILE" ]; then
    echo ""
    echo "✅ Policy file created successfully!"
    echo ""
    echo "Content of $POLICIES_FILE:"
    echo "----------------------------------------"
    cat "$POLICIES_FILE"
    echo "----------------------------------------"
    echo ""
    echo "✅ ZeroOmega extension will be automatically installed"
    echo "   when Microsoft Edge starts!"
    echo ""
    echo "🔒 The extension is force-installed and cannot be removed by users."
    echo "   This ensures it's always available for proxy configuration."
    echo ""
    echo "📝 Note: The extension will be downloaded from Microsoft Edge Add-ons"
    echo "   store on first launch and kept up-to-date automatically."
    echo ""
    echo "🚀 To apply: Start or restart Microsoft Edge"
    echo ""
    echo "✓ You can verify the extension is installed by visiting:"
    echo "  edge://extensions"
    echo ""
else
    echo "❌ Error: Failed to create policy file."
    exit 1
fi

# Step 5: Set proper permissions
chmod 644 "$POLICIES_FILE"
echo "✅ Permissions set correctly (644)"

echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
