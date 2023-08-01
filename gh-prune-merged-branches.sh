#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: delete all local git branches that have a merged github PR associated with them

git branch |
awk '{print $NF}' |
grep -v "^$(awk -F/ '{print $NF}' .git/refs/remotes/origin/HEAD)$" |
while read -r branch ; do
  echo "branch=$branch"
  [[ -z "$branch" ]] && continue
  gh pr view "$branch" --json state --jq .state |
    grep -q '^MERGED$' && git branch -D "$branch"
done
