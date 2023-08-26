#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
# Purpose: Show the difference between two dates in several human readable forms.


import pendulum
import typer
from rich import print


def validate_date(value: str):
    try:
        parsed_date = pendulum.parse(value)
    except (TypeError, pendulum.parsing.exceptions.ParserError):
        raise typer.BadParameter("Unable to parse the input dates. Please use YYYY-MM-DD or similar iso8601-ish strings.")

    return parsed_date


def date_diff(
    start: str = typer.Argument(None, callback=validate_date),
    end: str = typer.Argument(default=pendulum.now().to_iso8601_string(), callback=validate_date),
):
    """Show the difference between two iso8601 timestamps. If only one is given, the current time is used for the other."""

    delta = end - start
    future_past = "in the past" if delta.total_seconds() > 0 else "in the future"
    if delta.total_seconds() < 0:
        delta = start - end
    print(f"Total seconds: {int(delta.total_seconds()):,d}")
    print(f"Total minutes: {int(delta.total_minutes()):,d}")
    print(f"Total hours: {int(delta.total_hours()):,d}")
    print(f"Total days: {int(delta.total_days()):,d}")
    print(f"{delta.in_words()} {future_past}")


if __name__ == "__main__":
    typer.run(date_diff)
