#!/bin/bash

APPDIR=/usr/local/cursor

# start dbus
dbus-daemon --system --fork

# start app
$APPDIR/AppRun --no-sandbox
