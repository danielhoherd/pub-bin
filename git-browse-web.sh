#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: Unlicense
set -e

usage() {
  echo "Description:  Print and attempt to open the web address for the current repo/branch. Compatible with Github and Gitlab." 2>&1
  echo
  echo "Usage:  ${0##*/} [-h] [-p]" 2>&1
  echo
  echo "        -p Only print the URLs, do not open MacOS browser."
  echo "        -h Show help and exit."
}

while getopts ':hp' option ; do
  case "${option}" in
    p) readonly print_only=true ;;
    h) usage ; exit 0 ;;
    *) usage ; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

branch="$(git rev-parse --abbrev-ref HEAD)"
remote_url="$(git remote get-url origin)"
if [[ "$remote_url" =~ ^git* ]] ; then
  remote_url="$(echo "${remote_url/%.git/}" | sed -e 's#:#/#' -e 's#^git@#https://#')"
elif [[ "${remote_url}" =~ ^http* ]] ; then
  remote_url="${remote_url/%.git/}"
else
  echo "Not sure how to handle URL: $remote_url"
  exit 1
fi

web_url="$remote_url/tree/$branch"
if [[ "$web_url" =~ gitlab.com ]] ; then
  echo "CI Pipelines: $remote_url/-/pipelines"
  echo "CI Jobs:      $remote_url/-/jobs"
fi

echo "Branch URL:   $web_url"
[[ "${print_only}" == "true" ]] || open "$web_url"
