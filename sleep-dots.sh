#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: sleep for the given number of seconds and print a dot at each second

usage() {
  cat <<EOF
Print a sleep progress meter while sleeping for the given number of seconds.

${0##*/} <seconds>
EOF
}

char_print() {
  str=$1
  num=$2
  v=$(printf "%-${num}s" "$str")
  echo -en "${v// /${str}}"
}

[[ "$1" =~ ^[0-9]+$ ]] || { usage ; exit 1 ; }

char_print '.' "$1"
char_print '\b' "$(( "$1" + 1))"
for _ in $(seq 1 "$1") ; do
  sleep 1
  echo -n '#'
done ;
echo
