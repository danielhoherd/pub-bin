#!/usr/bin/env python3
# Author: github.com/danielhoherd and GH copilot GPT-4.1
# License: MIT
"""Merge several yaml files into one. Later files take precedence over earlier ones."""

import sys

import yaml


def deep_merge(a, b):
    """Recursively merges dict b into dict a and returns the result."""
    if not isinstance(a, dict) or not isinstance(b, dict):
        return b
    merged = dict(a)
    for k, v in b.items():
        merged[k] = deep_merge(merged[k], v) if k in merged else v
    return merged


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} file1.yaml [file2.yaml ...]", file=sys.stderr)
        raise SystemExit(1)

    merged = {}
    for path in sys.argv[1:]:
        with open(path) as f:
            data = yaml.safe_load(f) or {}
            merged = deep_merge(merged, data)

    yaml.safe_dump(merged, sys.stdout, sort_keys=False)


if __name__ == "__main__":
    main()
