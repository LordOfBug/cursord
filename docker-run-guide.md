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
