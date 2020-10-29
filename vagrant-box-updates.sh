#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Update all downloaded vagrant boxes to the latest version and delete old box versions

check_for_required_commands() {
  for command in "$@" ; do
    command -v "${command}" >/dev/null 2>&1 || missing_commands+=( "${command}" )
  done

  if [ "${#missing_commands[@]}" -gt 0 ] ; then
    date "+%F %T%z ${0##*/} ABORT: missing commands: ${missing_commands[*]}"
    exit 1
  fi
}

check_for_required_commands xargs vagrant awk date head

if [[ "${OSTYPE}" =~ ^darwin ]] ; then
  for cmd in awk date head sed sort ; do
    command -v "g${cmd}" > /dev/null || { echo "Command missing: 'g${cmd}'" ; error+=1 ; }
    # Evil eval because you can't create a function with a variable for a name
    eval "function ${cmd}() { "g${cmd}" \"\$@\" ; }"
    # shellcheck disable=SC2163
    export -f "${cmd}"
  done
  if [ "${error:-0}" -gt 0 ] ; then echo "Please install the missing commands." ; exit 1 ; fi ;
  yargs() { xargs "$@" ; }
elif [[ "${OSTYPE}" =~ ^linux ]] ; then
  # OSX xargs has an implicit -r and no explicit equivalent
  yargs() { xargs -r "$@" ; }
else
  echo "ERROR: unsure of how to handle ${OSTYPE}"
  exit 1
fi

date "+%F %T%z Pulling new versions of all existing Vagrant boxes"
vagrant box outdated --machine-readable --global |
  awk -F, '$4 == "warn" {print $5}' |
  awk -F"'" '{print $2}' |
  sort -u |
  yargs -n1 vagrant box update --box

date "+%F %T%z Deleting old veresions of each existing Vagrant box, keeping only the latest"
vagrant box list |
while read -r box _ ; do
  vagrant box list |
  grep "$box" |
  head -n -1 |
  awk '{print $3}' |
  sed 's/)$//' |
  sort --version-sort |
  yargs -t -n1 vagrant box remove "$box" --force --box-version
done

find ~/.vagrant.d/boxes -empty -delete
