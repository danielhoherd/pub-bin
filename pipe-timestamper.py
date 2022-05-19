#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
"""Takes a stream from stdin and prefixes it with the timestamp it was read and the delta from the previous line. Most useful for slow streams."""

from sys import argv, stdin

import pendulum
import typer

app = typer.Typer()


def timestamp_lines(show_delta: bool = typer.Option(None, help="Show the time delta between each line.")):
    """
    Takes a stream from stdin and prefixes it with the timestamp it was read and
    the delta from the previous line. Most useful for slow streams.
    """

    old = pendulum.now()

    if stdin.isatty():
        print(f"Description: {__doc__}")
        print(f"Usage: <some_command> | {argv[0]}")
        raise SystemExit(1)
    else:
        for line in stdin:
            line = line.strip("\n")
            new = pendulum.now()
            delta = (new - old).in_words()
            if show_delta:
                print(f"{new.to_iso8601_string()} ({delta}) {line}")
            else:
                print(f"{new.to_iso8601_string()} {line}")
            old = new


if __name__ == "__main__":
    typer.run(timestamp_lines)
