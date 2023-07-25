#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
from sys import argv, stdin

import pendulum
import typer


def timestamp_lines(separator: str = typer.Argument(" ")):
    """Takes a stream from stdin where the first token is a datestamp and inserts the time delta
    between the previous timestamp and the current one.
    """

    if stdin.isatty():
        print(f"Description: {__doc__}")
        print(f"Usage: <some_command> [separator] | {argv[0]}")
        raise SystemExit(1)
    else:
        old = None
        for line in stdin:
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
