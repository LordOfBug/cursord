#!/bin/bash

# Function to get latest Cursor version from changelog
get_latest_cursor_version() {
    # Send status messages to stderr so they don't get captured in VERSION
    echo "Fetching latest version from Cursor changelog..." >&2
    
    # Fetch the changelog page
    local changelog=$(curl -s -L https://www.cursor.com/changelog)
    
    # Extract version - looking for pattern like 'uppercase">0.46<'
    local version=$(echo "$changelog" | grep -o 'uppercase">[0-9]\+\.[0-9]\+<' | head -n 1 | sed 's/uppercase">//;s/<$//' | tr -d '\n\r')
    
    if [ -z "$version" ]; then
        echo "Failed to extract version from changelog" >&2
        return 1
    fi
    
    # Send status message to stderr
    echo "Found version: $version" >&2
    
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
docker build -t "$FULL_TAG" .

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "Successfully built $FULL_TAG"
else
    echo "Failed to build $FULL_TAG"
    exit 1
fi 