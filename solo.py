#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
"""Ensure only one instance of a command is running at a time by opening up a port
on localhost for the duration of the running command.

This is essentially a port of the solo.pl script by Timothy Kay."""

import typer
import socket
import subprocess
from typing import List, Optional

app = typer.Typer(help=__doc__)


def main(command: Optional[List[str]] = typer.Argument(None), port: int = 13579):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind(("127.0.0.1", port))
    subprocess.call(command)


if __name__ == "__main__":
    try:
        typer.run(main)
    except OSError as e:
        raise SystemExit(e) from e
