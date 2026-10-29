#!/bin/bash
# Main container entrypoint
# Sets up transparent proxy if enabled, then starts supervisord

set -e

echo "========================================"
echo "  Container Startup"
echo "========================================"

# Setup proxy if enabled
source /usr/local/bin/proxy-setup.sh

echo ">> Starting supervisord..."

# Execute supervisord (the original entrypoint)
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
