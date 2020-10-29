#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT

[[ ! "${OSTYPE}" =~ ^darwin ]] && { echo "ERROR: macOS required." ; exit 1 ; }


WHERE='where background only is false'
usage() {
  cat <<EOF
Get a list of running macOS apps.

${0##*/} [--help|-h] || [--all|-a]
EOF
}

[[ "$1" =~ ^(--help|-h)$ ]] && { usage ; exit 0 ; }
[[ "$1" =~ ^(--all|-a)$ ]] && WHERE=''

osascript -e "tell application \"System Events\" to get name of every process $WHERE"
