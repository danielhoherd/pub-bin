#!/usr/bin/env bash
# Attempts to keep homebrew running and current

[ "$(uname)" == 'Darwin' ] || { echo "ABORT: This is meant for OS X." ; exit 1 ; }

sudo chown -R "${USER}" /usr/local/{bin,share} && \
( set -x ;
  git -C "$(brew --repo homebrew/core)" reset --hard origin/master
  brew doctor ;
  brew update ;
  brew upgrade ;
  brew cleanup ;
)
