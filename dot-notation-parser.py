#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
"""Take a dotted notation string and convert it to json, yaml, or python.

Huge caveat: the dotted notation string must only be a dict, with no lists or other types."""

import json
from enum import Enum
from typing import Annotated

import typer
import yaml

app = typer.Typer(pretty_exceptions_enable=False)


class DestinationType(str, Enum):
    yaml = "yaml"
    python = "python"
    json = "json"


def convert_to_python(data: str, default_value: str | bool | None = None):
    """Convert from a dotted notation string to json."""
    data = data.removeprefix(".").removesuffix(".")
    if "." in data:
        key, _, value = data.partition(".")
        return {key: convert_to_python(value, default_value)}
    if "=" in data:
        key, _, value = data.partition("=")
        return {key: value}
    return {data: default_value}


def convert_to_json(data: str, default_value: str | bool | None = None):
    """Convert from a dotted notation string to json."""
    return json.dumps(convert_to_python(data, default_value))


def convert_to_yaml(data: str, default_value: str | bool | None = None):
    """Convert from a dotted notation string to yaml."""
    return yaml.dump(convert_to_python(data, default_value), default_flow_style=False)


def main(
    dotted_str: Annotated[str, typer.Argument()],
    default_value: Annotated[str | None, typer.Argument()] = "None",
    format: DestinationType = "json",
):
    """
    Convert from dot notation to various formats.
    """
    match format:
        case "yaml":
            typer.echo(convert_to_yaml(dotted_str, default_value))
        case "json":
            typer.echo(convert_to_json(dotted_str, default_value))
        case "python":
            typer.echo(convert_to_python(dotted_str, default_value))
        case _:
            typer.echo("Invalid format", err=True)
            raise typer.Exit(1)


if __name__ == "__main__":
    main.__doc__ = __doc__
    try:
        typer.run(main)
    except OSError as e:
        raise SystemExit(e) from e
