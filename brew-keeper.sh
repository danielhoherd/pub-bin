#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Attempt to keep homebrew running smooth and current

[[ "${OSTYPE}" =~ ^darwin ]]|| { echo "ABORT: This is meant for OS X." ; exit 1 ; }

sudo chown -R "${USER}" "$(brew --prefix)"/{bin,share} && \
( set -x ;
  brew doctor ;
  brew update ;
  brew upgrade ;
  brew cleanup ;
)
