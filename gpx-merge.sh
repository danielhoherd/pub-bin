#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: Unlicense

if [ $# -lt 2 ] ; then
    echo "This script merges gpx files and requires at least two gpx files passed as arguments. Output file is merged.gpx";
    echo "Usage:  ${0##*/} <file_1.gpx> <file_2.gpx> [... <file_n.gpx]";
    exit 1;
fi

check_for_required_commands() {
  for command in "$@" ; do
    command -v "${command}" >/dev/null 2>&1 || missing_commands+=( "${command}" )
  done

  if [ "${#missing_commands[@]}" -gt 0 ] ; then
    date "+%F %T%z ${0##*/} ABORT: missing commands: ${missing_commands[*]}"
    exit 1
  fi
}
export -f check_for_required_commands

check_for_required_commands gpsbabel

args=();
for f in "$@" ; do
    if [ -f "$f" ] || [ -h "$f" ] ; then
        args+=( "-f" "$f" );
    else
        echo "Skipping $f, it's not a file."
    fi
done;

if [ ${#args[@]} -lt 4 ] ; then
    echo "We don't have enough actual files to work with. Exiting."
    exit 1
fi

gpsbabel -i gpx "${args[@]}" -o gpx -F merged.gpx
