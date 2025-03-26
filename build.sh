#!/bin/bash

# Function to get latest Cursor version from cursor-ai-downloads
get_latest_cursor_version() {
    echo "Fetching latest version from cursor-ai-downloads..." >&2
    
    # Fetch the latest version info from cursor-ai-downloads
    local version_info=$(curl -s -L "https://raw.githubusercontent.com/oslook/cursor-ai-downloads/main/version-history.json")
    
    if [ -z "$version_info" ]; then
        echo "Failed to fetch version info" >&2
        return 1
    fi

    # Extract the latest version (first version in the list)
    local version=$(echo "$version_info" | grep -o '"version": "[0-9.]*"' | head -n 1 | cut -d'"' -f4)
    
    if [ -z "$version" ]; then
        echo "Failed to extract version from version info" >&2
        return 1
    fi
    
    # Extract download URL
    local download_url=$(echo "$version_info" | grep -o '"linux-x64": "[^"]*"' | head -n 1 | cut -d'"' -f4)
    if [ -z "$download_url" ]; then
        echo "Failed to extract download URL" >&2
        return 1
    fi
    
    # Export the download URL for use in docker build
    export CURSOR_DOWNLOAD_URL="$download_url"
    
    # Send status message to stderr
    echo "Found version: $version" >&2
    echo "Download URL: $download_url" >&2
    
    # Only output the version number itself to stdout
    echo -n "$version"
}

# Get the version - either from command line argument or fetch latest
if [ -z "$1" ]; then
    VERSION=$(get_latest_cursor_version)
    if [ $? -ne 0 ]; then
        echo "Failed to get latest version"
        exit 1
    fi
    echo "No version specified, using latest version: $VERSION"
else
    VERSION=$1
    echo "Using specified version: $VERSION"
fi

# Validate version format
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Invalid version format. Expected format: X.Y (e.g., 0.46)"
    echo "Debug: VERSION='${VERSION}'"
    echo "Debug: length=$(echo -n "$VERSION" | wc -c)"
    exit 1
fi

# Build the Docker image
IMAGE_NAME="cursord"
TAG="v${VERSION}"
FULL_TAG="${IMAGE_NAME}:${TAG}"

echo "Building Docker image: $FULL_TAG"
docker build -t "$FULL_TAG" --build-arg CURSOR_DOWNLOAD_URL="$CURSOR_DOWNLOAD_URL" .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Successfully built $FULL_TAG"
else
    echo "Failed to build $FULL_TAG"
    exit 1
fi 