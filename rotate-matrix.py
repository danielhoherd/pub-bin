#!/usr/bin/env python3
"""Takes a space delimited matrix on stdin and rotates or flips it."""

from pprint import pprint as pp
from sys import argv, stdin

import typer

app = typer.Typer()


def timestamp_lines(dir: str = typer.Option("left", help="Direction to rotate. Can be: left, right, diag")):
    """
    Rotate a matrix left or right.
    """

    if stdin.isatty():
        print(f"Description: {__doc__}")
        print(f"Usage: <some_command> | {argv[0]}")
        raise SystemExit(1)
    else:
        matrix = [line.split() for line in stdin]

        if dir == "left":
            rotated = list(zip(*matrix))[::-1]
        elif dir == "right":
            rotated = list(zip(*matrix[::-1]))
        elif dir == "diag":
            rotated = list(zip(*matrix))
        else:
            raise SystemExit("ERROR: --dir must be one of: left, right, diag")

        for line in rotated:
            print(" ".join(line))


if __name__ == "__main__":
    typer.run(timestamp_lines)
