#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Usage: add a yaml document separator to the beginning of all given yaml files only if it does not already exist

tempfile=$(mktemp)

for file in "$@"; do
  awk 'NR == 1 && $0 != "---" {print "---"} {print}' "${file}" > "${tempfile}" \
  && mv "${tempfile}" "${file}"
done
