#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
"""Takes a stream from stdin and prefixes it with the timestamp it was read and the delta from the previous line. Most useful for slow streams."""

from sys import argv, stdin

import pendulum

old = pendulum.now()

if stdin.isatty():
    print(f"Description: {__doc__}")
    print(f"Usage: <some_command> | {argv[0]}")
    raise SystemExit(1)
else:
    for line in stdin:
        new = pendulum.now()
        delta = new - old
        print(f"{new.to_iso8601_string()} ({delta.in_words()}) {line.strip()}")
        old = new
