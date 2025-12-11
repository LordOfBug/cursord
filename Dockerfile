# Use Ubuntu base image
FROM ubuntu:22.04

# Set non-interactive mode for apt
ENV DEBIAN_FRONTEND=noninteractive

# Define ARGs for Windsurf version and URL
ARG WINDSURF_URL

ARG WINDSURF_VERSION

# Install essential dependencies
RUN apt-get update && apt-get install -y \
    # Essential build tools and utilities
    build-essential \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    libarchive-tools \
    lsb-release \
    procps \
    psmisc \
    software-properties-common \
    supervisor \
    sudo \
    unzip \
    vim \
    wget \

    # X11 and GUI Libraries
    xorg \
    xrdp \
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    dbus-x11 \
    xauth \
    xdg-utils \

    # Core GTK and rendering libraries
    libgtk-3-0 \
    libgdk-pixbuf2.0-0 \
    libcairo2 \
    libpango-1.0-0 \
    libglib2.0-0 \

    # X11 extension libraries
    libx11-6 \
    libx11-xcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxinerama1 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    libxkbcommon0 \

    # Graphics and hardware libraries
    libdrm2 \
    libgbm1 \
    libgl1-mesa-glx \
    libgbm-dev \

    # Audio and multimedia
    libasound2 \
    libcups2 \

    # App-specific libraries (Electron, etc.)
    gnome-keyring \
    libappindicator3-1 \
    libatspi2.0-0 \
    libgconf-2-4 \
    libnss3 \
    libnotify4 \
    libsecret-1-0 \
    libsecret-common \
    libuuid1 \

    # Fonts and rendering support
    fonts-liberation \
    fonts-dejavu-core \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    fonts-wqy-zenhei \
    fonts-wqy-microhei \
    fontconfig \

    # XDG integration dependencies
    desktop-file-utils \
    mime-support \

    # Process and system utilities
    htop \
    
    # Transparent proxy support (redsocks + iptables)
    iptables \
    redsocks \
    
    # Locale support for Chinese
    locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure Chinese locale support
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    sed -i '/zh_CN.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=en_US.UTF-8

# Set environment variables for Chinese text rendering
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV FONTCONFIG_PATH=/etc/fonts

# Refresh font cache to ensure Chinese fonts are available
RUN fc-cache -fv

# Install Microsoft Edge and set as default browser
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-edge.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-edge.gpg] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge.list && \
    apt update && \
    apt install -y microsoft-edge-stable && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    # Create Edge startup script with necessary flags for containerized environment
    echo '#!/bin/bash' > /usr/bin/microsoft-edge-stable && \
    echo 'exec /opt/microsoft/msedge/msedge --no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage --disable-gpu --disable-software-rasterizer --disable-background-timer-throttling --disable-backgrounding-occluded-windows --disable-renderer-backgrounding --disable-features=TranslateUI --disable-ipc-flooding-protection --no-first-run --no-default-browser-check "$@"' >> /usr/bin/microsoft-edge-stable && \
    chmod +x /usr/bin/microsoft-edge-stable && \
    # Set as default browser
    update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/microsoft-edge-stable 500 && \
    update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /usr/bin/microsoft-edge-stable 500 && \
    # Create desktop entry for Edge
    mkdir -p /usr/share/applications && \
    echo '[Desktop Entry]' > /usr/share/applications/microsoft-edge.desktop && \
    echo 'Version=1.0' >> /usr/share/applications/microsoft-edge.desktop && \
    echo 'Name=Microsoft Edge' >> /usr/share/applications/microsoft-edge.desktop && \
    echo 'Comment=Access the Internet' >> /usr/share/applications/microsoft-edge.desktop && \
    echo 'GenericName=Web Browser' >> /usr/share/applications/microsoft-edge.desktop && \
    echo 'Keywords=Internet;WWW;Browser;Web;Explorer' >> /usr/share/applications/microsoft-edge.desktop && \
    echo 'Exec=/usr/bin/microsoft-edge-stable %U' >> /usr/share/applications/microsoft-edge.desktop && \
    echo 'Terminal=false' >> /usr/share/applications/microsoft-edge.desktop && \
    echo 'X-MultipleArgs=false' >> /usr/share/applications/microsoft-edge.desktop && \
    echo 'Type=Application' >> /usr/share/applications/microsoft-edge.desktop && \
    echo 'Icon=microsoft-edge' >> /usr/share/applications/microsoft-edge.desktop && \
    echo 'Categories=Network;WebBrowser;' >> /usr/share/applications/microsoft-edge.desktop && \
    echo 'MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;' >> /usr/share/applications/microsoft-edge.desktop && \
    echo 'Actions=new-window;new-private-window;' >> /usr/share/applications/microsoft-edge.desktop && \
    xdg-settings set default-web-browser microsoft-edge.desktop

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

