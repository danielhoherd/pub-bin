#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Show machine IP addresses

case $(uname -o) in
  Darwin)
    for IF in $(ipconfig getiflist) ; do
      IP=$(ipconfig getifaddr "$IF")
      [[ -n "$IP" ]] && echo "$IF $IP"
    done | sort
    ;;
  *)
    echo "Unsupported"
    exit 1
esac
