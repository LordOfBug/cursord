#!/bin/bash

# Ensure machine-id is properly set up for dbus
echo "Setting up machine-id..."

# Create directories if they don't exist
mkdir -p /var/lib/dbus

# Generate machine-id if it doesn't exist
if [ ! -f /etc/machine-id ] || [ ! -s /etc/machine-id ]; then
  echo "machine-id file not found or empty. Generating a new one..."
  # Generate a new machine-id
  dbus-uuidgen > /etc/machine-id
  echo "New machine-id generated: $(cat /etc/machine-id)"
else
  echo "machine-id file already exists: $(cat /etc/machine-id)"
fi

# Ensure dbus machine-id is synced
rm -f /var/lib/dbus/machine-id
cp -f /etc/machine-id /var/lib/dbus/machine-id

# Set proper permissions
chmod 444 /etc/machine-id
chmod 444 /var/lib/dbus/machine-id

echo "Machine-id setup completed successfully."