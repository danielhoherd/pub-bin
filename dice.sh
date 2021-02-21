#!/usr/bin/env bash
# License: MIT
# Author: github.com/danielhoherd
# Description: Display a numeral dice with N sides, min 1, default 6, max 32768

if command -v figlet >/dev/null 2>&1 ; then
  show_side() { figlet -w "$(tput cols)" -f doh "$*" ; }
else
  show_side() { echo ; echo "$*" ; echo ; }
fi

sides="${1:-6}"

show_side "  $(( RANDOM % sides + 1 ))"
