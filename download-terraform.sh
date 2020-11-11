#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Description: Download the given version of terraform to ~/bin/
#
# https://releases.hashicorp.com/terraform/
set -e

version="${1:-0.12.29}"
dest="${HOME}/bin/terraform-${version}"

[[ -d "${HOME}/bin" ]] || mkdir "${HOME}/bin"
[[ -f "${dest}" ]] && { echo "ABORT: ${dest} already exists" ; exit 255 ; }

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
  *) echo "ABORT: Unknown architecture" ; exit 1 ;;
esac

cd "$(mktemp -d)"
curl -sSLfo terraform.zip "https://releases.hashicorp.com/terraform/${version}/terraform_${version}_${os,,}_${arch}.zip"
unzip terraform.zip >/dev/null
rm -rf terraform.zip
mv terraform "${dest}"
echo "successfully downloaded ${HOME}/bin/terraform-${version}"
