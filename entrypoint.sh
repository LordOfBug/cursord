#!/bin/bash
# Main container entrypoint
# Sets up transparent proxy if enabled, then starts supervisord

set -e

echo "========================================"
echo "  Container Startup"
echo "========================================"

# Setup proxy if enabled
source /usr/local/bin/proxy-setup.sh

# Start system D-Bus daemon if not running
if [ ! -S /run/dbus/system_bus_socket ]; then
    mkdir -p /run/dbus /var/run/dbus
    service dbus start 2>/dev/null || dbus-daemon --system --fork 2>/dev/null || true
fi

echo ">> Starting supervisord..."

# Execute supervisord (the original entrypoint)
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
