#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: Unlicense
# Purpose: Download several versions of helm client
#
# https://get.helm.sh/helm-v2.11.0-darwin-amd64.tar.gz
# https://get.helm.sh/helm-v2.11.0-darwin-amd64.tar.gz.sha256
# https://github.com/helm/helm
set -e

usage() {
  echo "
Description:
    Download latest minor version helm clients, and optionally other versions.

Usage:
    ${0##*/} [-h|-v|-x] [helm_version ...]

    -h    Show this help text
    -s    Skip downloading default list, only download given versions
    -v    Enable verbose mode
    -x    set -o xtrace

See Also:
    https://github.com/helm/helm/releases
"
}

print-verbose() {
  [ "${#@}" == 0 ] && return 1
  [ -n "${VERBOSE}" ] || return 0
  printf '\e[0;35m%s\e[00m\n' "$(date "+%F %T%z") VERBOSE: $*"
}

while getopts ':hsvx' option ; do
  case "${option}" in
    h) usage ; exit 0 ;;
    s) SKIP_DEFAULTS=1 ;;
    v) VERBOSE=1 ;;
    x) set -x ;;
    *) echo "ERROR: Unknown option: -${OPTARG}" ; usage ; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

helm_releases=()

if [ -z "${SKIP_DEFAULTS}" ] ; then
  helm_releases+=(
    2.14.3  # 2019-07-30
    2.15.2  # 2019-10-29
    2.16.9  # 2020-06-16
    3.0.3   # 2020-01-29
    3.1.3   # 2020-04-22
    3.2.4   # 2020-06-15
  )
fi

helm_releases+=( "$@" )

case "$OSTYPE" in
  darwin*)
    platform=darwin ;;
  linux*)
    platform=linux ;;
  *)
    echo "ABORT: Unknown platform $OS." ; exit 1 ;;
esac

target_dir="$HOME/bin"

for version in "${helm_releases[@]}" ; do
  print-verbose "Downloading helm version ${version}"
  [ -f "${target_dir}/helm-${version}" ] && { echo "Skipping helm-${version}: already exists" ; continue ; }
  cd "$(mktemp -d)"
  wget -q "https://get.helm.sh/helm-v${version}-${platform}-amd64.tar.gz"
  wget -q "https://get.helm.sh/helm-v${version}-${platform}-amd64.tar.gz.sha256"
  sha256=$(sha256sum "helm-v${version}-${platform}-amd64.tar.gz" | cut -d ' ' -f 1)
  grep -q "${sha256}" "helm-v${version}-${platform}-amd64.tar.gz.sha256" || { echo "ERROR sha256sum failed for helm-v${version}-${platform}-amd64.tar.gz" ; continue ; }
  tar xf "helm-v${version}-${platform}-amd64.tar.gz"
  mv -n ${platform}-amd64/helm "${target_dir}/helm-${version}"
  [ -f "${target_dir}/helm-${version}" ] && echo "${target_dir}/helm-${version} Successfully downloaded" ;
done

cd "$target_dir"
ln -fs helm-2.16.9 helm2
ln -fs helm-3.2.4 helm
ln -fs helm-3.2.4 helm3
