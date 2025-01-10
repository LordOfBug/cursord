#!/bin/bash

# Function to get the current X display
get_display() {
    # First try the environment variable
    if [ -n "$DISPLAY" ]; then
        echo "$DISPLAY"
        return
    fi
    
    # Try getting from xrdp session
    local xrdp_display=$(ps aux | grep "[X]org.*:[0-9]" | grep -v "grep" | head -1 | grep -o ':[0-9.]*')
    if [ -n "$xrdp_display" ]; then
        echo "$xrdp_display"
        return
    fi
    
    # Default to :0 if nothing found
    echo ":0"
}

# Set display
export DISPLAY=$(get_display)
export APPDIR=/home/cursor

echo "Using DISPLAY=$DISPLAY"

# Wait for X server to be ready
for i in $(seq 1 10); do
    if DISPLAY=$DISPLAY xhost + >/dev/null 2>&1; then
        break
    fi
    echo "Waiting for X server... ($i/10)"
    sleep 1
done

# Set up dbus session
export $(dbus-launch)
export DBUS_SESSION_BUS_ADDRESS="unix:path=/var/run/dbus/system_bus_socket"

# Set proper permissions
DISPLAY=$DISPLAY xhost +local:
DISPLAY=$DISPLAY xhost +SI:localuser:cursor

# Debug information
echo "Current working directory: $(pwd)"
echo "DISPLAY: $DISPLAY"
echo "DBUS_SESSION_BUS_ADDRESS: $DBUS_SESSION_BUS_ADDRESS"
echo "XAUTHORITY: $XAUTHORITY"

# Run the AppImage directly with extract option if FUSE fails
cd ${APPDIR}
if ! ./cursor.app ${CHROME_FLAGS} 2>&1; then
    echo "FUSE mount failed, extracting AppImage..."
    ./cursor.app --appimage-extract
    cd squashfs-root
    exec ./AppRun ${CHROME_FLAGS} 2>&1 | tee /tmp/cursor.log
fi
