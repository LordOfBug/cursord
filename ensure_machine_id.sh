#!/bin/bash

if [ ! -f /etc/machine-id ]; then
  echo "machine-id file not found. Generating a new one..."
  # The command to generate machine-id might vary based on the distribution
  # For systems with systemd:
  dbus-uuidgen > /etc/machine-id
  rm -rf /var/lib/dbus/machine-id
  cp -f /etc/machine-id /var/lib/dbus/machine-id
  echo "New machine-id generated."
else
  echo "machine-id file already exists."
fi