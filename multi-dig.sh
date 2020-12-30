#!/usr/bin/env bash
# Run a dig query against lots of public DNS servers

usage() {
  cat <<EOF
Issue a dig query to many public DNS servers consecutively.

rsage: ${0##*/} [-v] <dig-args>

Options:
  -v   Be verbose

EOF
}

args=( "-n1" )

[[ "$1" == "-v" ]] && { args+=( "-t" ) ; shift ; }

[ "${#@}" -gt 0 ] || { usage ; exit 1 ; }

dns_servers=(
  # Cloudflare
  1.1.1.1
  1.0.0.1

  # Comodo
  8.26.56.26
  8.20.247.20

  # Google
  8.8.8.8
  8.8.4.4

  # OpenDNS
  208.67.222.222
  208.67.220.220

  # Quad9
  9.9.9.9
  149.112.112.112

  # Verisign
  64.6.64.6
  64.6.65.6
)

echo "${dns_servers[@]}" | xargs "${args[@]}" -I {} dig "${@}" {}
