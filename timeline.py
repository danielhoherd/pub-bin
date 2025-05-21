#!/usr/bin/env python3
# Author: github.com/danielhoherd (and gh copilot GPT-4.1)
# License: MIT
# Purpose: Show relative time for a list of events defined in a YAML file.

import sys
from textwrap import dedent

import pendulum
import yaml
from rich import print
from rich.console import Console
from rich.table import Table


def load_events(yaml_path):
    try:
        with open(yaml_path) as f:
            events = yaml.safe_load(f)
        if not isinstance(events, list):
            raise ValueError("YAML root should be a list of events.")
        return events
    except FileNotFoundError as e:
        print(f"[red]Error reading YAML file:[/red] {e}")
        sys.exit(1)


def normalize_events(events):
    normalized = []
    for event in events:
        date_val = event.get("date")
        match date_val:
            case pendulum.DateTime() | pendulum.Date():
                date_str = date_val.to_date_string()
            case _ if hasattr(date_val, "isoformat"):
                date_str = date_val.isoformat()
            case _:
                date_str = str(date_val)
        try:
            parsed_date = pendulum.parse(date_str)
        except pendulum.parsing.exceptions.ParserError:
            parsed_date = None
        normalized.append({"description": event.get("description"), "date": parsed_date})
    return normalized


def main(yaml_path):
    events = normalize_events(load_events(yaml_path))
    now = pendulum.now()

    table = Table(title="Events Relative Time")
    table.add_column("Description", style="cyan", no_wrap=True)
    table.add_column("Event Date", style="magenta")
    table.add_column("Relative Time", style="green")

    for event in events:
        desc = event.get("description", "<no description>")
        event_date = event.get("date")
        match event_date:
            case pendulum.DateTime():
                rel_time = event_date.diff_for_humans(now, absolute=False)
                date_display = event_date.to_date_string()
            case None:
                rel_time = "[red]Invalid date[/red]"
                date_display = "[red]Invalid date[/red]"
            case _:
                rel_time = f"[red]Unrecognized date type: {event_date}[/red]"
                date_display = str(event_date)
        table.add_row(desc, date_display, rel_time)

    console = Console()
    console.print(table)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(
            dedent("""
            [yellow]Usage: python events_relative_time.py <events.yaml>[/yellow]

            Example YAML file:

            - description: "Claude Debussy born"
              date: 1862-08-22
            - description: "Debussy publishes Rêverie"
              date: 1891-01-01
            - description: "Debussy publishes Deux Arabesques"
              date: 1891-01-01
            - description: "Debussy publishes Suite bergamasque"
              date: 1905-04-01
            - description: "Claude Debussy dies"
              date: 1918-03-25""")
        )
        sys.exit(1)
    main(sys.argv[1])
