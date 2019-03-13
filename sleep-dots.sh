#!/usr/bin/env bash

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

# Check for invalid script usage. All tests should fail.
[ "${#@}" -eq 1 ] ||
[ "$1" == "--help" ] ||
[ "$1" == "-h" ] ||
[[ $1 != *[!0-9]* ]] &&
{ usage ; exit 1 ; }

char_print '.' "$1"
char_print '\b' "$(( "$1" + 1))"
for _ in $(seq 1 "$1") ; do
  sleep 1
  echo -n '#'
done ;
echo
