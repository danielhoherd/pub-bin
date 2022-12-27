#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
#
# We remove the tags first in order to prevent duplicates.
# Keywords is an IPTC tag
# Subject is an XMP tag

read -r -d "" usage <<EOF
Description:
  Add keyword tags to an image file. Only one file at a time is supported.

Usage:
  ${0##*/} [-x] <tag> [<tag>...<tag>] <filename>"
EOF

if [[ "${#@}" -lt 2 ]] ; then
  echo "ERROR: too few arguments"
  echo "$usage"
  exit 1
fi

case $1 in
  '-h' | '--help' | '-?')
    echo "$usage"
    exit 0
    ;;
  '-x')
    set -x
    shift
    ;;
esac

args=()

for tag in "$@" ; do
  if [[ "${#@}" -eq 1 ]] ; then continue ; fi
  args+=("-subject-=$tag" "-keywords-=$tag" "-subject+=$tag" "-keywords+=$tag")
  shift
done

exiftool -overwrite_original_in_place "${args[@]}" -- "$@"