# Install Antigravity using apt repository
RUN echo "Installing Antigravity from official apt repository..." && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
      gpg --dearmor -o /etc/apt/keyrings/antigravity-repo-key.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
      tee /etc/apt/sources.list.d/antigravity.list > /dev/null && \
    apt-get update && \
    apt-get install -y antigravity && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy Antigravity startup script
COPY antigravity-ubuntu.sh /bin/antigravity.sh
RUN chmod +x /bin/antigravity.sh && \
    chown coder:coder /bin/antigravity.sh

# Create desktop shortcut for Antigravity
RUN mkdir -p /home/coder/Desktop && \
    echo "[Desktop Entry]" > /home/coder/Desktop/antigravity.desktop && \
    echo "Name=Antigravity" >> /home/coder/Desktop/antigravity.desktop && \
    echo "Exec=/bin/antigravity.sh" >> /home/coder/Desktop/antigravity.desktop && \
    echo "Icon=antigravity" >> /home/coder/Desktop/antigravity.desktop && \
    echo "Terminal=false" >> /home/coder/Desktop/antigravity.desktop && \
    echo "Type=Application" >> /home/coder/Desktop/antigravity.desktop && \
    echo "Categories=Development;" >> /home/coder/Desktop/antigravity.desktop && \
    chmod +x /home/coder/Desktop/antigravity.desktop && \
    chown -R coder:coder /home/coder/Desktop

# Copy and setup upgrade script
COPY upgrade-antigravity.sh /bin/upgrade-antigravity.sh
RUN chmod +x /bin/upgrade-antigravity.sh && \
    chown coder:coder /bin/upgrade-antigravity.sh

# Install windsurf using provided URL
RUN echo "Installing Windsurf version: ${WINDSURF_VERSION} from ${WINDSURF_URL}" && \
    wget -O /tmp/windsurf.tar.gz "${WINDSURF_URL}" && \
    tar -xzvf /tmp/windsurf.tar.gz && \
    mv Windsurf /usr/local/windsurf && \
    chown -R coder:coder /usr/local/windsurf && \
    rm /tmp/windsurf.tar.gz

# Copy windsurf startup script
COPY windsurf-ubuntu.sh /bin/windsurf.sh
RUN chmod +x /bin/windsurf.sh && \
    chown coder:coder /bin/windsurf.sh

# Create windsurf desktop entry
RUN mkdir -p /home/coder/Desktop && \
    echo "[Desktop Entry]" > /home/coder/Desktop/windsurf.desktop && \
    echo "Name=Windsurf" >> /home/coder/Desktop/windsurf.desktop && \
    echo "Exec=/bin/windsurf.sh" >> /home/coder/Desktop/windsurf.desktop && \
    echo "Icon=/usr/local/windsurf/resources/app/resources/linux/code.png" >> /home/coder/Desktop/windsurf.desktop && \
    echo "Type=Application" >> /home/coder/Desktop/windsurf.desktop && \
    echo "Categories=Development;" >> /home/coder/Desktop/windsurf.desktop && \
    chmod +x /home/coder/Desktop/windsurf.desktop && \
    chown -R coder:coder /home/coder/Desktop

# Create windsurf protocol handler script
RUN echo '#!/bin/bash' > /bin/windsurf-protocol-handler.sh && \
    echo 'url="$1"' >> /bin/windsurf-protocol-handler.sh && \
    echo '/bin/windsurf.sh "$url"' >> /bin/windsurf-protocol-handler.sh && \
    chmod +x /bin/windsurf-protocol-handler.sh

