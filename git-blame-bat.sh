#!/usr/bin/env bash
# Author: github.com/speed2exe - https://github.com/sharkdp/bat/issues/1536#issuecomment-2254051432

if [[ $# -eq 0 ]]; then
  echo "Usage: git blame-bat [options] <file>"
  echo
  echo "Options:"
  echo "  -w  Ignore whitespace changes"
  exit 1
fi

git_blame_args=( "--color-lines" "--color-by-age" )

if [[ "$1" == "-w" ]]; then
  git_blame_args+=("-w")
  shift
fi

blame_lines=()
while IFS= read -r line; do
  blame_lines+=("$line")
done < <(git blame "${git_blame_args[@]}" "$@")

first_line="$(head -n 1 "$@")"
offset=$(("${#blame_lines[0]}" - "${#first_line}"))

index=0
while IFS= read -r line; do
  echo "${blame_lines[$index]:0:$offset}$line"
  ((index++))
done < <(bat --plain --color=always "$@")
