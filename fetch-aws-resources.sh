#!/usr/bin/env bash
# License: Unlicense
# Author: github.com/danielhoherd
# Purpose: Fetch information about used AWS resources and output as JSON per region.
#          This assumes credentials are set up for awscli and awless
#          https://github.com/wallix/awless

check_for_required_commands() {
  for command in "$@" ; do
    command -v "${command}" >/dev/null 2>&1 || missing_commands+=( "${command}" )
  done

  if [ "${#missing_commands[@]}" -gt 0 ] ; then
    date "+%F %T%z ABORT: missing commands: ${missing_commands[*]}"
    exit 1
  fi
}

check_for_required_commands aws awless jq

aws ec2 describe-regions |
jq -r '. | "\( .Regions[].RegionName )"' |
while read -r region ; do
  awless --aws-region "$region" --format json list instances |
  jq -S '. | walk( if type == "array" then sort else . end )' > "${region}-list-instances.json" ;
done ;
