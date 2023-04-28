#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Download several versions of kubectl

usage() {
  echo "
Description:
    Download kubectl clients for the last 6 or so minor versions of kubernetes

Usage:
    ${0##*/} [-h|-v|-x]

    -h    Show this help text
    -v    Enable verbose mode
    -x    set -o xtrace

See Also:
    https://github.com/kubernetes/kubectl/tags
    curl --silent https://api.github.com/repos/kubernetes/kubectl/tags?per_page=100 | jq -r '.[].name' | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V

Version EOLs:
    AKS: https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions#aks-kubernetes-release-calendar
    EKS: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html#kubernetes-release-calendar
    GKE: https://cloud.google.com/kubernetes-engine/docs/release-schedule
    Upstream: https://github.com/kubernetes/website/blob/main/content/en/releases/patch-releases.md

"
}

print-verbose() {
  [[ "${#@}" == 0 ]] && return 1
  [[ -n "${VERBOSE}" ]] || return 0
  printf '\e[0;35m%s\e[00m\n' "$(date "+%F %T%z") VERBOSE: $*"
}

while getopts ':hvx' option ; do
  case "${option}" in
    h) usage ; exit 0 ;;
    v) VERBOSE=1 ;;
    x) set -x ;;
    *) echo "ERROR: Unknown option: -${OPTARG}" ; usage ; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

kubectl_releases=(
  1.23.17
  1.24.13
  1.25.9
  1.26.4
)

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
[[ -d "$target_dir" ]] || mkdir "$target_dir" || { echo "ERROR: $target_dir is not a dir and we cannot create it." ; exit 1 ; }

get_kubectl_version() {
  version="$1"
  url="https://dl.k8s.io/release/v${version}/bin/${platform}/${arch}/kubectl"
  target_filename="kubectl-${version}"
  target_filename="${target_dir}/${target_filename}"
  target_filename_trimmed="${target_filename%.*}" # trim to just major.minor
  print-verbose "Downloading ${target_filename} from ${url}"
  [[ -f "${target_filename}" ]] && { echo "Skipping ${url}, target file already exists: ${target_filename}" ; return ; }
  cd "$(mktemp -d)" || exit 1
  { curl -fsSLo "${target_filename}" "${url}" && chmod +x "${target_filename}" ; } || return 1
  [[ -f "${target_filename}" ]] && echo "${target_filename} successfully downloaded (${url})" ;
  ln -fsv "${target_filename}" "${target_filename_trimmed}"
}

for version in "${kubectl_releases[@]}" ; do
  get_kubectl_version "$version"
done

# Start with index 3 so we can be within window for latest k8s server to oldest supported cli version
for index in 3 2 1 ; do
  target_file="${target_dir}/kubectl-${kubectl_releases[-${index}]}"
  if [[ -f "${target_file}" ]] ; then
    ln -fsv "${target_file}" "${target_dir}/kubectl" && break
  fi
done
