#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Check docker rate limits. https://docs.docker.com/docker-hub/download-rate-limit/
set -eu

repo="${1:-danielhoherd/rate-limit-test}"

token=$(curl -sSL "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${repo}:pull" | jq -r .token)
curl --head --header "Authorization: Bearer $token" "https://registry-1.docker.io/v2/${repo}/manifests/latest" 2>&1 | grep ratelimit
