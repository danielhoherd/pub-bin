#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT

from sys import argv, stdin

import pendulum
import typer


def timestamp_lines(show_delta: bool = typer.Option(None, help="Show the time delta between each line.")):
    """Take a stream from stdin and prefix each line with the timestamp of when it was read, and
    optionally the delta from the previous line.

    Most useful for slow streams.
    """

    date_section_len = 0
    old = pendulum.now()

    if stdin.isatty():
        print(f"Description: {__doc__}")
        print(f"Usage: <some_command> | {argv[0]}")
        raise SystemExit(1)
    for line in stdin:
        line = line.strip("\n")
        new = pendulum.now()
        delta = (new - old).in_words()
        if show_delta:
            date_section = f"{new.to_iso8601_string()} ({delta})"
        else:
            date_section = f"{new.to_iso8601_string()}"
        date_section_len = max(date_section_len, len(date_section))
        print(f"{date_section:<{date_section_len}} {line}")
        old = new


if __name__ == "__main__":
    typer.run(timestamp_lines)
