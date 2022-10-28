#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
"""Run 'helm history' and align each entry on UTC, and show how old it is."""

import json
import subprocess
import sys

import pendulum
from rich.console import Console
from rich.table import Table


def add_item_to_row(item):
    revision, updated, status, chart, app_version, description = (str(x) for x in item.values())
    updated = pendulum.parse(updated).in_tz("utc").strftime("%FT%T%z")
    age = (pendulum.now() - pendulum.parse(updated)).in_words()
    table.add_row(revision, updated, age, status, chart, app_version, description)


cmd = f'helm history {" ".join(sys.argv[1:])}'
ret = subprocess.run(cmd.split() + ["-o", "json"], capture_output=True)
if ret.returncode != 0:
    print(ret.stderr.decode())
    raise SystemExit(1)

try:
    data = json.loads(ret.stdout)
except json.decoder.JSONDecodeError:
    # This is only known to happen with 'helm-history.py --help'
    print(ret.stdout.decode())
    raise SystemExit(0)

table = Table(title=cmd, show_lines=True)
table.add_column("Revision")
table.add_column("Updated")
table.add_column("Age")
table.add_column("Status")
table.add_column("Chart")
table.add_column("App Version")
table.add_column("Description")

for item in data:
    add_item_to_row(item)

console = Console()
console.print(table)
