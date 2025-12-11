#!/bin/bash
# Transparent Proxy Setup Script
# This script sets up redsocks and iptables for transparent proxying
# when a valid /etc/redsocks.conf file is mounted into the container.
#
# Usage:
#   1. Create a redsocks.conf file on the host
#   2. Mount it: docker run -v /path/to/redsocks.conf:/etc/redsocks.conf ...
#   3. Add NET_ADMIN capability: docker run --cap-add=NET_ADMIN ...

set -e

REDSOCKS_CONF="/etc/redsocks.conf"
REDSOCKS_PORT="${REDSOCKS_PORT:-12345}"

setup_transparent_proxy() {
    echo ">> Transparent Proxy Mode ENABLED"
    echo "   - Config file: $REDSOCKS_CONF"

    # Check if we have permission to modify network rules
    if ! iptables -L >/dev/null 2>&1; then
        echo ""
        echo "========================================================"
        echo "ERROR: redsocks.conf found, but 'iptables' failed."
        echo ""
        echo "You must run the container with '--cap-add=NET_ADMIN'"
        echo ""
        echo "Example:"
        echo "  docker run --cap-add=NET_ADMIN \\"
        echo "    -v /path/to/redsocks.conf:/etc/redsocks.conf \\"
        echo "    your-image-name"
        echo "========================================================"
        echo ""
        exit 1
    fi

    # Extract the local port from config (default to 12345 if not found)
    if grep -q "local_port" "$REDSOCKS_CONF"; then
        REDSOCKS_PORT=$(grep "local_port" "$REDSOCKS_CONF" | head -1 | sed 's/.*=\s*\([0-9]*\).*/\1/')
        echo "   - Redsocks local port: $REDSOCKS_PORT"
    fi

    # Extract proxy server info for display (optional, just for logging)
    if grep -q "^[[:space:]]*ip\s*=" "$REDSOCKS_CONF"; then
        PROXY_IP=$(grep "^[[:space:]]*ip\s*=" "$REDSOCKS_CONF" | head -1 | sed 's/.*=\s*\([^;]*\).*/\1/' | tr -d ' "')
        PROXY_PORT=$(grep "^[[:space:]]*port\s*=" "$REDSOCKS_CONF" | head -1 | sed 's/.*=\s*\([0-9]*\).*/\1/')
        echo "   - Proxy server: $PROXY_IP:$PROXY_PORT"
    fi

    # Start redsocks daemon
    echo ">> Starting redsocks daemon..."
    redsocks -c "$REDSOCKS_CONF"

    # Wait a moment for redsocks to start
    sleep 1

    # Check if redsocks is running
    if ! pgrep -x redsocks > /dev/null; then
        echo "ERROR: redsocks failed to start. Check configuration in $REDSOCKS_CONF"
        exit 1
    fi
    echo "   - redsocks started successfully"

    # Apply iptables rules
    echo ">> Applying iptables NAT rules..."

    # Create REDSOCKS chain
    iptables -t nat -N REDSOCKS 2>/dev/null || iptables -t nat -F REDSOCKS

    # Ignore local/private network traffic (don't proxy these)
    iptables -t nat -A REDSOCKS -d 0.0.0.0/8 -j RETURN
    iptables -t nat -A REDSOCKS -d 10.0.0.0/8 -j RETURN
    iptables -t nat -A REDSOCKS -d 127.0.0.0/8 -j RETURN
    iptables -t nat -A REDSOCKS -d 169.254.0.0/16 -j RETURN
    iptables -t nat -A REDSOCKS -d 172.16.0.0/12 -j RETURN
    iptables -t nat -A REDSOCKS -d 192.168.0.0/16 -j RETURN
    iptables -t nat -A REDSOCKS -d 224.0.0.0/4 -j RETURN
    iptables -t nat -A REDSOCKS -d 240.0.0.0/4 -j RETURN

    # Exclude the proxy server itself to avoid infinite loops
    if [ -n "$PROXY_IP" ]; then
        iptables -t nat -A REDSOCKS -d "$PROXY_IP" -j RETURN
    fi

    # Redirect HTTP and HTTPS traffic to redsocks
    iptables -t nat -A REDSOCKS -p tcp --dport 80 -j REDIRECT --to-ports "$REDSOCKS_PORT"
    iptables -t nat -A REDSOCKS -p tcp --dport 443 -j REDIRECT --to-ports "$REDSOCKS_PORT"

    # Optionally redirect all TCP traffic (uncomment if needed)
    # iptables -t nat -A REDSOCKS -p tcp -j REDIRECT --to-ports "$REDSOCKS_PORT"

    # Apply the REDSOCKS chain to all outgoing traffic
    iptables -t nat -A OUTPUT -p tcp -j REDSOCKS

    echo ">> Transparent Proxy is ACTIVE"
    echo ""
}

# Main execution
# Check if redsocks.conf exists and is a valid file (not empty)
if [ -f "$REDSOCKS_CONF" ] && [ -s "$REDSOCKS_CONF" ]; then
    setup_transparent_proxy
else
    echo ">> Transparent Proxy Mode DISABLED (no $REDSOCKS_CONF mounted)"
fi
