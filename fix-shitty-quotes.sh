#!/usr/bin/env bash
# shellcheck disable=SC1111
# Purpose: Remove unicode quotes from content.
# Caveats: This is just a dumb search/replace. It does not account for quoted
#          content that will be misquoted after removing unicode quotes.

if [[ "${#@}" -lt 1 ]] ; then
    echo "Replaces shitty quotes with normal quotes in all given files"
    echo "example: grep -rl '[“”’]' | xargs -r ${0##*/}"
    exit 1
fi

if [[ "$(uname)" == 'Darwin' ]] ; then
    no_gsed="GNU sed is required because bsd sed is lame. Make sure you have homebrew installed, then 'brew install gnu-sed'"
    brew_prefix=$(brew --prefix) || { echo "$no_gsed" && exit 1 ; }
    [[ ! -e "${brew_prefix}/bin/gsed" ]] && {
        echo "$no_gsed"
        exit 1
    }
    "${brew_prefix}/bin/gsed" -i 's/[“”]/"/g' "$@"
    "${brew_prefix}/bin/gsed" -i "s/’/'/g" "$@"
else
    sed -i 's/[“”]/"/g' "$@"
    sed -i "s/’/'/g" "$@"
fi
