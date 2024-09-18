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

See also: https://github.com/tfutils/tfenv
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
  # https://endoflife.date/terraform
  versions=(
    "1.6.6"   # 2023-12-13
    "1.7.5"   # 2024-03-13
    "1.8.5"   # 2024-06-05
    "1.9.6"   # 2024-09-18
  )
else
  versions=( "${@}" )
fi

target_dir="${HOME}/bin"
[[ -d "$target_dir" ]] || mkdir "$target_dir" || { echo "ERROR: $target_dir is not a dir and we cannot create it." ; exit 1 ; }

download_version() {
  dest="${target_dir}/terraform-${version}"

  tempdir="$(mktemp -d)"
  if ! cd "$tempdir" ; then
    echo "ERROR: unable to cd to tempdir $tempdir"
    exit 1
  fi

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

  [[ -n "$VERBOSE" ]] && { echo ; echo "Trying to download with os=$os, arch=$arch, version=$version" ; }

  URL="https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${os,,}_${arch}.zip"

  [[ -f "${dest}" ]] && { echo "Skipping URL ${URL} which already exists at ${dest}" ; return ; }

  if ! curl -sSLf "${extra_args[@]}" -o terraform.zip "$URL" ; then
    echo "Failed to download $URL"
    return
  fi

  unzip terraform.zip >/dev/null
  rm -f terraform.zip LICENSE.txt
  mv terraform "${dest}"
  ( cd "${target_dir}" && ln -fsv "terraform-${version}" "terraform-${version%.*}" )
  echo "Successfully downloaded ${dest} from ${URL}"
}

for version in "${versions[@]}" ; do
  download_version "${version}"
done

ln -fsv "${target_dir}/terraform-${versions[-1]}" "${target_dir}/terraform"
