# Antigravity, Kiro & OpenCode In Docker

Run Antigravity, Kiro, and OpenCode AI-powered IDEs in Docker with Ubuntu base image. Enjoy!!

## What it is

This project provides a Docker container that allows you to run AI-powered IDEs in an Ubuntu environment:
- [Antigravity](https://antigravity.google/) - An AI-first code editor
- [Kiro](https://kiro.dev/) - An agentic IDE with spec-driven development
- [OpenCode](https://opencode.ai/) - Open source AI coding agent built for the terminal and desktop

This is particularly useful for:
- Running AI IDEs in a containerized environment
- Testing IDEs in Ubuntu without modifying your host system
- Ensuring consistent development environment across different machines

The prebuild version is available on Docker Hub as [buglord/cursord:latest](https://hub.docker.com/r/buglord/cursord)

## Quick Start with Desktop Version

The desktop version provides a full Ubuntu desktop environment accessible via RDP:

1. Pull and run the container:
   ```bash
   docker run -d --cap-add=NET_ADMIN -p 3389:3389 buglord/cursord:latest
   ```

2. Connect using any RDP client:
   - Host: `localhost` (or your server IP)
   - Port: `3389`
   - Username: `coder`
   - Password: `coder`

## Features

- **Ubuntu 22.04 base** with XFCE4 desktop environment.
- **Pre-installed AI Editors**:
  - **Antigravity**: AI-first code editor from Google.
  - **Kiro**: Agentic IDE with spec-driven development, agent hooks, and natural language coding assistance.
  - **OpenCode**: Open source AI coding agent with terminal and desktop interfaces.
  - **VSCode**: Visual Studio Code with custom startup flags for container stability.
- **Default Browser**: **Microsoft Edge** (configured with flags for container/no-sandbox environments).
  - **Pre-installed Extension**: ZeroOmega proxy extension (automatically installed via enterprise policy).
- **Development Stack**:
  - Node.js 20.x & Nginx.
  - Essential tools: `git`, `curl`, `wget`, `htop`, `strace`, `gdb`, `lsof`.
  - Network utilities: `net-tools`, `iputils-ping`, `telnet`.
- **Locale Support**: English (US) and Chinese (UTF-8) pre-configured.
- **Remote Access**: via XRDP (port 3389).
- **Proxy Support**: Userspace proxying via `proxychains4` and environment proxies (`ALL_PROXY`, `HTTP_PROXY`).

## Proxy Configuration (ProxyChains)

The container includes a built-in system for userspace proxying via **ProxyChains4** and standard environment proxies, without requiring `--cap-add=NET_ADMIN` or complex kernel NAT rules.

### How to Enable

1. **Mount your proxychains.conf** (or pass `PROXY_URL`):
   Mount a standard `proxychains.conf` on your host to `/etc/proxychains4.conf`:
   ```bash
   -v /path/to/proxychains.conf:/etc/proxychains4.conf:ro
   ```
   Or pass as an environment variable:
   ```bash
   -e PROXY_URL="socks5://192.168.1.50:1080"
   ```

2. **Run Example**:
   ```bash
   docker run -d \
     --shm-size=2g \
     -p 3389:3389 \
     -v $(pwd)/proxychains.conf:/etc/proxychains4.conf:ro \
     buglord/cursord:latest
   ```

### Usage
- **Terminal CLI tools**: Prefix any command with `pc` or `proxychains4`:
  ```bash
  pc git clone https://github.com/...
  pc curl https://api.openai.com
  ```
- **AI IDEs (Antigravity & Kiro)**: Automatically detect the configured proxy on launch and route traffic through `--proxy-server`.

## Browser Proxy Extension (ZeroOmega)

The container comes with **ZeroOmega** proxy extension pre-installed in Microsoft Edge using enterprise policies. This is especially useful when working behind firewalls.

### Key Features

- **Automatic Installation**: The extension is force-installed via Edge's enterprise policy system (`ExtensionInstallForcelist`)
- **Always Available**: Cannot be accidentally uninstalled by users
- **Auto-Updates**: The extension automatically updates from the Microsoft Edge Add-ons store
- **Persistent Configuration**: Your proxy settings persist across container restarts

### How It Works

The installation uses Edge's managed policy system:
- Policy file location: `/etc/opt/edge/policies/managed/policies.json`
- Extension ID: `fnbemgdobbciiofjfaoaajboakejkdbo`
- The extension is downloaded from Microsoft Edge Add-ons store on first launch

### Verification

To verify the extension is installed:
1. Open Microsoft Edge in the container
2. Navigate to `edge://extensions`
3. You should see "ZeroOmega" listed with "Installed by enterprise policy" label

### Configuration

Once Edge is open with the extension installed:
1. Click the ZeroOmega icon in the toolbar
2. Configure your proxy settings (SOCKS5, HTTP, etc.)
3. Settings are saved and will persist across restarts

**Note**: This browser-level proxy is separate from the system-wide transparent proxy (redsocks). Use ZeroOmega when you need per-application proxy control in the browser.

## Upgrading AI IDEs

To upgrade your AI IDE installations to the latest versions:

### Upgrade Antigravity

1. Connect to the container via RDP
2. Open a terminal
3. Run the upgrade script:
   ```bash
   /bin/upgrade-antigravity.sh
   ```

### Upgrade Kiro

1. Connect to the container via RDP
2. Open a terminal
3. Run the upgrade script:
   ```bash
   /bin/upgrade-kiro.sh
   ```

### Upgrade OpenCode

1. Connect to the container via RDP
2. Open a terminal
3. Run the upgrade script:
   ```bash
   /bin/upgrade-opencode.sh
   ```

## Building Locally

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/cursor-docker.git
   cd cursor-docker
   ```

2. Build using the provided script:
   ```bash
   # Build with latest versions
   ./build.sh
   ```

## Troubleshooting

1. **RDP Connection Failed**
   - Ensure port 3389 is open.
   - Check logs: `docker logs <container_id>`

2. **Proxy Not Working**
   - Check container logs: `docker logs <container_id> | grep -i proxy`.
   - Verify config is mounted: `cat /etc/proxychains4.conf`.
   - Test connection: `pc curl -I https://www.google.com`.

3. **ZeroOmega Extension Not Showing**
   - Restart Microsoft Edge completely (close all windows and reopen)
   - Check policy file exists: `cat /etc/opt/edge/policies/managed/policies.json`
   - Verify Edge can read policies: `edge://policy` should show "ExtensionInstallForcelist"
   - Check Edge extensions page: `edge://extensions` should show the extension

4. **Extension Installed But Not Working**
   - Configure the proxy settings by clicking the ZeroOmega icon in Edge toolbar
   - Check if your proxy server is accessible from the container
   - Try switching between different proxy profiles in ZeroOmega

## License

[MIT License](LICENSE)

Last updated: March 26, 2026
