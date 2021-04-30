#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Description: Download the given version of terraform to ~/bin/
#
# https://releases.hashicorp.com/terraform/
# https://github.com/hashicorp/terraform/releases

cd "$(mktemp -d)" || exit 1

usage(){ cat <<EOF
Download several versions of terraform into ~/bin

    -h  Print help
    -v  Enable verbose
    -x  Enable xtrace

${0##*/} [-x] [version_number ... version_number]
EOF
}

extra_args=()

while getopts ':xv' option ; do
  case "${option}" in
    x) set -x ;;
    v) export VERBOSE=1 ; extra_args+=( -w '%{url_effective}\n' ) ;;
    *) usage ; exit 1 ;
  esac
done
shift $((OPTIND - 1))

if [[ -z "${*}" ]] ; then
  versions=(
    "0.12.31" # 2021-04-26
    "0.13.7"  # 2021-04-26
    "0.14.11" # 2021-04-26
    "0.15.1"  # 2021-04-26
  )
else
  versions=( "${@}" )
fi

download_version() {
  dest="${HOME}/bin/terraform-${version}"

  [[ -d "${HOME}/bin" ]] || mkdir "${HOME}/bin"
  [[ -f "${dest}" ]] && { echo "Skipping: ${dest} already exists" ; return ; }

  read -r os arch < <(uname -s -m)
  case $arch in
    x86_64) arch="amd64" ;;
    i386) arch="386" ;;
    i686) arch="386" ;;
    x86) arch="386" ;;
    aarch64) arch="arm64" ;;
    armv5*) arch="armv5" ;;
    armv6*) arch="armv6" ;;
    armv7*) arch="armv7" ;;
    arm64*) arch="arm64" ;;
    *) echo "ABORT: Unknown architecture '$arch'" ; exit 1 ;;
  esac

  [ -n "$VERBOSE" ] && { echo ; echo "Trying to download with os=$os, arch=$arch, version=$version" ; }

  URL="https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${os,,}_${arch}.zip"

  if ! curl -sSLf "${extra_args[@]}" -o terraform.zip "$URL" ; then
    echo "Failed to download $URL"
    return
  fi


  unzip terraform.zip >/dev/null
  rm -rf terraform.zip
  mv terraform "${dest}"
  ( cd "${HOME}/bin" && ln -fs "terraform-${version}" "terraform-${version%.*}" )
  echo "Successfully downloaded ${dest}"
}

for version in "${versions[@]}" ; do
  download_version "${version}"
done
