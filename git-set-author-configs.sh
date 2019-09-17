#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: Unlicense
set -e

usage() {
  echo "Description:  For all directories found directly within code_dir, add local git author configs."
  echo "Usage:        ${0##*/} code_dir git.user.email git.user.name"
}

while getopts ':x' option ; do
  case "${option}" in
    x) VERBOSE=true ;;
    *) usage ; exit 1 ;
  esac
done
shift $((OPTIND - 1))

[ $# -ne 3 ] && { echo "ERROR" ; usage ; exit 1 ; }
code_dir="$1"
git_user_email="$2"
git_user_name="$3"

[ -d "${code_dir}" ] || { echo "ABORT: ${code_dir} does not exist." ; exit 1 ; }

find "${code_dir}" -maxdepth 1 -mindepth 1 -type d | while read -r DIR ; do
  (
    [ "${VERBOSE}" == 1 ] || [ "${VERBOSE}" == "true" ] && set -x
    cd "$DIR"
    git config --local user.email "${git_user_email}"
    git config --local user.name "${git_user_name}"
  )
done
