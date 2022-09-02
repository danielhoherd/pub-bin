#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
# TODO:
# - Handle line breaks on input
# - Handle stdin

import sys
import textwrap

import typer

app = typer.Typer(help=__doc__)


def commentator(input: list[str], right_side: bool = False, delimiter: str = "#", width: int = 75):
    """Generate a block of text inside of a border, for example to use as a template header."""

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
