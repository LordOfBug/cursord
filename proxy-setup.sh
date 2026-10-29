#!/bin/bash
# Proxy Setup Script
# Replaces redsocks with lightweight, userspace proxychains-ng and environment proxying.
# Requires NO special capabilities (no NET_ADMIN, no iptables, no DNS hijacking).
#
# Supported configuration methods:
# 1. Mount config: -v /path/to/proxychains.conf:/etc/proxychains4.conf:ro
# 2. Environment variable: -e PROXY_URL=socks5://192.168.1.50:1080 (or http://...)

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

# If proxychains configuration is active, export standard proxy environment variables
if [ -f "$PROXYCHAINS_CONF" ] && grep -v '^#' "$PROXYCHAINS_CONF" | grep -q '[a-z]'; then
    # Extract the last active proxy from [ProxyList]
    LAST_LINE=$(grep -v '^#' "$PROXYCHAINS_CONF" | grep -v '^\[' | grep -E '(socks4|socks5|http)' | tail -1)
    if [ -n "$LAST_LINE" ]; then
        TYPE=$(echo "$LAST_LINE" | awk '{print $1}')
        IP=$(echo "$LAST_LINE" | awk '{print $2}')
        PORT=$(echo "$LAST_LINE" | awk '{print $3}')
        USER=$(echo "$LAST_LINE" | awk '{print $4}')
        PASS=$(echo "$LAST_LINE" | awk '{print $5}')

        if [ -n "$USER" ] && [ -n "$PASS" ]; then
            PROXY_URI="${TYPE}://${USER}:${PASS}@${IP}:${PORT}"
        else
            PROXY_URI="${TYPE}://${IP}:${PORT}"
        fi

        echo ">> Proxy configured: $PROXY_URI"
        echo "   - Userspace proxy tool: proxychains4 / pc <command>"

        # Set system-wide environment variables for apps, CLI tools, and IDEs
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

        # Also write to /etc/environment for non-interactive sessions
        echo "http_proxy=\"$PROXY_URI\"" >> /etc/environment
        echo "https_proxy=\"$PROXY_URI\"" >> /etc/environment
        echo "all_proxy=\"$PROXY_URI\"" >> /etc/environment
        echo "HTTP_PROXY=\"$PROXY_URI\"" >> /etc/environment
        echo "HTTPS_PROXY=\"$PROXY_URI\"" >> /etc/environment
        echo "ALL_PROXY=\"$PROXY_URI\"" >> /etc/environment
        echo "no_proxy=\"localhost,127.0.0.1,::1,*.local\"" >> /etc/environment
        echo "NO_PROXY=\"localhost,127.0.0.1,::1,*.local\"" >> /etc/environment
        
        # Export for current entrypoint session
        export http_proxy="$PROXY_URI"
        export https_proxy="$PROXY_URI"
        export all_proxy="$PROXY_URI"
        export HTTP_PROXY="$PROXY_URI"
        export HTTPS_PROXY="$PROXY_URI"
        export ALL_PROXY="$PROXY_URI"
        export no_proxy="localhost,127.0.0.1,::1,*.local"
        export NO_PROXY="localhost,127.0.0.1,::1,*.local"
    fi
else
    echo ">> Proxy mode: Direct (no proxy configuration provided)"
fi
