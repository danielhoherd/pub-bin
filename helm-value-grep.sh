#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
set -euo pipefail

usage() { cat <<HELPTEXT
grep the given helm release values for a string that will match against all levels of
the namespaceand its value. This is essentially the same as grepping the value string
as if it were given as --set foo.bar.baz=value

    -h  Print help
    -n  Kubernetes namespace
    -x  Enable xtrace

${0##*/} [-x] [-n namespace] <helm-deployment-name> <grep-string>

HELPTEXT
}

if ! yq --help | grep -q 'https://github.com/kislyuk/yq' ; then
  echo "ERROR: This script requires https://github.com/kislyuk/yq"
  exit 1
fi

if ! gron --help 2>&1 | grep -q '^Transform JSON' ; then
  echo "ERROR: This script requires https://github.com/tomnomnom/gron"
  exit 1
fi

if ! helm version | grep -q '"v3' ; then
  echo "ERROR: This script requires helm 3 https://github.com/helm/helm"
  exit 1
fi

while getopts ':hn:x' option ; do
  case "${option}" in
    n) namespace=("-n" "${OPTARG}") ;;
    x) set -x ;;
    h|*) usage ; exit 1 ;;
  esac
done
shift "$((OPTIND - 1))"

if [[ "${#@}" -ne 2 ]] ; then
  echo "ERROR: command must end with <deployment> <grep-string>"
  exit 1
fi

deployment="$1"
grep_string="$2"

helm get values "${namespace[@]}" "${deployment}" -o json | gron | grep "${grep_string}" | gron -u | yq -y .
