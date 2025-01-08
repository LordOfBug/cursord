FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages for X11
RUN apt update && apt install -y \
    xorg \
    libgl1-mesa-glx \ 
    libgl1-mesa-dri \ 
    mesa-common-dev 

# Install fuse and other libraries
RUN apt install -y vim wget net-tools fuse xdg-utils

# Install Firefox ESR (non-snap version)
RUN apt install -y software-properties-common && \
    add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    apt update && \
    apt install -y firefox-esr

# Extra packages goes here

# Download and set permissions for cursor.app (assuming it's available for Ubuntu)
RUN wget -O /tmp/cursor.app https://downloader.cursor.sh/linux

RUN chmod +x /tmp/cursor.app

RUN /tmp/cursor.app --appimage-extract && mv squashfs-root /usr/local/cursor && rm /tmp/cursor.app

# prepare dbus
RUN mkdir -p /run/dbus

ENV APPDIR=/usr/local/cursor

# Set environment variable for X11 display
ENV DISPLAY=:0

COPY cursor.sh /bin/cursor.sh

RUN chmod +x /bin/cursor.sh

# Start the application
CMD ["cursor.sh"]
