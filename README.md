# Antigravity In Docker

Run Antigravity IDE in Docker with Ubuntu base image. Enjoy!!

## What it is

This project provides a Docker container that allows you to run [Antigravity](https://antigravity.google/), an AI-first code editor, in an Ubuntu environment. This is particularly useful for:
- Running Antigravity in a containerized environment
- Testing Antigravity in Ubuntu without modifying your host system
- Ensuring consistent development environment across different machines

The prebuild version is available on Docker Hub as [buglord/cursord:latest](https://hub.docker.com/r/buglord/cursord)

## Quick Start with Desktop Version

The desktop version provides a full Ubuntu desktop environment accessible via RDP:

1. Pull and run the container:
   ```bash
   docker run -d -p 3389:3389 buglord/cursord:latest
   ```

2. Connect using any RDP client:
   - Host: `localhost` (or your server IP)
   - Port: `3389`
   - Username: `coder`
   - Password: `coder`

## Features

- Ubuntu 22.04 base with XFCE4 desktop environment
- Pre-installed Antigravity editor with desktop shortcut
- Google Chrome browser
- Remote access via RDP
- Automatic version tracking and builds
- Easy in-container Antigravity upgrades

## Upgrading Antigravity

To upgrade your Antigravity installation to the latest version:

1. Connect to the container via RDP
2. Open a terminal
3. Run the upgrade script:
   ```bash
   /bin/upgrade-antigravity.sh
   ```

The upgrade process will:
- Download the latest version
- Safely close any running Antigravity instances
- Install the new version
- Preserve your settings

## Building Locally

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/cursor-docker.git
   cd cursor-docker
   ```

2. Build using the provided script:
   ```bash
   # Build with latest Antigravity version
   ./build.sh

   # Or specify a version
   ./build.sh 0.46
   ```

## Automated Builds

This repository includes GitHub Actions workflow that:
- Checks for new Antigravity versions every 12 hours
- Automatically builds and pushes new versions to Docker Hub
- Maintains the `latest` tag
- Allows manual workflow triggers

## Troubleshooting

### Common Issues

1. RDP Connection Failed
   - Ensure port 3389 is not blocked by firewall
   - Check if container is running: `docker ps`
   - Check container logs: `docker logs antigravity`

2. Antigravity Not Starting
   - Check container logs
   - Ensure container has enough resources
   - Try restarting the container

### Resource Requirements

- Minimum 4GB RAM recommended
- At least 10GB disk space
- Docker 20.10 or newer

## Security Note

The default password is set for convenience. For production use, consider:
- Changing the default password
- Using environment variables for credentials
- Implementing proper authentication mechanisms
- Securing RDP access behind a VPN

## License

[MIT License](LICENSE)

Last updated: January 8, 2024
