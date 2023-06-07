#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: check a host against known public DNS servers

usage() {
  cat <<EOF
Description:
  Checks a given host against many known DNS servers.

Example:
  To check a give host repeatedly in order to get a history of its DNS stability:

    while sleep 10 ; do
      ${0##*/} slack.com
    done

Usage:
  ${0##*/} <target_host>

See Also:
  https://www.whatsmydns.net
EOF
}

if [[ "$#" -ne 1 ]] || [[ "$1" =~ ^[^a-zA-Z0-9] ]] ; then
  usage
  exit 1
fi

trap "kill 0" SIGINT

target_host=$1

nameservers=(
  1.1.1.1
  4.2.2.1
  4.2.2.2
  4.2.2.3
  4.2.2.4
  4.2.2.5
  4.2.2.6
  8.8.4.4
  8.8.8.8
  9.9.9.9
  149.112.112.112
  156.154.70.1
  156.154.71.1
  198.6.1.4
  208.67.220.220
  208.67.222.222
)

echo -n "$(date '+%FT%T%z') "

for nameserver in "${nameservers[@]}" ; do
  (
    if host "${target_host}" "${nameserver}" >/dev/null 2>/dev/null ; then
      echo -n .
    else
      echo -n F
    fi
  ) &
done
wait
echo
