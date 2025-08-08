#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Attempt to keep homebrew running smooth and current

[[ "${OSTYPE}" =~ ^darwin ]]|| { echo "ABORT: This is meant for OS X." ; exit 1 ; }

find "$(brew --prefix)"/{bin,share} ! -user "$USER" -print0 |
  xargs -0 -r sudo chown "$USER" && \
( set -x ;
  brew doctor ;
  brew update ;
  brew upgrade ;
  brew cleanup ;
)
