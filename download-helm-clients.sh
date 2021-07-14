#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Download several versions of helm client
#
# https://get.helm.sh/helm-v2.11.0-darwin-amd64.tar.gz
# https://get.helm.sh/helm-v2.11.0-darwin-amd64.tar.gz.sha256
# https://github.com/helm/helm

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
    3.4.2  # 2020-12-09
    3.5.4  # 2021-04-14
    3.6.3  # 2021-07-14
  )
fi

helm_releases=( "${helm2_releases[@]}" "${helm3_releases[@]}" "$@" )

case "${HOSTTYPE}" in
  x86_64) arch=amd64 ;;
  aarch64) arch=arm64 ;;
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

target_dir="${HOME}/bin"
[ -d "$target_dir" ] || mkdir "$target_dir" || { echo "ERROR: $target_dir is not a dir and we cannot create it." ; exit 1 ; }

get_helm_version() {
  version="$1"
  base_filename="helm-v${version}-${platform}-${arch}"
  target_filename="${target_dir}/helm-${version}"
  archive_file="${base_filename}.tar.gz"
  checksum_file="${base_filename}.tar.gz.sha256"
  archive_url="https://get.helm.sh/${archive_file}"
  checksum_url="https://get.helm.sh/${checksum_file}"
  print-verbose "Downloading ${target_filename} from ${archive_url}"
  [ -f "${target_filename}" ] && { echo "Skipping ${archive_url}, target file already exists: ${target_filename}" ; return ; }
  cd "$(mktemp -d)" || exit 1
  curl -fsSLO "$archive_url" || return 1
  curl -fsSLO "$checksum_url" || return 1
  sha256=$(sha256sum "${archive_file}" | cut -d ' ' -f 1)
  grep -q "${sha256}" "${checksum_file}" || { echo "ERROR sha256sum failed for ${archive_file} (${archive_url})" ; return ; }
  tar xf "${archive_file}"
  mv -n "${platform}-${arch}/helm" "${target_filename}"
  [ -f "${target_filename}" ] && echo "${target_filename} successfully downloaded (${archive_url})" ;
}

for version in "${helm_releases[@]}" ; do
  get_helm_version "$version"
done

[ -f "${target_dir}/helm-${helm2_releases[-1]}" ] && ln -fsv "${target_dir}/helm-${helm2_releases[-1]}" "${target_dir}/helm2"
[ -f "${target_dir}/helm-${helm3_releases[-1]}" ] && {
  ln -fsv "${target_dir}/helm-${helm3_releases[-1]}" "${target_dir}/helm"
  ln -fsv "${target_dir}/helm-${helm3_releases[-1]}" "${target_dir}/helm3"
}
