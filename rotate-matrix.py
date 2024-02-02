#!/usr/bin/env python3
"""Takes a space delimited matrix on stdin and rotates or flips it."""

from sys import argv, stdin

import typer


def timestamp_lines(dir: str = typer.Option("left", help="Direction to rotate. Can be: left, right, diag")):
    """Rotate a matrix left or right."""

    if stdin.isatty():
        print(f"Description: {__doc__}")
        print(f"Usage: <some_command> | {argv[0]}")
        raise SystemExit(1)
    else:
        matrix = [line.split() for line in stdin]

        match dir:
            case "left":
                rotated = list(zip(*matrix))[::-1]
            case "right":
                rotated = list(zip(*matrix[::-1]))
            case "diag":
                rotated = list(zip(*matrix))
            case _:
                raise SystemExit("ERROR: --dir must be one of: left, right, diag")

        print("\n".join(" ".join(line) for line in rotated))


if __name__ == "__main__":
    typer.run(timestamp_lines)
