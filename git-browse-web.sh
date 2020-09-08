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

branch="$(git rev-parse --abbrev-ref HEAD)"  # bare branch name
repo_root="$(git rev-parse --show-toplevel)"  # absolute path to git root
repo_cwd="${PWD#${repo_root}}"  # cwd relative to repo_root, with leading slash (eg: /bin) # TODO: fix this to not have leading slash
remote_url_original="$(git remote get-url origin)"  # the remote checkout url (eg: git@github.com:some_org_name/some_repo.git)
# remote_url_https is the https link to the repo (eg: https://github.com/some_org_name/some_repo)
if [[ "${remote_url_original}" =~ ^git* ]] ; then
  remote_url_https="$(echo "${remote_url_original/%.git/}" | sed -e 's#:#/#' -e 's#^git@#https://#')"
elif [[ "${remote_url_original}" =~ ^http* ]] ; then
  remote_url_https="${remote_url_original/%.git/}"
else
  echo "Not sure how to handle URL: ${remote_url_original}"
  exit 1
fi

print_gitlab() {
  branch_url="${remote_url_https}/-/tree/${branch}"
  web_url="${remote_url_https}/-/tree/${branch}${repo_cwd}"
  echo "CI Pipelines:        ${remote_url_https}/pipelines"
  echo "CI Jobs:             ${remote_url_https}/-/jobs"
  echo "Branch root:         ${branch}_url"
  if [ -n "${file}" ] ; then
    web_file_url="${remote_url_https}/-/blob/${branch}${repo_cwd}/${file}"
    echo "File url:            ${web_file_url}"
  fi
}

print_github() {
  branch_url="${remote_url_https}/tree/${branch}"
  web_url="${remote_url_https}/tree/${branch}${repo_cwd}"
  echo "Branch root:         ${branch_url}"
  if [ -n "${file}" ] ; then
    web_file_url="${remote_url_https}/blob/${branch}${repo_cwd}/${file}"
    echo "File url:            ${web_file_url}"
  fi

  if [ -f "${repo_root}/.circleci/config.yml" ] ; then
    echo "CircleCI:            https://app.circleci.com/pipelines/github/${remote_url_https#*.com?}?branch=$branch"
  fi
}

if [[ "${remote_url_https}" =~ gitlab.com ]] ; then
  print_gitlab
elif [[ "${remote_url_https}" =~ github.com ]] ; then
  print_github
else
  echo "ERROR: could not find github or gitlab in origin url"
  exit 1
fi

if [ ! "${branch_url}" == "${web_url}" ] ; then
  echo "Current branch dir:  $web_url"
fi

[[ "${print_only}" == "true" ]] || open "${web_file_url:-$web_url}"
