#!/usr/bin/env bash
# Author: github.com/speed2exe - https://github.com/sharkdp/bat/issues/1536#issuecomment-2254051432

blame_lines=()
while IFS= read -r line; do
  blame_lines+=("$line")
done < <(git blame "$@" --color-lines --color-by-age)

first_line="$(head -n 1 "$@")"
offset=$(("${#blame_lines[0]}" - "${#first_line}"))

index=0
while IFS= read -r line; do
  echo "${blame_lines[$index]:0:$offset}$line"
  ((index++))
done < <(bat --plain --color=always "$@")
