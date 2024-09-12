#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
from sys import stderr, stdin

import pendulum
import typer


def timestamp_lines(separator: str = typer.Option(" ", "--separator", "-s"), file: str = typer.Argument(None)):
    """Takes a stream from stdin where the first token is a datestamp and inserts the time delta
    between the previous timestamp and the current one.
    """

    if file:
        data = open(file)
    else:
        if stdin.isatty():
            print("ERROR: no data piped in and no file specified!", file=stderr)
            raise SystemExit(1)
        data = stdin

    old = None
    for line in data:
        line = line.strip("\n")
        datestamp = line.split()[0]
        new = pendulum.parse(datestamp)
        if not old:
            old = new
        delta = (new - old).in_words()
        print(f"{new.to_iso8601_string()}{separator}({delta}){separator}{line.removeprefix(datestamp)}")
        old = new


if __name__ == "__main__":
    typer.run(timestamp_lines)
