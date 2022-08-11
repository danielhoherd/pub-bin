#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Show sorted count of committers per-line of the current contents of the repo.

[[ "${BASH_VERSINFO[0]}" -gt 3 ]] || {
    echo "Error: this requires bash > 3. You have ${BASH_VERSION}."
    exit 1
}

# Kill sub-shells on ctrl-c
trap "kill 0" SIGINT

usage() {
    echo "Searches the current path or given files of a git repo and shows who has made the most commits."
}

SED=$(command -v sed)
if [[ "$("$SED" --version 2> /dev/null | grep -c GNU)" -eq 0 ]]; then
    if ! SED=$(command -v gsed); then
        echo "GNU sed is required but not found."
        exit 1
    fi
fi

while getopts ':hx' option; do
    case "${option}" in
        h)
            usage
            exit
            ;;
        x) set -x ;;
        *)
            usage
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

git config --get remote.origin.url > /dev/null || {
    echo "Error: Not in a git repo, can't continue."
    exit 1
}

# If no args, list files from current directory
if [[ "${#@}" -eq 0 ]]; then
    mapfile -t files < <(git ls-files)
else
    # If args, list each file or files within a dir
    files=()
    for item in "$@"; do
        if [[ -d "$item" ]]; then
            mapfile -O "${#files[@]}" -t files < <(git ls-files "$item")
        else
            files+=("$item")
        fi
    done
fi

for file in "${files[@]}"; do
    git blame -w --line-porcelain -- "${file}" |
        "$SED" -n -- 's/^author-mail //p'
done | sort | uniq -c | sort -rn
