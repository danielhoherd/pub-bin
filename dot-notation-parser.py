#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
"""Take a dotted notation string and convert it to json, yaml, or python.

Huge caveat: the dotted notation string must only be a dict, with no lists or other types."""

import json
from enum import Enum

import typer
import yaml

app = typer.Typer(pretty_exceptions_enable=False)


class DestinationType(str, Enum):
    yaml = "yaml"
    python = "python"
    json = "json"


def convert_to_python(data: str):
    """Convert from a dotted notation string to json."""
    if "." in data:
        key, _, value = data.partition(".")
        return {key: convert_to_python(value)}
    if "=" in data:
        key, _, value = data.partition("=")
        return {key: value}
    return {data: None}


def convert_to_json(data: str):
    """Convert from a dotted notation string to json."""
    return json.dumps(convert_to_python(data))


def convert_to_yaml(data: str):
    """Convert from a dotted notation string to yaml."""
    return yaml.dump(convert_to_python(data), default_flow_style=False)


def main(dot_notation: str, format: DestinationType = "json"):
    """
    Convert from dot notation to various formats.
    """
    if format == "json":
        print(convert_to_json(dot_notation))
    elif format == "yaml":
        print(convert_to_yaml(dot_notation))
    elif format == "python":
        print(convert_to_python(dot_notation))


if __name__ == "__main__":
    main.__doc__ = __doc__
    try:
        typer.run(main)
    except OSError as e:
        raise SystemExit(e) from e
