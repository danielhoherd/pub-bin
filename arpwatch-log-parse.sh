#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Parses arpwatch logs into a date sorted table

check_for_required_commands() {
  for command in "$@" ; do
    command -v "${command}" >/dev/null 2>&1 || missing_commands+=( "${command}" )
  done

  if [[ "${#missing_commands[@]}" -gt 0 ]] ; then
    date "+%FT%T%z ${0##*/} ABORT: missing commands: ${missing_commands[*]}"
    exit 1
  fi
}

if [[ "${OSTYPE}" =~ ^darwin ]] ; then
  check_for_required_commands gdate sort column
  ydate() { gdate "$@" ; }
elif [[ "${OSTYPE}" =~ ^linux ]] ; then
  check_for_required_commands date sort column
  ydate() { date "$@" ; }
else
  echo "Not sure what to do with ${OSTYPE}..."
  exit 1
fi

while IFS=$'\t' read -r A B C D E ; do
  ydate "+%FT%T%z $A $B $E $D" -d "@${C}"
done < /var/lib/arpwatch/arp.dat |
sort |
column -t
