#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
set -e

usage() {
  echo "
Description:
    Print and optionally open the web address for the current repo/branch/file. Compatible with Github and Gitlab.

Usage:  ${0##*/} [-h] [-x] [-0]
    -o Open the branch at the given dir or file
    -x set -o xtrace
    -h Show help and exit
"
}

print_only=true

while getopts ':hox' option ; do
  case "${option}" in
    h) usage ; exit 0 ;;
    o) print_only=false ;;
    x) set -x ;;
    *) usage ; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

file="$1"

branch="$(git rev-parse --abbrev-ref HEAD)"  # bare branch name
main_branch=$(git ls-remote --symref origin HEAD | awk '$2 ~ /^refs/ { sub(".*/","", $2) ; print $2 }')  # assumes remote 'origin'
sha="$(git rev-parse HEAD)"  # full hash
short_sha="${sha::10}"
repo_root="$(git rev-parse --show-toplevel)"  # absolute path to git root
repo_cwd="${PWD#"${repo_root}"}"  # cwd relative to repo_root, with leading slash (eg: /bin) # TODO: fix this to not have leading slash
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
  sha_tree_url="${remote_url_https}/-/tree/${short_sha}"
  sha_commit_url="${remote_url_https}/-/commit/${sha}"
  web_url="${remote_url_https}/-/tree/${branch}${repo_cwd}"
  branch_compare_url="${remote_url_https}/-/compare/${main_branch}...${branch}"
  sha_compare_url="${remote_url_https}/-/compare/${main_branch}...${sha}"
  echo "CI Pipelines:        ${remote_url_https}/-/pipelines"
  echo "CI Jobs:             ${remote_url_https}/-/jobs"
  echo "Branch root:         ${branch_url}"
  echo "SHA root:            ${sha_tree_url}"
  echo "Commit:              ${sha_commit_url}"
  if [ "${branch}" != "${main_branch}" ] ; then
    echo "Compare branch:      ${branch_compare_url}"
  fi
  echo "Compare sha:         ${sha_compare_url}"
  if [ -n "${file}" ] ; then
    web_file_url_branch="${remote_url_https}/-/blob/${branch}${repo_cwd}/${file}"
    web_file_url_sha="${remote_url_https}/-/blob/${short_sha}${repo_cwd}/${file}"
    echo "File url (branch):   ${web_file_url_branch}"
    echo "File url (sha):      ${web_file_url_sha}"
  fi
}

print_github() {
  branch_url="${remote_url_https}/tree/${branch}"
  sha_tree_url="${remote_url_https}/tree/${short_sha}${repo_cwd}"
  sha_commit_url="${remote_url_https}/commit/${sha}"
  web_url="${remote_url_https}/tree/${branch}${repo_cwd}"
  branch_compare_url="${remote_url_https}/compare/${main_branch}...${branch}"
  sha_compare_url="${remote_url_https}/compare/${main_branch}...${sha}"

  if [ -d "${repo_root}/.github/workflows" ] ; then
    echo "Github Actions:      ${remote_url_https}/actions"
  fi

  if [ -f "${repo_root}/.circleci/config.yml" ] ; then
    echo "CircleCI:            https://app.circleci.com/pipelines/github/${remote_url_https#*.com?}?branch=$branch"
  fi

  echo "Branch root:         ${branch_url}"
  echo "SHA root:            ${sha_tree_url}"
  echo "Commit:              ${sha_commit_url}"
  if [ "${branch}" != "${main_branch}" ] ; then
    echo "Compare branch:      ${branch_compare_url}"
  fi
  echo "Compare sha:         ${sha_compare_url}"

  if [ -n "${file}" ] ; then
    web_file_url_branch="${remote_url_https}/blob/${branch}${repo_cwd}/${file}"
    web_file_url_sha="${remote_url_https}/blob/${short_sha}${repo_cwd}/${file}"  # only use the last 10 chars of the sha
    echo "File url (branch):   ${web_file_url_branch}"
    echo "File url (sha):      ${web_file_url_sha}"
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

if [[ ! "${print_only}" == "true" ]] ; then
  case "${OSTYPE}" in
    darwin*) open "${web_file_url_sha:-$web_url}" ;;
    linux-gnu) echo "ERROR: cannot handle opening browser in linux." ; exit 1 ;;
    *) echo "ERROR: cannot handle opening browser for OSTYPE '${OSTYPE}'" ; exit 1 ;;
  esac
fi
