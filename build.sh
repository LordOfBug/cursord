#!/bin/bash

# Function to get latest Antigravity version
get_latest_antigravity_version() {
    echo "Using latest Antigravity version..." >&2
    
    # Hardcoded for now as there is no version API
    local download_url="https://antigravity.google/download/linux"
    local version="latest"
    
    # Export the download URL for use in docker build
    export ANTIGRAVITY_DOWNLOAD_URL="$download_url"
    
    # Send status message to stderr
    echo "Found version: $version" >&2
    echo "Download URL: $download_url" >&2
    
    # Only output the version number itself to stdout
    echo -n "$version"
}

# Get the version - either from command line argument or fetch latest
if [ -z "$1" ]; then
    VERSION=$(get_latest_antigravity_version)
    if [ $? -ne 0 ]; then
        echo "Failed to get latest version"
        exit 1
    fi
    echo "No version specified, using latest version: $VERSION"
else
    VERSION=$1
    echo "Using specified version: $VERSION"
fi

# Build the Docker image
IMAGE_NAME="cursord"
TAG="v${VERSION}"
FULL_TAG="${IMAGE_NAME}:${TAG}"

echo "Building Docker image: $FULL_TAG"
docker build -t "$FULL_TAG" --build-arg ANTIGRAVITY_DOWNLOAD_URL="$ANTIGRAVITY_DOWNLOAD_URL" .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Successfully built $FULL_TAG"
else
    echo "Failed to build $FULL_TAG"
    exit 1
fi 