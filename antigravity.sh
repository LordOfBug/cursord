#!/bin/bash

APPDIR=/usr/local/antigravity

# start dbus
dbus-daemon --system --fork

# start app
$APPDIR/AppRun --no-sandbox
