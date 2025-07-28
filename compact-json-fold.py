#!/usr/bin/env python3
# Author: github.com/danielhoherd and GH copilot GPT-4.1
# License: MIT
"""Fold json into a compact form while still maintaining valid syntax.

Folded lines may be longer than specified if there is no other way to maintain valid json syntax.

This is a response to https://github.com/jqlang/jq/issues/3378"""

import json
import sys


def minified_json(obj):
    # Use separators to remove unnecessary whitespace
    return json.dumps(obj, separators=(",", ":"))


# TODO: This algorithm is sub-optimal. There are cases where breaking before a character
#       would allow the line to fall within the max length limit.
def break_json_lines(s, maxlen):
    breaks = {",", "]", "}", ":"}
    out = []
    start = 0
    in_str = False
    esc = False
    last_safe = None

    for i, c in enumerate(s):
        if in_str:
            if esc:
                esc = False
            elif c == "\\":
                esc = True
            elif c == '"':
                in_str = False
        elif c == '"':
            in_str = True
        elif c in breaks:
            last_safe = i + 1  # safe break after this char

        # If reached maxlen, break at last safe if possible
        if i - start + 1 >= maxlen and (last_safe is not None and last_safe > start):
            out.append(s[start:last_safe])
            start = last_safe
            last_safe = None

    # Append remaining
    if start < len(s):
        out.append(s[start:])

    return "\n".join(out)


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Output minified JSON with line breaks at N chars, only after allowed characters.")
    parser.add_argument("input", nargs="?", type=argparse.FileType("r"), default=sys.stdin, help="Input JSON file (or stdin).")
    parser.add_argument("-n", "--max-line-length", type=int, default=80, help="Maximum line length. (default 80)")
    args = parser.parse_args()

    # Read and load JSON
    obj = json.load(args.input)
    minified = minified_json(obj)
    result = break_json_lines(minified, args.max_line_length)
    print(result)


if __name__ == "__main__":
    main()
