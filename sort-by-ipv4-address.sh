#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Description: sort lines by ipv4 address

if [[ "$1" = "--help" ]] || [[ "$1" = "-h" ]] ; then
    cat <<EOF
Sort lines by ipv4 IP address. The first column of each line must be an ipv4 address.

Usage:  ${0##*/} [sort args] file1 [file2]
        <command> | ${0##*/}

Example usage:
    Sort a list uniquely by ip address and output to another file:
        ${0##*/} -u -o sorted-ipv4-allow-list.txt ipv4-allow-list.txt

EOF
    exit
fi

sort -b -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 "$@"
