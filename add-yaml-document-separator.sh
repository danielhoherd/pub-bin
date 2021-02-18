#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Usage: add a yaml document separator to the beginning of all given yaml files only if it does not already exist

for file in "$@"; do
  tempfile=$(mktemp)
  awk 'NR == 1 && $0 != "---" {print "---"} {print}' "${file}" > "${tempfile}" \
  && mv "${tempfile}" "${file}"
done
