#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: Unlicense
set -e

usage() {
  echo "
Description:
    Print and attempt to open the web address for the current repo/branch. Compatible with Github and Gitlab.

Usage:  ${0##*/} [-h] [-x] [-p]
    -p Only print the URLs, do not open browser on MacOS
    -x set -o xtrace
    -h Show help and exit
"
}

while getopts ':hpx' option ; do
  case "${option}" in
    h) usage ; exit 0 ;;
    p) print_only=true ;;
    x) set -x ;;
    *) usage ; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

file="$1"

branch="$(git rev-parse --abbrev-ref HEAD)"
repo_root="$(git rev-parse --show-toplevel)"
repo_cwd="${PWD#${repo_root}}"
remote_url="$(git remote get-url origin)"

if [[ "${remote_url}" =~ ^git* ]] ; then
  remote_url="$(echo "${remote_url/%.git/}" | sed -e 's#:#/#' -e 's#^git@#https://#')"
elif [[ "${remote_url}" =~ ^http* ]] ; then
  remote_url="${remote_url/%.git/}"
else
  echo "Not sure how to handle URL: ${remote_url}"
  exit 1
fi

print_gitlab() {
  branch_url="${remote_url}/-/tree/${branch}"
  web_url="${remote_url}/-/tree/${branch}${repo_cwd}"
  echo "CI Pipelines:        ${remote_url}/pipelines"
  echo "CI Jobs:             ${remote_url}/-/jobs"
  echo "Branch root:         ${branch}_url"
}

print_github() {
  branch_url="${remote_url}/tree/${branch}"
  web_url="${remote_url}/tree/${branch}${repo_cwd}"
  echo "Branch root:         ${branch_url}"
  if [ -n "${file}" ] ; then
    web_file_url="${remote_url}/blob/${branch}${repo_cwd}/${file}"
    echo "File url:            ${web_file_url}"
  fi
}

if [[ "${remote_url}" =~ gitlab.com ]] ; then
  print_gitlab
elif [[ "${remote_url}" =~ github.com ]] ; then
  print_github
else
  echo "ERROR: could not find github or gitlab in origin url"
  exit 1
fi

if [ ! "${branch_url}" == "${web_url}" ] ; then
  echo "Current branch dir:  $web_url"
fi

[[ "${print_only}" == "true" ]] || open "${web_file_url:-$web_url}"
