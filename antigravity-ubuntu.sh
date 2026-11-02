#!/bin/bash

# Set environment variables for Chinese text rendering and locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export FONTCONFIG_PATH=/etc/fonts

# Ensure D-Bus session bus is available (prevents Electron hanging on SecretStorage)
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax)
fi

# Disable accessibility bus warnings
export NO_AT_BRIDGE=1

# Bypass TLS certificate expiration errors for Node.js / Language Server HTTP2 session
export NODE_TLS_REJECT_UNAUTHORIZED=0

# Ensure ~/.gemini/bin is in PATH for the agy backend binary
export PATH="$HOME/.gemini/bin:/usr/local/bin:$PATH"

# Start app with stability flags for containerized environment
exec /usr/bin/antigravity \
    --no-sandbox \
    --disable-gpu \
    --disable-gpu-compositing \
    --use-gl=swiftshader \
    --password-store=basic \
    --disable-dev-shm-usage \
    --js-flags="--max-old-space-size=4096" \
    "$@"

