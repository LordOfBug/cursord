#!/bin/bash
#
# Pre-installs specified Chrome extensions in offline mode using local or remote ZIP/CRX files.
# Requires: jq, bsdtar

set -e

echo "--- Setting up Chrome extension pre-installation ---"

# --- DEPENDENCY CHECKS ---
for cmd in jq bsdtar curl unzip; do
    if ! command -v $cmd &> /dev/null; then
        echo "Missing dependency: $cmd. Please install it."
        exit 1
    fi
done

# --- CONFIGURATION ---
CHROME_EXT_PATH="/home/coder/.config/google-chrome/Default/Extensions"
mkdir -p "${CHROME_EXT_PATH}"

# Extension Definitions
UBLOCK_ID="cjpalhdlnbpafiamejdnhcphjbkeiagm"
DARKREADER_ID="eimadpbcbfnmbkopoojfekhnkhdbieeh"
ZEROOMEGA_ID="pfnededegaaopdmhkdmcofjmoldfiped"

# --- Install ZIP-Based Extension ---
install_from_zip() {
    local id="$1"
    local url="$2"
    local name="$3"
    local tmp_zip="/tmp/${name}.zip"
    local tmp_unzip_dir="/tmp/${name}_ext"

    echo "--> Installing ${name} (${id}) from ZIP"
    echo "    Downloading from ${url}..."
    curl -L --retry 3 "${url}" -o "${tmp_zip}"
    if [ ! -s "${tmp_zip}" ]; then
        echo "    ERROR: Failed to download ${name}."
        return 1
    fi

    rm -rf "${tmp_unzip_dir}"
    mkdir -p "${tmp_unzip_dir}"
    unzip -o -q "${tmp_zip}" -d "${tmp_unzip_dir}"

    local manifest_path
    manifest_path=$(find "${tmp_unzip_dir}" -name "manifest.json" | head -n 1)
    if [ -z "${manifest_path}" ]; then
        echo "    ERROR: manifest.json not found for ${name}."
        return 1
    fi

    local version
    version=$(jq -r '.version' "${manifest_path}")
    if [ -z "${version}" ] || [ "${version}" == "null" ]; then
        echo "    ERROR: Could not read version from manifest."
        return 1
    fi
    echo "    Detected version: ${version}"

    local final_ext_path="${CHROME_EXT_PATH}/${id}/${version}"
    mkdir -p "${final_ext_path}"
    cp -r "$(dirname "${manifest_path}")"/* "${final_ext_path}/"

    if [ -f "${final_ext_path}/manifest.json" ]; then
        echo "    SUCCESS: ${name} v${version} installed."
    else
        echo "    ERROR: Final verification failed for ${name}."
    fi

    rm -f "${tmp_zip}"
    rm -rf "${tmp_unzip_dir}"
}

# --- Install CRX-Based Extension (with bsdtar) ---
install_from_crx() {
    local id="$1"
    local url="$2"
    local name="$3"
    local tmp_crx="/tmp/${name}.crx"
    local tmp_unzip_dir="/tmp/${name}_ext"

    echo "--> Installing ${name} (${id}) from CRX"
    echo "    Downloading from ${url}..."
    curl -L --retry 3 "${url}" -o "${tmp_crx}"
    if [ ! -s "${tmp_crx}" ]; then
        echo "    ERROR: Failed to download ${name}."
        return 1
    fi

    rm -rf "${tmp_unzip_dir}"
    mkdir -p "${tmp_unzip_dir}"
    bsdtar -xf "${tmp_crx}" -C "${tmp_unzip_dir}"

    local manifest_path
    manifest_path=$(find "${tmp_unzip_dir}" -name "manifest.json" | head -n 1)
    if [ -z "${manifest_path}" ]; then
        echo "    ERROR: manifest.json not found in extracted CRX for ${name}."
        return 1
    fi

    local version
    version=$(jq -r '.version' "${manifest_path}")
    if [ -z "${version}" ] || [ "${version}" == "null" ]; then
        echo "    ERROR: Could not read version from manifest."
        return 1
    fi
    echo "    Detected version: ${version}"

    local final_ext_path="${CHROME_EXT_PATH}/${id}/${version}"
    mkdir -p "${final_ext_path}"
    cp -r "$(dirname "${manifest_path}")"/* "${final_ext_path}/"

    if [ -f "${final_ext_path}/manifest.json" ]; then
        echo "    SUCCESS: ${name} v${version} installed."
    else
        echo "    ERROR: Final verification failed for ${name}."
    fi

    rm -f "${tmp_crx}"
    rm -rf "${tmp_unzip_dir}"
}

# --- Install All Extensions ---
install_from_zip "${UBLOCK_ID}" "https://github.com/gorhill/uBlock/releases/download/1.52.2/uBlock0_1.52.2.chromium.zip" "uBlockOrigin"
install_from_zip "${DARKREADER_ID}" "https://github.com/darkreader/darkreader/releases/download/v4.9.67/darkreader-chrome.zip" "DarkReader"
install_from_crx "${ZEROOMEGA_ID}" "https://github.com/zero-peak/ZeroOmega/releases/download/3.3.23/zeroomega-3.3.23.crx" "ZeroOmega"

# --- Final Permissions ---
echo "--- Finalizing permissions ---"
chown -R coder:coder /home/coder/.config

echo "--- Chrome extension setup complete ---"
