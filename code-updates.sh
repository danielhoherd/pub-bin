#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Iterate code dirs and pull svn and git updates

usage() {
  echo "Usage:  ${0##*/} [-a] [-x] [zero or more code_workspaces]"
  echo "    -a  Force git gc --aggressive"
  echo "    -p  Number of parallel jobs to run"
  echo "    -x  Enable xtrace"
}

PARALLEL=3

while getopts :ahnp:x option ; do
  case "${option}" in
    a) aggressive=yes ;;
    n) aggressive=no ;;
    p) PARALLEL="$OPTARG" ;;
    x) set -x ;;
    h|*) usage ; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

export GC_TYPE='--auto'
export GIT_SSH_COMMAND="ssh -o ConnectTimeout=5"

trap "kill 0" SIGINT

if [ $((RANDOM % 500)) -eq 9 ] || [ "${aggressive}" == 'yes' ] ; then
  GC_TYPE='--aggressive'
  date "+%F %T%z 'git gc ${GC_TYPE}' selected"
  ( set -x ; pre-commit gc ; )
fi

for host in gitlab.com github.com ; do
  ssh-keyscan "$host" 2>/dev/null |
  while read -r line ; do
    grep -q "$line" ~/.ssh/known_hosts || echo "$line" >> ~/.ssh/known_hosts
  done
done

code_update() {
  echo "$(
    exec 2>&1
    repo=$1
    if [ -d "${repo}" ] ; then
      cd "${repo}" || ( echo "ERROR: cannot cd to ${repo}" ; return 1 ; )
      date "+%F %T%z ${repo}"
      if [ -e .git ] ; then
        git remote | xargs -I {} git remote set-head {} -a
        if git config --get remote.origin.url > /dev/null ; then
          git pull -q || echo "$(date '+%F %T%z') Problems with ${PWD}"
          git remote prune origin
          git gc "${GC_TYPE}"
          if [ -f .pre-commit-config.yaml ] ; then pre-commit install --install-hooks >/dev/null ; fi
        else
          date "+%F %T%z Skipping $repo, remote origin is not working: $?"
        fi
      elif [ -e .svn ] ; then
        svn up
      fi
    fi
  )"
}

export -f code_update

DIRS="${HOME}/code"
if [ "$#" -gt 0 ] ; then
  DIRS=( "$@" )
fi

find "${DIRS[@]}" -mindepth 1 -maxdepth 1 -type d -print0 |
  sort -z |
  xargs -P"${PARALLEL}" -0 -I{} bash -c "code_update {}" \;
