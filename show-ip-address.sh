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
  GNU/Linux)
    if ! command -v ip &>/dev/null ; then
      echo "ip command not found. Please install iproute2."
      exit 1
    fi
    for IF in /sys/class/net/* ; do
      ip -4 addr show "${IF##*/}" |
      awk -v IF="${IF##*/}" '/inet / {sub("/.*", "", $2) ; printf "%s %s\n", IF, $2}'
    done
    ;;
  *)
    echo "Unsupported"
    exit 1
esac
