#!/bin/bash
# Proxy Setup Script
# Replaces redsocks with lightweight, userspace proxychains-ng.
# Requires NO special capabilities (no NET_ADMIN, no iptables, no DNS hijacking).
#
# Supported configuration methods:
# 1. Mount config: -v /path/to/proxychains.conf:/etc/proxychains4.conf:ro
# 2. Environment variable: -e PROXY_URL=socks5://192.168.1.50:1080 (or http://...)
# 3. Direct mode (default): No configuration needed; everything connects directly.

PROXYCHAINS_CONF="/etc/proxychains4.conf"
PROXYCHAINS_ALT_CONF="/etc/proxychains.conf"

# Ensure proxychains symlink exists
if [ -f "/usr/bin/proxychains4" ] && [ ! -f "/usr/bin/proxychains" ]; then
    ln -sf /usr/bin/proxychains4 /usr/bin/proxychains
fi

# Create a shell helper alias: 'pc' for quick proxychains execution
cat > /etc/profile.d/proxychains-alias.sh << 'EOF'
alias pc="proxychains4 -q"
EOF
chmod +x /etc/profile.d/proxychains-alias.sh

# Also ensure alias is present in bash.bashrc for non-login interactive shells
if [ -f /etc/bash.bashrc ] && ! grep -q 'alias pc=' /etc/bash.bashrc; then
    echo "alias pc='proxychains4 -q'" >> /etc/bash.bashrc
fi

# Ensure default Tor placeholder from Debian/Ubuntu package is disabled if present
if [ -f "$PROXYCHAINS_CONF" ]; then
    sed -i 's/^[[:space:]]*socks4[[:space:]]\+127\.0\.0\.1[[:space:]]\+9050/# socks4 127.0.0.1 9050/' "$PROXYCHAINS_CONF" 2>/dev/null || true
fi

# Check if an alternative config was mounted at /etc/proxychains.conf
if [ -f "$PROXYCHAINS_ALT_CONF" ] && [ ! -L "$PROXYCHAINS_CONF" ] && [ "$PROXYCHAINS_ALT_CONF" != "$PROXYCHAINS_CONF" ]; then
    cp "$PROXYCHAINS_ALT_CONF" "$PROXYCHAINS_CONF"
fi

# Handle PROXY_URL environment variable if set (e.g. socks5://user:pass@host:port or socks5://host:port)
if [ -n "$PROXY_URL" ] || [ -n "$PROXY_SERVER" ]; then
    TARGET_PROXY="${PROXY_URL:-$PROXY_SERVER}"
    echo ">> Configuring proxy from environment variable: $TARGET_PROXY"

    # Parse protocol, credentials, host, and port
    PROTO=$(echo "$TARGET_PROXY" | sed -E 's|^([^:]+)://.*|\1|')
    REMAINDER=$(echo "$TARGET_PROXY" | sed -E 's|^[^:]+://||')

    USER_PASS=""
    HOST_PORT=""
    if echo "$REMAINDER" | grep -q "@"; then
        USER_PASS=$(echo "$REMAINDER" | sed -E 's|@.*||')
        HOST_PORT=$(echo "$REMAINDER" | sed -E 's|.*@||')
        USER=$(echo "$USER_PASS" | cut -d: -f1)
        PASS=$(echo "$USER_PASS" | cut -d: -f2)
    else
        HOST_PORT="$REMAINDER"
    fi

    HOST=$(echo "$HOST_PORT" | cut -d: -f1)
    PORT=$(echo "$HOST_PORT" | cut -d: -f2 | tr -d '/')

    cat > "$PROXYCHAINS_CONF" << EOF
strict_chain
proxy_dns
tcp_read_time_out 15000
tcp_connect_time_out 8000

[ProxyList]
$PROTO $HOST $PORT $USER $PASS
EOF
fi

# Check if a valid, non-placeholder proxy is configured in proxychains
ACTIVE_PROXY_LINE=""
if [ -f "$PROXYCHAINS_CONF" ]; then
    ACTIVE_PROXY_LINE=$(grep -v '^[[:space:]]*#' "$PROXYCHAINS_CONF" | grep -v '^\[' | grep -E '^[[:space:]]*(socks4|socks5|http)' | grep -v '127\.0\.0\.1[[:space:]]\+9050' | tail -1)
fi

if [ -n "$ACTIVE_PROXY_LINE" ]; then
    TYPE=$(echo "$ACTIVE_PROXY_LINE" | awk '{print $1}')
    IP=$(echo "$ACTIVE_PROXY_LINE" | awk '{print $2}')
    PORT=$(echo "$ACTIVE_PROXY_LINE" | awk '{print $3}')
    USER=$(echo "$ACTIVE_PROXY_LINE" | awk '{print $4}')
    PASS=$(echo "$ACTIVE_PROXY_LINE" | awk '{print $5}')

    if [ -n "$USER" ] && [ -n "$PASS" ]; then
        PROXY_URI="${TYPE}://${USER}:${PASS}@${IP}:${PORT}"
    else
        PROXY_URI="${TYPE}://${IP}:${PORT}"
    fi

    echo ">> ProxyChains active: $PROXY_URI"
    echo "   - Run any command through proxy using: pc <command> (e.g. pc git clone ...)"

    # Only export global HTTP_PROXY/HTTPS_PROXY if explicitly requested via environment variable.
    # This preserves fine-grained control so browsers and system tools run directly by default.
    if [ -n "$PROXY_URL" ] || [ -n "$PROXY_SERVER" ] || [ "$EXPORT_PROXY_ENV" = "true" ]; then
        echo "   - Global environment proxy enabled (EXPORT_PROXY_ENV=true)"
        cat > /etc/profile.d/proxy-env.sh << EOF
export http_proxy="$PROXY_URI"
export https_proxy="$PROXY_URI"
export all_proxy="$PROXY_URI"
export HTTP_PROXY="$PROXY_URI"
export HTTPS_PROXY="$PROXY_URI"
export ALL_PROXY="$PROXY_URI"
export no_proxy="localhost,127.0.0.1,::1,*.local"
export NO_PROXY="localhost,127.0.0.1,::1,*.local"
EOF
        chmod +x /etc/profile.d/proxy-env.sh
    fi
else
    # Clean up any stale environment proxy files from previous runs
    rm -f /etc/profile.d/proxy-env.sh
    sed -i '/PROXY/Id' /etc/environment 2>/dev/null || true
    echo ">> Proxy mode: Direct (no proxy configured, all connections direct)"
fi
