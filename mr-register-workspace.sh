#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Register a git worksapce in myrepos

[[ "$#" -gt 0 ]] || { echo "ERROR: Please provide at least one git workspace to register." ; exit 1 ; }

command -v mr >/dev/null 2>&1 || { echo "ERROR: 'mr' command is missing. See https://myrepos.branchable.com/install" ; exit 2 ; }

find "$@" -maxdepth 1 -mindepth 1 -print0 |
  sort -z |
  xargs -r -0 -n1 mr register
