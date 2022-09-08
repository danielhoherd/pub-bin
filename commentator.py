#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
# TODO:
# - Handle line breaks on input (seems hard if we use textwrap)
# - Handle stdin (typer doesn't handle defaults for nargs)

import sys
import textwrap

import typer

app = typer.Typer(help=__doc__)


def commentator(
    input: list[str] = typer.Argument(..., help="Input text"),
    right_side: bool = typer.Option(False, help="Whether or not to show the right-hand-side border"),
    delimiter: str = typer.Option("#", "--delimiter", "-d", help="Character or string to use for border"),
    width: int = typer.Option(75, "--width", "-w", help="Width of the final padded line"),
):
    """Generate a block of text inside of a border, for example to use as a template header."""

    if width < len(delimiter) * 4:  # just a rough minimum because this is an edge case
        raise SystemExit("ERROR: delimiter is too wide relative to width")

    print((delimiter * width)[:width])

    if right_side:
        text_width = width - (len(delimiter) * 2) - 2
        wrapper = textwrap.TextWrapper(width=text_width)
        lines = wrapper.wrap(text=" ".join(input))

        for line in lines:
            print(delimiter, f"{line:{text_width}}", delimiter)
    else:
        text_width = width - len(delimiter) - 1
        wrapper = textwrap.TextWrapper(width=text_width)
        lines = wrapper.wrap(text=" ".join(input))

        for line in lines:
            print(delimiter, line)

    print((delimiter * width)[:width])


if __name__ == "__main__":
    typer.run(commentator)
