#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
set -eo pipefail

if [[ $# -lt 1 ]] ; then
    cat <<EOF
Clone a git repo and check out all of its branches into workingtrees named after the branch.

Usage:

    ${0##*/} <repository_url>

WARNING: this can potentially create a LOT of directories with lots of data in the current directory!
EOF
    exit 1
fi

repo_url="$1"
repo_directory=$(basename "$repo_url" .git)

git clone "$repo_url" "$repo_directory"
cd "$repo_directory"

branches=$(git branch -a | grep "remotes/origin/" | grep -v -- '->' | sed 's|.*remotes/origin/||')
current_branch=$(git rev-parse --abbrev-ref HEAD)

for branch in $branches; do
    if [[ "$branch" == "$current_branch" ]] ; then
        continue
    fi

    # Create a working directory for the branch
    branch_directory="../${branch//\//_}_working_directory"
    git worktree add -b "$branch" "$branch_directory" "origin/$branch"
done
