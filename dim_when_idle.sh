#!/usr/bin/env bash
# License: MIT
# Author: github.com/danielhoherd
# Purpose: Hacky script to dim LCD screen unless any login sessions have been active recently.
#          Works on a 2015 macbook pro with Ubuntu 18.04, other setups may not work.

[[ "${OSTYPE}" =~ ^linux ]] || { echo "ABORT: This is only works in linux." ; exit 1 ; }

IDLE_SESSION_COUNT="$(who -s | perl -lane '$s = (86400 * -A "/dev/$F[1]") ; print $s if $s < 300 ;' | wc -l)"

if [ "${IDLE_SESSION_COUNT}" -eq 0 ] ; then
  echo 0 > /sys/class/backlight/acpi_video0/brightness
else
  echo 50 > /sys/class/backlight/acpi_video0/brightness
fi
