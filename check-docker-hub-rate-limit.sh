#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Check docker rate limits. https://docs.docker.com/docker-hub/download-rate-limit/
#
# Unfortunately, as of 2020-11-04, you can't check your rate limit without spending one of your allotted API requests:
# > valid non-rate-limited manifest API requests to Hub will include the following rate limit headers
# It would be great if they included this header on every request, including HEAD requests, so hopefully they fix that.

set -eu

repo="${1:-danielhoherd/rate-limit-test}"

token=$(curl -sSL "https://auth.docker.io/token?service=registry.docker.io&scope=repository:${repo}:pull" | jq -r .token)
curl -v -H "Authorization: Bearer $token" "https://registry-1.docker.io/v2/${repo}/manifests/latest" 2>&1 | grep -Eo 'RateLimit-(Limit|Remaining): [0-9]+'

exit 0
