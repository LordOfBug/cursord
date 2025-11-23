#!/bin/bash

# start dbus
dbus-daemon --system --fork

# start app
/usr/bin/antigravity --no-sandbox
