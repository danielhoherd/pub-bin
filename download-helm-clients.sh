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
    -V    Show recent helm versions
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

show_recent_helm_versions() {
  curl -s https://api.github.com/repos/helm/helm/releases |
    jq -r -c '.[] | .tag_name + " " + .created_at' |
    grep -vE 'alpha|beta|rc' |
    column -t |
    sort
}

while getopts ':hsvVx' option ; do
  case "${option}" in
    h) usage ; exit 0 ;;
    s) SKIP_DEFAULTS=1 ;;
    v) VERBOSE=1 ;;
    V) show_recent_helm_versions ; exit 0 ;;
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

case "${HOSTTYPE}" in
  x86_64) arch=amd64 ;;
  *) echo "ERROR: Unknown architecture" ; exit 1 ;;
esac

case "$OSTYPE" in
  darwin*)
    platform=darwin ;;
  linux*)
    platform=linux ;;
  *)
    echo "ABORT: Unknown platform $OSTYPE." ; exit 1 ;;
esac

target_dir="$HOME/bin"

get_helm_version() {
  version="$1"
  print-verbose "Downloading helm version ${version}"
  [ -f "${target_dir}/helm-${version}" ] && { echo "Skipping: helm-${version} already exists" ; return ; }
  cd "$(mktemp -d)"
  base_filename="helm-v${version}-${platform}-${arch}"
  wget -q "https://get.helm.sh/${base_filename}.tar.gz"
  wget -q "https://get.helm.sh/${base_filename}.tar.gz.sha256"
  sha256=$(sha256sum "${base_filename}.tar.gz" | cut -d ' ' -f 1)
  grep -q "${sha256}" "${base_filename}.tar.gz.sha256" || { echo "ERROR sha256sum failed for ${base_filename}.tar.gz" ; return ; }
  tar xf "${base_filename}.tar.gz"
  mv -n ${platform}-${arch}/helm "${target_dir}/helm-${version}"
  [ -f "${target_dir}/helm-${version}" ] && echo "${target_dir}/helm-${version} Successfully downloaded" ;
}

for version in "${helm_releases[@]}" ; do
  get_helm_version "$version"
done

cd "$target_dir"
ln -fs helm-2.16.9 helm2
ln -fs helm-3.2.4 helm
ln -fs helm-3.2.4 helm3
