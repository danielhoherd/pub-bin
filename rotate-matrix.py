#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
"""Take a space delimited matrix on stdin and rotate or flip it diagonally."""

from enum import Enum
from sys import argv, stdin

import typer


class Direction(str, Enum):
    left = "left"
    right = "right"
    diag = "diag"


def rotate_matrix(direction: Direction = typer.Option(Direction.left, "--direction", "-d", help="Direction to rotate.")):
    """Rotate a matrix left or right."""

    if stdin.isatty():
        print(f"Description: {__doc__}")
        print(f"Usage: <some_command> | {argv[0]}")
        raise SystemExit(1)
    else:
        matrix = [line.split() for line in stdin]

        match direction:
            case "left":
                rotated = list(zip(*matrix))[::-1]
            case "right":
                rotated = list(zip(*matrix[::-1]))
            case "diag":
                rotated = list(zip(*matrix))
            case _:
                raise SystemExit(1)

        print("\n".join(" ".join(line) for line in rotated))


if __name__ == "__main__":
    typer.run(rotate_matrix)
