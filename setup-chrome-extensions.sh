#!/bin/bash

# Create necessary directories
mkdir -p /home/coder/.config/google-chrome/Default/Extensions
mkdir -p /home/coder/.config/google-chrome/Default

# Create Chrome preferences file with extensions
cat > /home/coder/.config/google-chrome/Default/Preferences << 'EOL'
{
  "extensions": {
    "settings": {
      "cjpalhdlnbpafiamejdnhcphjbkeiagm": {
        "location": 1,
        "granted_permissions": {"api":["tabs"],"explicit_host":["*://*/*"]},
        "path": "cjpalhdlnbpafiamejdnhcphjbkeiagm/1.52.2_0",
        "state": 1
      },
      "eimadpbcbfnmbkopoojfekhnkhdbieeh": {
        "location": 1,
        "granted_permissions": {"api":["tabs"],"explicit_host":["*://*/*"]},
        "path": "eimadpbcbfnmbkopoojfekhnkhdbieeh/4.9.67_0",
        "state": 1
      },
      "padekgcemlokbadohgkifijomclgjgif": {
        "location": 1,
        "granted_permissions": {"api":["proxy","tabs","webRequest","webRequestBlocking"],"explicit_host":["*://*/*"]},
        "path": "padekgcemlokbadohgkifijomclgjgif/2.5.21_0",
        "state": 1
      }
    }
  }
}
EOL

# Download and extract extensions
# uBlock Origin
mkdir -p /home/coder/.config/google-chrome/Default/Extensions/cjpalhdlnbpafiamejdnhcphjbkeiagm
wget -O /tmp/ublock.zip "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&x=id%3Dcjpalhdlnbpafiamejdnhcphjbkeiagm%26uc"
unzip /tmp/ublock.zip -d /home/coder/.config/google-chrome/Default/Extensions/cjpalhdlnbpafiamejdnhcphjbkeiagm

# Dark Reader
mkdir -p /home/coder/.config/google-chrome/Default/Extensions/eimadpbcbfnmbkopoojfekhnkhdbieeh
wget -O /tmp/darkreader.zip "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&x=id%3Deimadpbcbfnmbkopoojfekhnkhdbieeh%26uc"
unzip /tmp/darkreader.zip -d /home/coder/.config/google-chrome/Default/Extensions/eimadpbcbfnmbkopoojfekhnkhdbieeh

# Proxy SwitchyOmega
mkdir -p /home/coder/.config/google-chrome/Default/Extensions/padekgcemlokbadohgkifijomclgjgif
wget -O /tmp/switchyomega.zip "https://clients2.google.com/service/update2/crx?response=redirect&acceptformat=crx2,crx3&x=id%3Dpadekgcemlokbadohgkifijomclgjgif%26uc"
unzip /tmp/switchyomega.zip -d /home/coder/.config/google-chrome/Default/Extensions/padekgcemlokbadohgkifijomclgjgif

# Set permissions
chown -R coder:coder /home/coder/.config

# Cleanup
rm -f /tmp/ublock.zip /tmp/darkreader.zip /tmp/switchyomega.zip 