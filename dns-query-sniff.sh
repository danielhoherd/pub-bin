#!/usr/bin/env bash
# Author: danielh@zoosk.com - 2014-04-18
# License: MIT
# Listens for DNS queries and prints who is requesting what

# TODO:
#   Make a mode that only prints out new src hosts
#   While we're at it, make a mode that prints out how many times a src has queried
#   Make a -c count mode that works in tcpdump

if [ "$(id -u)" != "0" ]; then
    echo "ERROR: This script must be run with root privileges"
    exit 1
fi

# require tcpdump
command -v tcpdump &>/dev/null || { echo "This script requires tcpdump" ; exit 1 ; }

# Sniff only DNS queries and parse them
tcpdump -l -n -e dst port 53 |
awk '$14 == "A?" {print $10,$15 ; fflush("/dev/stdout") ;}' |
while read -r src domain ; do
    src=${src%.*}
    date "+%F %T%z $src requesting $domain" ;
done
