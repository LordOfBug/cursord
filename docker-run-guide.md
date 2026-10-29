# Docker Run Guide for IDE Stability

## Critical Docker Run Parameters

To prevent IDE crashes during file operations and window resizing, use these parameters when running the container:

```bash
docker run -d \
  --name antigravity-ide \
  --shm-size=2g \
  --memory=8g \
  --cpus=4 \
  --tmpfs /tmp:rw,exec,nosuid,size=2g \
  --tmpfs /var/tmp:rw,exec,nosuid,size=512m \
  -v /dev/shm:/dev/shm \
  -p 3389:3389 \
  -e DISPLAY=:0 \
  --security-opt seccomp=unconfined \
  --cap-add SYS_ADMIN \
  your-image-name
```

## Parameter Explanations

- `--shm-size=2g`: Critical for Electron apps - prevents crashes during file operations and rendering
- `--memory=8g`: Adequate memory for IDE operations
- `--cpus=4`: Sufficient CPU allocation
- `--tmpfs /tmp`: Fast temporary file operations (must have `exec` permission for agent/native binaries)
- `-v /dev/shm:/dev/shm`: Shared memory access
- `--security-opt seccomp=unconfined`: Allows necessary system calls (e.g. clone3 with glibc >= 2.38)
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

## Proxy Configuration (ProxyChains & Environment)

The image provides fine-grained, userspace proxying via **ProxyChains4** and standard environment proxies (`ALL_PROXY`, `HTTP_PROXY`, `HTTPS_PROXY`).
Unlike redsocks, this operates completely in userspace and **does not require `--cap-add=NET_ADMIN`** or complex iptables NAT rules.

### How It Works

You can configure the proxy in two simple ways:

#### Option A: Mount a `proxychains.conf` file (Recommended)
Mount your configuration to `/etc/proxychains4.conf`:

```bash
docker run -d \
  --name antigravity-ide \
  --shm-size=2g \
  -v /path/to/proxychains.conf:/etc/proxychains4.conf:ro \
  -p 3389:3389 \
  your-image-name
```

Sample `proxychains.conf`:
```conf
strict_chain
proxy_dns
tcp_read_time_out 15000
tcp_connect_time_out 8000

[ProxyList]
socks5 192.168.1.50 1080
# http  192.168.1.50 8080
```

#### Option B: Pass via `PROXY_URL` Environment Variable
Pass your proxy URL directly when starting the container:

```bash
docker run -d \
  --name antigravity-ide \
  --shm-size=2g \
  -e PROXY_URL="socks5://192.168.1.50:1080" \
  -p 3389:3389 \
  your-image-name
```

### Using the Proxy Inside the Container

1. **Terminal Tools (Fine-Grained Control):**
   Run any command through the proxy using `proxychains4` or the short alias `pc`:
   ```bash
   pc git clone https://github.com/...
   pc curl -I https://api.openai.com
   pc npm install
   ```

2. **AI IDEs (Antigravity & Kiro):**
   Antigravity and Kiro automatically detect the configured proxy on startup and apply native `--proxy-server` routing to AI models and extension marketplaces without any extra steps.

3. **Verifying Proxy Status:**
   ```bash
   # Check proxy configuration in container logs
   docker logs antigravity-ide | grep -i proxy

   # Test connection in terminal
   docker exec -it antigravity-ide pc curl ipinfo.io
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