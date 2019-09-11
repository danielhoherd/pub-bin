#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: Unlicense
# Purpose: Print and attempt to open the web address for the current repo/branch.
#          Compatible with git protocol URLs in Github and Gitlab

set -e

branch="$(git rev-parse --abbrev-ref HEAD)"
remote_url="$(git remote get-url origin | sed -e 's#:#/#' -e 's#^git@#https://#' -e 's#\.git$##')"

open "$remote_url/tree/$branch"
