#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT

[[ ! "${OSTYPE}" =~ ^darwin ]] && { echo "ERROR: macOS required." ; exit 1 ; }

usage(){
  cat <<EOF
Quit a running macOS app

${0##*/} <app to quit>
EOF
}

[ "${#@}" -eq 0 ] && { usage ; exit 1 ; }

osascript -e "tell application \"System Events\" to quit process $1"
