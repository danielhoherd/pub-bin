#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
"""Sleep until the next interval or until the given date."""

# TODO:
# - Support an interval offset (eg: every 3 hours but offset by 30 minutes)
# - Support conversational input (eg: date '5 minutes 30 seconds')

import os
import sys
from datetime import datetime
from time import sleep

import pendulum
import typer
from pendulum.parsing.exceptions import ParserError
from rich.progress import (
    track,  # https://typer.tiangolo.com/tutorial/progressbar/#progress-bar
)

app = typer.Typer(help=__doc__)


def parser_error_exit():
    print("ERROR: invalid date given. Please use ISO8601 or RFC3339 compatible strings. https://pendulum.eustace.io/docs/#parsing")
    raise SystemExit(1)


try:
    tz = pendulum.timezone(TZ) if (TZ := os.getenv("TZ")) else pendulum.now().tz
except pendulum.tz.zoneinfo.exceptions.InvalidTimezone as e:
    print(
        f"ERROR: {TZ=} is an invalid timezone. Try using one from the TZ database column here https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List"
    )
    raise SystemExit(1) from e


@app.command()
def interval(interval: int, verbose: bool = typer.Option(False, "-v", "--verbose")):
    """Sleep until the next interval."""
    try:
        now = pendulum.now()
        sleep_time = interval - float(now.strftime("%s.%f")) % interval
        delta = pendulum.now().add(seconds=sleep_time) - pendulum.now()
        if verbose:
            print(f'{now.strftime("%FT%T.%f")} sleep for {sleep_time} seconds ({delta.in_words()})', file=sys.stderr)
        sleep(sleep_time)
    except KeyboardInterrupt as e:
        print("")
        raise SystemExit(1) from e


@app.command()
def date(date: str, verbose: bool = typer.Option(False, "-v", "--verbose")):
    """Sleep until the given date."""
    now = datetime.now()
    try:
        future_date = pendulum.parse(date, tz=tz)
    except ParserError:
        parser_error_exit()
    delta = future_date - pendulum.now()
    if delta.invert:
        print(f"ERROR: date {date} has already passed!")
        raise SystemExit(2)
    sleep_time = float(f"{delta.seconds}.{delta.microseconds}")
    if verbose:
        print(f'{now.strftime("%FT%T.%f")} sleep for {sleep_time} seconds ({delta.in_words()})', file=sys.stderr)
    sleep(sleep_time)


if __name__ == "__main__":
    app()
