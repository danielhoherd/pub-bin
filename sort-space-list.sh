#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Description: sorts a space-separated list on a single line

sort_space_list ()
{
    for X in ${*:-$(cat /dev/stdin)};
    do
        echo "${X}";
    done | sort | while read -r line; do
        echo -n "${line} ";
    done;
    echo ''
}

sort_space_list "$@"
