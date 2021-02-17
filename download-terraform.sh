#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Description: Download the given version of terraform to ~/bin/
#
# https://releases.hashicorp.com/terraform/
# https://github.com/hashicorp/terraform/releases

cd "$(mktemp -d)" || exit 1

if [[ -z "${*}" ]] ; then
  versions=(
    "0.12.30" # 2021-01-06
    "0.13.6"  # 2021-01-06
    "0.14.7"  # 2022-02-17
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
    *) echo "ABORT: Unknown architecture '$arch'" ; return ;;
  esac

  curl -sSLfo terraform.zip "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${os,,}_${arch}.zip" || return
  unzip terraform.zip >/dev/null
  rm -rf terraform.zip
  mv terraform "${dest}"
  ( cd "${HOME}/bin" && ln -fs "terraform-${version}" "terraform-${version%.*}" )
  echo "Successfully downloaded ${dest}"
}

for version in "${versions[@]}" ; do
  download_version "${version}"
done
