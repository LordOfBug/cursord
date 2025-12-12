# Docker Run Guide for IDE Stability

## Critical Docker Run Parameters

To prevent IDE crashes during file operations and window resizing, use these parameters when running the container:

```bash
docker run -d \
  --name antigravity-ide \
  --shm-size=2g \
  --memory=8g \
  --cpus=4 \
  --tmpfs /tmp:rw,noexec,nosuid,size=1g \
  --tmpfs /var/tmp:rw,noexec,nosuid,size=512m \
  -v /dev/shm:/dev/shm \
  -p 3389:3389 \
  -e DISPLAY=:0 \
  --security-opt seccomp=unconfined \
  --cap-add SYS_ADMIN \
  your-image-name
```

## Parameter Explanations

- `--shm-size=2g`: Critical for Electron apps - prevents crashes during file operations
- `--memory=8g`: Adequate memory for IDE operations
- `--cpus=4`: Sufficient CPU allocation
- `--tmpfs /tmp`: Fast temporary file operations
- `-v /dev/shm:/dev/shm`: Shared memory access
- `--security-opt seccomp=unconfined`: Allows necessary system calls
- `--cap-add SYS_ADMIN`: Required for some GUI operations

## Alternative Minimal Run Command

If you need a simpler setup:

```bash
docker run -d \
  --name antigravity-ide \
  --shm-size=2g \
  -p 3389:3389 \
  your-image-name
```

## Troubleshooting

If you still experience crashes:

1. Increase `--shm-size` to 4g or higher
2. Add `--privileged` flag (less secure but more compatible)
3. Check container logs: `docker logs antigravity-ide`
4. Monitor memory usage: `docker stats antigravity-ide`

## Performance Monitoring

Monitor container resources:
```bash
# Check memory and CPU usage
docker stats antigravity-ide

# Check shared memory usage
docker exec antigravity-ide df -h /dev/shm
```

## Transparent Proxy Mode

The image supports transparent proxying - applications inside the container will be completely unaware of the proxy while all HTTP/HTTPS traffic is automatically routed through it.

### How It Works

- Mount a `redsocks.conf` file to `/etc/redsocks.conf`
- If the file exists and is non-empty, transparent proxy is **enabled**
- If the file doesn't exist, transparent proxy is **disabled** (normal mode)

### Running with Transparent Proxy

**Step 1: Create a redsocks.conf file on your host:**

```conf
base {
    log_debug = off;
    log_info = on;
    log = "syslog:daemon";
    daemon = on;
    redirector = iptables;
}

redsocks {
    local_ip = 127.0.0.1;
    local_port = 12345;
    
    // Your proxy server
    ip = 192.168.1.50;
    port = 8080;
    
    // Use 'http-connect' for HTTP proxies, 'socks5' for SOCKS5
    type = http-connect;
    
    // Optional authentication (uncomment if needed)
    // login = "username";
    // password = "password";
}
```

**Step 2: Run the container with the config mounted:**

```bash
docker run -d \
  --name antigravity-ide \
  --cap-add=NET_ADMIN \
  -v /path/to/redsocks.conf:/etc/redsocks.conf:ro \
  --shm-size=2g \
  -p 3389:3389 \
  your-image-name
```

### Important Notes

- **`--cap-add=NET_ADMIN` is required** when mounting the config. The container needs this capability to modify iptables rules.
- The proxy intercepts traffic on ports 80 (HTTP) and 443 (HTTPS).
- Local/private network traffic (10.x.x.x, 172.16.x.x, 192.168.x.x, etc.) is NOT proxied.
- The proxy server IP is automatically excluded to prevent infinite loops.

### Verifying Proxy is Active

```bash
# Check container logs for proxy status
docker logs antigravity-ide | grep -i proxy


# Verify iptables rules are applied
docker exec antigravity-ide iptables -t nat -L REDSOCKS

# Check redsocks is running
docker exec antigravity-ide pgrep -x redsocks
```

## Web Development Configuration

### Customizing Nginx

To use your own `nginx.conf`, mount it into the container:

```bash
docker run -d \
  ... \
  -v /path/to/your/nginx.conf:/etc/nginx/nginx.conf:ro \
  ...
```

### Customizing /etc/hosts

To add entries to `/etc/hosts` inside the container, use the `--add-host` flag. This is preferred over mounting `/etc/hosts` directly, as it avoids permission issues and allows Docker to manage the file.

```bash
docker run -d \
  ... \
  --add-host my.dev.site:127.0.0.1 \
  --add-host api.internal:192.168.1.50 \
  ...
```

