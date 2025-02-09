# Cursor In Docker

Run Cursor IDE in Docker with Ubuntu base image. Enjoy!!

## What it is

This project provides a Docker container that allows you to run [Cursor](https://cursor.sh/), an AI-first code editor, in an Ubuntu environment. This is particularly useful for:
- Running Cursor in a containerized environment
- Testing Cursor in Ubuntu without modifying your host system
- Ensuring consistent development environment across different machines

The prebuild version is availabe on docker hub as [buglord/cursord:latest](https://hub.docker.com/r/buglord/cursord)

### Latest Update
On Mac, XQuartz is slow so I decided to build the full desktop version with Ubuntu
- Desktop version: [buglord/cursord:ubuntu](https://hub.docker.com/r/buglord/cursord)

1. Start the container
   ```bash
   docker run -d -p 3389:3389 buglord/cursord:ubuntu
   ```

2. Use your remote desktop to connect to 3389 port. use coder:coder to login, that's all


## How to run on MacOS

1. Prerequisites:
   - Docker Desktop for Mac installed
   - XQuartz installed (for X11 forwarding)

2. Install XQuartz:
   ```bash
   brew install --cask xquartz
   ```

3. Configure XQuartz:
   - Open XQuartz
   - Go to XQuartz > Preferences
   - Go to the Security tab
   - Check "Allow connections from network clients"
   - Restart XQuartz

4. Allow X11 forwarding:
   ```bash
   xhost +localhost
   ```

5. Build and run the container:
   ```bash
   docker build -t cursord .
   docker run -e DISPLAY=host.docker.internal:0 -v /tmp/.X11-unix:/tmp/.X11-unix cursord
   ```

## How to run on Linux

1. Prerequisites:
   - Docker installed
   - X11 installed (comes with most Linux distributions)

2. Allow X11 forwarding:
   ```bash
   xhost +local:
   ```

3. Build and run the container:
   ```bash
   docker build -t cursord .
   docker run -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix cursord
   ```

## Note

Last updated: January 8, 2025
