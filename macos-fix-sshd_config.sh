#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Fix sshd_config that never terminates idle connections and kill all active connections.
# More details on why this is needed: https://danielhoherd.com/tech-notes/macos/#fix-sshd-client-timeout-config

[[ ! "${OSTYPE}" =~ ^darwin ]] && { echo "ERROR: while this should work on other unixes, it is meant for macOS." ; exit 1 ; }

set -xe

sudo sed -i '' -E 's/^#?ClientAliveInterval [0-9]+/ClientAliveInterval 120/ ; s/^#?ClientAliveCountMax [0-9]+/ClientAliveCountMax 5/ ;' /etc/ssh/sshd_config
sudo launchctl stop com.openssh.sshd
sudo launchctl start com.openssh.sshd
sudo pkill sshd
