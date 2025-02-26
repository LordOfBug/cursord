#!/bin/bash

# Function to get latest Cursor version from GitHub
get_latest_cursor_version() {
    # Fetch the latest release version from GitHub API
    local version=$(curl -s https://api.github.com/repos/getcursor/cursor/releases/latest | grep -o '"tag_name": *"[^"]*"' | grep -o '[0-9.]*')
    if [ -z "$version" ]; then
        echo "Error: Could not fetch version from GitHub" >&2
        exit 1
    fi
    echo "$version"
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
    exit 1
fi

# Build the Docker image
IMAGE_NAME="cursord"
TAG="v${VERSION}"
FULL_TAG="${IMAGE_NAME}:${TAG}"

echo "Building Docker image: $FULL_TAG"
docker build -t "$FULL_TAG" .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Successfully built $FULL_TAG"
else
    echo "Failed to build $FULL_TAG"
    exit 1
fi 