# Configure windsurf:// protocol handler
RUN mkdir -p /usr/share/applications && \
    echo "[Desktop Entry]" > /usr/share/applications/windsurf-protocol-handler.desktop && \
    echo "Name=Windsurf Protocol Handler" >> /usr/share/applications/windsurf-protocol-handler.desktop && \
    echo "Exec=/bin/windsurf.sh %u" >> /usr/share/applications/windsurf-protocol-handler.desktop && \
    echo "Type=Application" >> /usr/share/applications/windsurf-protocol-handler.desktop && \
    echo "Terminal=false" >> /usr/share/applications/windsurf-protocol-handler.desktop && \
    echo "MimeType=x-scheme-handler/windsurf;" >> /usr/share/applications/windsurf-protocol-handler.desktop && \
    echo "Categories=Development;" >> /usr/share/applications/windsurf-protocol-handler.desktop

# Copy and setup upgrade script
COPY upgrade-windsurf.sh /bin/upgrade-windsurf.sh
RUN chmod +x /bin/upgrade-windsurf.sh && \
    chown coder:coder /bin/upgrade-windsurf.sh

# Register the protocol handler
RUN xdg-mime default windsurf-protocol-handler.desktop x-scheme-handler/windsurf && \
    update-desktop-database /usr/share/applications

# Install Visual Studio Code
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/packages.microsoft.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
    apt update && \
    apt install -y code && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Create VSCode startup script
RUN echo '#!/bin/bash' > /bin/code.sh && \
    echo '# Set environment variables for Chinese text rendering' >> /bin/code.sh && \
    echo 'export LANG=en_US.UTF-8' >> /bin/code.sh && \
    echo 'export LC_ALL=en_US.UTF-8' >> /bin/code.sh && \
    echo 'export FONTCONFIG_PATH=/etc/fonts' >> /bin/code.sh && \
    echo 'exec /usr/bin/code --no-sandbox --unity-launch "$@"' >> /bin/code.sh && \
    chmod +x /bin/code.sh && \
    chown coder:coder /bin/code.sh

# Create desktop shortcut for VSCode
RUN echo "[Desktop Entry]" > /home/coder/Desktop/vscode.desktop && \
    echo "Name=Visual Studio Code" >> /home/coder/Desktop/vscode.desktop && \
    echo "Comment=Code Editing. Redefined." >> /home/coder/Desktop/vscode.desktop && \
    echo "Exec=/bin/code.sh" >> /home/coder/Desktop/vscode.desktop && \
    echo "Icon=/usr/share/code/resources/app/resources/linux/code.png" >> /home/coder/Desktop/vscode.desktop && \
    echo "Terminal=false" >> /home/coder/Desktop/vscode.desktop && \
    echo "Type=Application" >> /home/coder/Desktop/vscode.desktop && \
    echo "Categories=Development;TextEditor;" >> /home/coder/Desktop/vscode.desktop && \
    echo "StartupNotify=true" >> /home/coder/Desktop/vscode.desktop && \
    chmod +x /home/coder/Desktop/vscode.desktop && \
    chown -R coder:coder /home/coder/Desktop

# Delete the existing machine-id file. Init system will generate new ones
RUN rm -f /etc/machine-id

COPY install-zero-omega.sh /usr/bin/install-zero-omega.sh
RUN chmod +x /usr/bin/install-zero-omega.sh
# Run as coder user to install extension in user profile
USER coder
# Ensure PATH includes standard directories and install required tools are available
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
RUN /usr/bin/install-zero-omega.sh
USER root

# Setup supervisord entry for ensure machine id
COPY ensure_machine_id.sh /usr/bin/ensure_machine_id.sh
RUN chmod +x /usr/bin/ensure_machine_id.sh

RUN echo "[program:ensure_machine_id]" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "command=/usr/bin/ensure_machine_id.sh" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autostart=true" >> /etc/supervisor/conf.d/supervisord.conf && \
    echo "autorestart=false" >> /etc/supervisor/conf.d/supervisord.conf

# Expose XRDP port
EXPOSE 3389

# Copy transparent proxy scripts
COPY transparent-proxy.sh /usr/local/bin/transparent-proxy.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/transparent-proxy.sh /usr/local/bin/entrypoint.sh

# Set entrypoint to our wrapper (which handles proxy setup then starts supervisord)
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
