#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Print some media info about the given media files

help() {
  echo "Show some metadata for the given media files."
  echo "See also: https://danielhoherd.com/tech-notes/exiftool/"
}

while getopts ':hv' option ; do
  case "${option}" in
    h) help ; exit ;;
    v) set -x ; exiftool_args+=( '-a' '-u' '-G:1:2' ) ;;
    *) help ; exit 1 ;
  esac
done
shift $((OPTIND - 1))

if [ -z "${exiftool_args[*]}" ] ; then
  exiftool_args+=(
    '-BitDepth'
    '-BitsPerSample'
    '-Duration'
    '-ImageSize'
    '-ImageHeight'
    '-ImageWidth'
    '-VideoFrameRate'
    '-AudioFormat'
    '-AudioSampleRate'
    '-Model'
    '-LensID'
    '-Country'
    '-State'
    '-City'
  )
fi

exiftool "${exiftool_args[@]}" "$@"
