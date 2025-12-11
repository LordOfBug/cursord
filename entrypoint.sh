#!/bin/bash
# Main container entrypoint
# Sets up transparent proxy if enabled, then starts supervisord

set -e

echo "========================================"
echo "  Container Startup"
echo "========================================"

# Setup transparent proxy if enabled
source /usr/local/bin/transparent-proxy.sh

echo ">> Starting supervisord..."

# Execute supervisord (the original entrypoint)
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
