#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: Unlicense
# Purpose: Download several versions of helm client
#
# https://get.helm.sh/helm-v2.11.0-darwin-amd64.tar.gz
# https://get.helm.sh/helm-v2.11.0-darwin-amd64.tar.gz.sha256
# https://github.com/helm/helm
set -e

helm_releases=(
  2.11.0
  2.12.3
  2.13.1
  2.14.3
  2.15.2
  2.16.1
  3.0.3
)

OS=$(uname -s)
case "$OS" in
  Darwin)
    platform=darwin ;;
  Linux)
    platform=linux ;;
  *)
    echo "ABORT: Unknown platform $OS." ; exit 1 ;;
esac

target_dir="$HOME/bin"

for version in "${helm_releases[@]}" ; do
  [ -f "${target_dir}/helm-${version}" ] && { echo "${target_dir}/helm-${version} already exists" ; continue ; }
  cd "$(mktemp -d)"
  wget -q "https://get.helm.sh/helm-v${version}-${platform}-amd64.tar.gz"
  wget -q "https://get.helm.sh/helm-v${version}-${platform}-amd64.tar.gz.sha256"
  sha256=$(sha256sum "helm-v${version}-${platform}-amd64.tar.gz" | cut -d ' ' -f 1)
  grep -q "${sha256}" "helm-v${version}-${platform}-amd64.tar.gz.sha256" || { echo "ERROR sha256sum failed for helm-v${version}-${platform}-amd64.tar.gz" ; continue ; }
  tar xf "helm-v${version}-${platform}-amd64.tar.gz"
  mv -n ${platform}-amd64/helm "${target_dir}/helm-${version}"
  [ -f "${target_dir}/helm-${version}" ] && echo "${target_dir}/helm-${version} Successfully downloaded" ;
done
