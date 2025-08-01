# Announce the script's purpose and automatic installation
echo "This script will download and automatically install the LATEST release of 'ZeroOmega'"
echo "directly from the official GitHub releases page into Microsoft Edge."
echo "------------------------------------------------------------------"

# Step 1: Check for required tools
# Try different curl locations
CURL_CMD=""
if command -v curl &> /dev/null; then
    CURL_CMD="curl"
elif [ -x "/usr/bin/curl" ]; then
    CURL_CMD="/usr/bin/curl"
elif [ -x "/bin/curl" ]; then
    CURL_CMD="/bin/curl"
else
    echo "Error: 'curl' is required to run this script."
    echo "Please install it first by running: sudo apt update && sudo apt install curl"
    echo "Searched in: $(which curl 2>/dev/null || echo 'not found'), /usr/bin/curl, /bin/curl"
    exit 1
fi

echo "Using curl from: $CURL_CMD"

# Step 2: Dynamically find the latest version tag
echo "Finding the latest release version..."
# Use curl to follow redirects (-L) and get the final URL (-w '%{url_effective}').
# The last part of the URL will be the version tag.
LATEST_TAG=$($CURL_CMD -s -L -o /dev/null -w '%{url_effective}' https://github.com/zero-peak/ZeroOmega/releases/latest | xargs basename)

if [ -z "$LATEST_TAG" ]; then
    echo "Error: Could not determine the latest release tag. Please check the GitHub page."
    exit 1
fi

echo "Latest version found: $LATEST_TAG"

# Step 3: Construct the download URL and download the .crx file
CRX_URL="https://github.com/zero-peak/ZeroOmega/releases/download/${LATEST_TAG}/zeroomega-${LATEST_TAG}.crx"
DEST_FILE="$HOME/zeroomega-${LATEST_TAG}.crx"

echo "Downloading CRX file from: $CRX_URL"
$CURL_CMD -L --progress-bar -o "$DEST_FILE" "$CRX_URL"
if [ $? -ne 0 ]; then
    echo "Error: Failed to download the CRX file."
    exit 1
fi

echo "Extracting extension..."
EXT_DIR="$HOME/.zeroomega"
mkdir -p "$EXT_DIR"
cd "$EXT_DIR"
unzip -q "$DEST_FILE"
rm "$DEST_FILE"

# Step 4: Automatically install extension in Microsoft Edge
echo
echo "✅ Download and extraction complete!"
echo "Installing ZeroOmega extension automatically in Microsoft Edge..."
echo

# Create Edge extensions directory if it doesn't exist
EDGE_EXT_DIR="$HOME/.config/microsoft-edge/Default/Extensions"
mkdir -p "$EDGE_EXT_DIR"

# Get extension ID from manifest.json
if [ -f "$EXT_DIR/manifest.json" ]; then
    # Generate a consistent extension ID based on the extension's public key or name
    # For ZeroOmega, we'll use a known extension ID or generate one
    EXT_ID="padekgcemlokbadohgkifijomclgjgif"  # ZeroOmega's known extension ID
    
    # Create extension directory in Edge profile
    EDGE_EXT_INSTALL_DIR="$EDGE_EXT_DIR/$EXT_ID"
    mkdir -p "$EDGE_EXT_INSTALL_DIR/$LATEST_TAG"
    
    # Copy extension files to Edge extensions directory
    cp -r "$EXT_DIR"/* "$EDGE_EXT_INSTALL_DIR/$LATEST_TAG/"
    
    # Create Edge preferences to enable the extension
    EDGE_PREFS="$HOME/.config/microsoft-edge/Default/Preferences"
    mkdir -p "$(dirname "$EDGE_PREFS")"
    
    # Create or update preferences file to include the extension
    if [ ! -f "$EDGE_PREFS" ]; then
        cat > "$EDGE_PREFS" << EOF
{
   "extensions": {
      "settings": {
         "$EXT_ID": {
            "active_permissions": {
               "api": [ "proxy", "storage", "webRequest", "webRequestBlocking", "tabs", "activeTab" ],
               "explicit_host": [ "<all_urls>" ]
            },
            "creation_flags": 1,
            "from_webstore": false,
            "install_time": "$(date -u +%s)000000",
            "location": 4,
            "manifest": {
               "name": "ZeroOmega",
               "version": "${LATEST_TAG#v}"
            },
            "path": "$EXT_ID/$LATEST_TAG",
            "state": 1,
            "was_installed_by_default": false,
            "was_installed_by_oem": false
         }
      }
   }
}
EOF
    fi
    
    echo "✅ ZeroOmega extension has been automatically installed in Microsoft Edge!"
    echo "The extension will be available when you start Microsoft Edge."
    echo "Extension installed to: $EDGE_EXT_INSTALL_DIR/$LATEST_TAG"
else
    echo "❌ Error: Could not find manifest.json in extracted files."
    echo "Manual installation may be required."
    echo "Extension files are available at: $EXT_DIR"
fi

echo "------------------------------------------------------------------"
echo "Installation complete! Start Microsoft Edge to use ZeroOmega."
echo "------------------------------------------------------------------"
