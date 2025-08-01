# Announce the script's purpose and thank the user for the better method
echo "This script will download the LATEST release of 'ZeroOmega' directly"
echo "from the official GitHub releases page. This is the best method."
echo "------------------------------------------------------------------"

# Step 1: Check for required tools
if ! command -v curl &> /dev/null
then
    echo "Error: 'curl' is required to run this script."
    echo "Please install it first by running: sudo apt update && sudo apt install curl"
    exit 1
fi

# Step 2: Dynamically find the latest version tag
echo "Finding the latest release version..."
# Use curl to follow redirects (-L) and get the final URL (-w '%{url_effective}').
# The last part of the URL will be the version tag.
LATEST_TAG=$(curl -s -L -o /dev/null -w '%{url_effective}' https://github.com/zero-peak/ZeroOmega/releases/latest | xargs basename)

if [ -z "$LATEST_TAG" ]; then
    echo "Error: Could not determine the latest release tag. Please check the GitHub page."
    exit 1
fi

echo "Latest version found: $LATEST_TAG"

# Step 3: Construct the download URL and download the .crx file
CRX_URL="https://github.com/zero-peak/ZeroOmega/releases/download/${LATEST_TAG}/zeroomega-${LATEST_TAG}.crx"
DEST_FILE="$HOME/zeroomega-${LATEST_TAG}.crx"

echo "Downloading CRX file from: $CRX_URL"
curl -L --progress-bar -o "$DEST_FILE" "$CRX_URL"
if [ $? -ne 0 ]; then
    echo "Error: Failed to download the CRX file."
    exit 1
fi

echo "Extracting to .zeroomega"
mkdir .zeroomega
cd .zeroomega
unzip "$DEST_FILE"
rm "$DEST_FILE"

# Step 4: Provide clear instructions for installing a .crx file
echo
echo "��� Download complete!"
echo "File extract to $HOME/.zeroomega"
echo
echo "------------------------------------------------------------------"
echo "IMPORTANT: FINAL INSTALLATION STEPS"
echo "------------------------------------------------------------------"
echo "1. Open Google Chrome and go to the extensions page:"
echo "   chrome://extensions"
echo
echo "2. Click Load unpacked and choose $HOME/.zeroomega"
echo
echo "3. A confirmation dialog will appear. Click 'Add extension'."
echo "------------------------------------------------------------------"
