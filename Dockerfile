# Use Ubuntu base image
FROM ubuntu:22.04

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Add build argument for Cursor download URL
ARG CURSOR_DOWNLOAD_URL=https://downloader.cursor.sh/linux

# Verify build argument is provided
RUN test -n "$CURSOR_DOWNLOAD_URL" || (echo "CURSOR_DOWNLOAD_URL build argument is required" && false)

# Install essential dependencies
RUN apt update && apt install -y \
    vim \
    wget \
    curl \
    unzip \
    sudo \
    xorg \
    xrdp \
    xfce4 \
    xfce4-terminal \
    xdg-utils \
    gnome-keyring \
    dbus-x11 \
    libsecret-1-0 \
    libsecret-common \
    xauth \
    supervisor \
    software-properties-common \
    # Chrome/Electron app dependencies
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    # XDG integration dependencies
    desktop-file-utils \
    mime-support \
    && apt clean

# Install Chrome and set as default browser
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt update && \
    apt install -y google-chrome-stable && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo '#!/bin/bash' > /usr/bin/google-chrome-stable && \
    echo 'exec /opt/google/chrome/chrome --no-sandbox --test-type "$@"' >> /usr/bin/google-chrome-stable && \
    chmod +x /usr/bin/google-chrome-stable && \
    update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/google-chrome-stable 500 && \
    update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /usr/bin/google-chrome-stable 500 && \
    xdg-settings set default-web-browser google-chrome.desktop

# Configure XRDP
RUN adduser xrdp ssl-cert && \
    echo "startxfce4" > /etc/skel/.xsession && \
    sed -i 's/max_bpp=32/max_bpp=128/g' /etc/xrdp/xrdp.ini && \
    sed -i 's/xserverbpp=24/xserverbpp=128/g' /etc/xrdp/xrdp.ini && \
    echo "xfce4-session" > /root/.xsession

# Create user
RUN useradd -m -s /bin/bash coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "coder:coder" | chpasswd && \
    cp /root/.xsession /home/coder/.xsession && \
    chown coder:coder /home/coder/.xsession

# Set up supervisord configuration
RUN echo "[supervisord]" > /etc/supervisor/conf.d/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "[program:xrdp]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=/usr/sbin/xrdp -n" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "[program:xrdp-sesman]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=/usr/sbin/xrdp-sesman -n" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autorestart=true" >> /etc/supervisor/conf.d/supervisord.conf

# Download cursor from cursor.sh
RUN wget -O /tmp/cursor.app "${CURSOR_DOWNLOAD_URL}" && \
    chmod +x /tmp/cursor.app && \
    /tmp/cursor.app --appimage-extract && \
    mv squashfs-root /usr/local/cursor && \
    chown -R coder:coder /usr/local/cursor && \
    rm /tmp/cursor.app

# Copy cursor startup script
COPY cursor-ubuntu.sh /bin/cursor.sh
RUN chmod +x /bin/cursor.sh && \
    chown coder:coder /bin/cursor.sh

# Create desktop shortcut for Cursor
RUN mkdir -p /home/coder/Desktop && \
    echo "[Desktop Entry]" > /home/coder/Desktop/cursor.desktop && \
    echo "Name=Cursor" >> /home/coder/Desktop/cursor.desktop && \
    echo "Exec=/bin/cursor.sh" >> /home/coder/Desktop/cursor.desktop && \
    echo "Icon=/usr/local/cursor/resources/app/resources/linux/code.png" >> /home/coder/Desktop/cursor.desktop && \
    echo "Terminal=false" >> /home/coder/Desktop/cursor.desktop && \
    echo "Type=Application" >> /home/coder/Desktop/cursor.desktop && \
    echo "Categories=Development;" >> /home/coder/Desktop/cursor.desktop && \
    chmod +x /home/coder/Desktop/cursor.desktop && \
    chown -R coder:coder /home/coder/Desktop

# Copy and setup upgrade script
COPY upgrade-cursor.sh /bin/upgrade-cursor.sh
RUN chmod +x /bin/upgrade-cursor.sh && \
    chown coder:coder /bin/upgrade-cursor.sh

# Delete the existing machine-id file. Init system will generate new ones
RUN rm -f /etc/machine-id

# Setup supervisord entry for ensure machine id
COPY ensure_machine_id.sh /usr/bin/ensure_machine_id.sh
RUN echo "[program:ensure_machine_id]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=/usr/bin/ensure_machine_id.sh" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autostart=true" >> /etc/supervisor/conf.d/supervisord.conf
    echo "autorestart=false" >> /etc/supervisor/conf.d/supervisord.conf

# Expose XRDP port
EXPOSE 3389

# Set entrypoint to supervisord
ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
