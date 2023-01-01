#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Sleep until the given GNU date compatible timestamp

if [[ "${OSTYPE}" =~ ^darwin ]]; then
    ydate() { gdate "$@"; }
elif [[ "${OSTYPE}" =~ ^linux ]]; then
    ydate() { date "$@"; }
else
    echo "Not sure what to do with ${OSTYPE}..."
    exit 1
fi

if [[ $# -ne 1 ]] ; then
  echo "Invalid syntax."
  echo "Usage: sleep-until.sh <future-timestamp>"
  exit 1
fi

now=${EPOCHSECONDS}
future=$(ydate '+%s' -d "$*")
sleep $((future - now))
