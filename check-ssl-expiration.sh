#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT License

usage(){ cat <<EOF
Show TLS dates for the given server and optional port.

    -h  Print help
    -p  Port number the server is running (default 443)
    -x  Enable xtrace

${0##*/} [-x] [-p portname] <servername>
EOF
}

for cmd in dig openssl ; do
  command -v "$cmd" >/dev/null || {
    echo "ERROR: this script requires the '$cmd' command."
    errors+=1
  }
done
[[ "$errors" -gt 0 ]] && exit 1

while getopts ':hxp:' option ; do
  case "${option}" in
    p) port="${OPTARG}" ;;
    x) set -x ;;
    h|*) usage ; exit 1 ;;
  esac
done
shift "$((OPTIND - 1))"

[[ "${#@}" -eq 1 ]] || {
  usage
  exit 1
}

openssl s_client -connect "${1}:${port:-443}" -servername "$1" < /dev/null 2>/dev/null |
  openssl x509 -startdate -enddate -noout
