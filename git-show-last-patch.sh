#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Show the last patch version for each semver tag

git tag -l "v*.*.*" --sort=-v:refname | awk -F. '!seen[$1,$2]++'
