#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
# TODO:
# - Handle end of line delimiters
# - Handle line breaks on input
# - Handle stdin

import sys
import textwrap

import typer

app = typer.Typer(help=__doc__)


def commentator(input: list[str], delimiter: str = "#", width: int = 75):
    """Generate a block of text inside of a border, for example to use as a template header."""
    wrapper = textwrap.TextWrapper(width=width)

    lines = wrapper.wrap(text=" ".join(input))

    print(delimiter * (width + 2))
    for line in lines:
        print(delimiter, line)
    print(delimiter * (width + 2))


if __name__ == "__main__":
    typer.run(commentator)
