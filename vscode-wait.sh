#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: wrapper for EDITOR that will open vscode and wait for all editor tabs to be closed before continuing
# Example usage: EDITOR=$(which vscode-wait.sh) crontab -e

code -w "$@"
