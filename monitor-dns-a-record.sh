#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Description: Monitor a DNS A record and print status, prowl if it changes. (requires external command 'prowl')

if [[ "$#" -eq 0 ]] ; then
  echo "Usage: $0 <hostname> [ip_address]"
  exit 1
fi

date_print() {
  echo "$(date "+%FT%T%z") $*"
}

hostname=$1
date_print "Monitoring $hostname $ip_address"

if [[ -n "$2" ]] ; then
  ip_address="$2"
else
  if ! ip_address=$(dig -4 +short @8.8.8.8 A "$hostname") ; then
    date_print "ERROR: could not resolve IP address for host $hostname"
    exit 1
  fi
fi
date_print "$hostname is $ip_address"

check_dns_a_record(){
  local hostname=$1
  local ip_address=$2

  if ! resolved_address=$(dig +short @8.8.8.8 "$hostname") ; then
    date_print "ERROR: could not resolve ip address"
    return 1
  fi

  if ! [[ "${resolved_address}" == "${ip_address}" ]] ; then
    message="DNS for $hostname changed from $ip_address to $resolved_address"
    date_print "ALERT: $message"
    prowl "$message"
    return 2
  fi

  date_print "DNS for $hostname remains $ip_address"
  return 0
}

while true ; do
  check_dns_a_record "$hostname" "$ip_address"
  sleep 60
done
