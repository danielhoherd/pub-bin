#!/usr/bin/env bash
# Ejects all removable media from an OS X machine

command -v osascript &>/dev/null || { echo "osascript is required, are you using OS X?" >&2 ; exit 1 ; }

osascript -e 'tell application "Finder" to eject (every disk whose ejectable is true)'
