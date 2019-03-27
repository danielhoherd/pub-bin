#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: Unlicense
set -e

usage() {
  echo "Description:  For all directories found directly within code_dir, add local git author configs."
  echo "Usage:        ${0##*/} code_dir git.user.email git.user.name"
}

while getopts x option
do
  case "${option}" in
    x) VERBOSE=true ;;
    *) help ; exit 1 ;
  esac
done
shift $((OPTIND - 1))

[ $# -ne 3 ] && { echo "ERROR" ; usage ; exit 1 ; }
CODE_DIR="$1"
EMAIL="$2"
NAME="$3"

find "$CODE_DIR" -maxdepth 1 -mindepth 1 -type d | while read -r DIR ; do
  (
    [ "${VERBOSE}" == 1 ] || [ "${VERBOSE}" == "true" ] && set -x
    cd "$DIR"
    git config --local user.email "$EMAIL"
    git config --local user.name "$NAME"
  )
done
