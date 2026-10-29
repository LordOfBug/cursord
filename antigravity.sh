#!/bin/bash

# Ensure D-Bus session bus is available
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax)
fi

PROXY_FLAG=""
if [ -n "$ALL_PROXY" ]; then
    PROXY_FLAG="--proxy-server=$ALL_PROXY"
elif [ -n "$http_proxy" ]; then
    PROXY_FLAG="--proxy-server=$http_proxy"
fi

# start app
exec /usr/bin/antigravity $PROXY_FLAG --no-sandbox --disable-gpu --password-store=basic --disable-dev-shm-usage "$@"
