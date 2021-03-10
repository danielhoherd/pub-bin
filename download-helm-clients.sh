#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
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

if [ -z "${SKIP_DEFAULTS}" ] ; then
  helm2_releases=(
    2.17.0  # 2020-10-26
  )
  helm3_releases=(
    3.2.4   # 2020-06-15
    3.3.4   # 2020-09-22
    3.4.2   # 2020-12-09
    3.5.3   # 2021-03-10
  )
fi

helm_releases=( "${helm2_releases[@]}" "${helm3_releases[@]}" "$@" )

case "${HOSTTYPE}" in
  x86_64) arch=amd64 ;;
  *) echo "ERROR: Unknown architecture, please open an issue: https://github.com/danielhoherd/pub-bin/issues" ; exit 1 ;;
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
  base_filename="helm-v${version}-${platform}-${arch}"
  [ -f "${target_dir}/helm-${version}" ] && { echo "Skipping: helm-${version} already exists (https://get.helm.sh/${base_filename}.tar.gz)" ; return ; }
  cd "$(mktemp -d)"
  wget -q "https://get.helm.sh/${base_filename}.tar.gz"
  wget -q "https://get.helm.sh/${base_filename}.tar.gz.sha256"
  sha256=$(sha256sum "${base_filename}.tar.gz" | cut -d ' ' -f 1)
  grep -q "${sha256}" "${base_filename}.tar.gz.sha256" || { echo "ERROR sha256sum failed for ${base_filename}.tar.gz" ; return ; }
  tar xf "${base_filename}.tar.gz"
  mv -n ${platform}-${arch}/helm "${target_dir}/helm-${version}"
  [ -f "${target_dir}/helm-${version}" ] && echo "${target_dir}/helm-${version} Successfully downloaded (https://get.helm.sh/${base_filename}.tar.gz)" ;
}

for version in "${helm_releases[@]}" ; do
  get_helm_version "$version"
done
set -x

cd "$target_dir"
ln -fs "helm-${helm2_releases[-1]}" helm2
ln -fs "helm-${helm3_releases[-1]}" helm
ln -fs "helm-${helm3_releases[-1]}" helm3
