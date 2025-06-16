#!/bin/bash
#
# This script pre-installs specified Chrome extensions for an offline environment.
# It works by downloading the extension packages, unzipping them, and placing
# them in the correct directory structure within the user's Chrome profile.
#
# It fixes the "Missing manifest" error by:
# 1. NOT manually creating the fragile 'Preferences' file.
# 2. Automatically reading the correct version from the extension's manifest.json
#    to create the correct directory name, which Chrome expects.
#

# --- PRE-REQUISITES ---
# This script uses 'jq' to parse JSON. Ensure it is installed.
if ! command -v jq &> /dev/null
then
    echo "jq could not be found. Please install it first."
    echo "For Debian/Ubuntu: sudo apt-get update && sudo apt-get install -y jq"
    exit 1
fi

echo "--- Setting up Chrome extension pre-installation ---"

# --- CONFIGURATION ---
CHROME_EXT_PATH="/home/coder/.config/google-chrome/Default/Extensions"

# Extension Definitions
UBLOCK_ID="cjpalhdlnbpafiamejdnhcphjbkeiagm"
DARKREADER_ID="eimadpbcbfnmbkopoojfekhnkhdbieeh"
ZEROOMEGA_ID="pfnededegaaopdmhkdmcofjmoldfiped"

# --- SCRIPT LOGIC ---

# Create the base extensions directory
mkdir -p "${CHROME_EXT_PATH}"

# --- Function to install an extension from a ZIP URL ---
install_from_zip() {
    local id="$1"
    local url="$2"
    local name="$3"
    local tmp_zip="/tmp/${name}.zip"
    local tmp_unzip_dir="/tmp/${name}_ext"

    echo "--> Installing ${name} (${id})"

    # 1. Download the extension package
    echo "    Downloading from ${url}..."
    curl -L --retry 3 "${url}" -o "${tmp_zip}"
    if [ ! -s "${tmp_zip}" ]; then
        echo "    ERROR: Failed to download ${name}. Aborting."
        return 1
    fi

    # 2. Unzip to a temporary directory
    rm -rf "${tmp_unzip_dir}"
    mkdir -p "${tmp_unzip_dir}"
    unzip -o -q "${tmp_zip}" -d "${tmp_unzip_dir}"

    # 3. Find the manifest file to get the version
    local manifest_path
    manifest_path=$(find "${tmp_unzip_dir}" -name "manifest.json" | head -n 1)
    if [ -z "${manifest_path}" ]; then
        echo "    ERROR: manifest.json not found for ${name}. Cannot proceed."
        return 1
    fi

    # 4. **CRITICAL STEP**: Read the version directly from the manifest
    local version
    version=$(jq -r '.version' "${manifest_path}")
    if [ -z "${version}" ] || [ "${version}" == "null" ]; then
        echo "    ERROR: Could not read version from manifest for ${name}."
        return 1
    fi
    echo "    Detected version: ${version}"

    # 5. Create the final, correctly named directory and copy files
    local final_ext_path="${CHROME_EXT_PATH}/${id}/${version}"
    mkdir -p "${final_ext_path}"
    # The source directory is the one containing the manifest.json
    local source_dir
    source_dir=$(dirname "${manifest_path}")
    cp -r "${source_dir}"/* "${final_ext_path}/"

    # 6. Verify and clean up
    if [ -f "${final_ext_path}/manifest.json" ]; then
        echo "    SUCCESS: ${name} v${version} installed successfully."
    else
        echo "    ERROR: Final verification failed for ${name}."
    fi
    rm -f "${tmp_zip}"
    rm -rf "${tmp_unzip_dir}"
}

# --- Function to install an extension from a CRX file ---
# Note: CRX files are essentially zip files with a header.
install_from_crx() {
    local id="$1"
    local url="$2"
    local name="$3"
    local tmp_crx="/tmp/${name}.crx"

    echo "--> Installing ${name} (${id}) from CRX"
    # The zip installation logic can handle CRX files if they are just renamed.
    # We download as .crx and rename to .zip for the generic function.
    curl -L --retry 3 "${url}" -o "${tmp_crx}"
    if [ ! -s "${tmp_crx}" ]; then
        echo "    ERROR: Failed to download ${name}. Aborting."
        return 1
    fi

    # Rename to .zip and use the zip installer function
    mv "${tmp_crx}" "/tmp/${name}.zip"
    install_from_zip "$id" "file:///tmp/${name}.zip" "$name"
}


# --- Install each extension ---
install_from_zip "${UBLOCK_ID}" "https://github.com/gorhill/uBlock/releases/download/1.52.2/uBlock0_1.52.2.chromium.zip" "uBlockOrigin"
install_from_zip "${DARKREADER_ID}" "https://github.com/darkreader/darkreader/releases/download/v4.9.67/darkreader-chrome.zip" "DarkReader"
# Note: GitHub doesn't have a ZIP for ZeroOmega, so we use a CRX converter site URL or a self-hosted ZIP if available.
# Let's try downloading the CRX and treating it as a ZIP. Many CRX files are ZIP compatible.
install_from_crx "${ZEROOMEGA_ID}" "https://github.com/zero-peak/ZeroOmega/releases/download/3.3.23/zeroomega-3.3.23.crx" "ZeroOmega"


# --- Finalization ---
# Set correct permissions for the user's config directory
echo "--- Finalizing permissions ---"
chown -R coder:coder /home/coder/.config

echo "--- Chrome extension setup complete ---"

