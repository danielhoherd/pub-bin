#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
"""Run 'helm history', then align each entry on the same timezone and show how
old it is."""

import json
import os
import subprocess
import sys

import pendulum
from tabulate import tabulate

try:
    if TZ := os.getenv("TZ"):
        tz = pendulum.timezone(TZ)
    else:
        tz = pendulum.now().tz
except pendulum.tz.zoneinfo.exceptions.InvalidTimezone:
    print(
        f"ERROR: {TZ=} is an invalid timezone. Try using one from the TZ database column here https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List"
    )
    raise SystemExit(1)


def format_deployment(item):
    """Reformat the deployment with an age field and a corrected timestamp field."""
    revision, updated, status, chart, app_version, description = (str(x) for x in item.values())
    updated = pendulum.parse(updated).replace(microsecond=0)
    age = (pendulum.now().replace(microsecond=0) - updated).in_words()
    return [revision, updated.strftime("%FT%H:%M:%S%z"), age, status, chart, app_version, description]


def print_as_table(data):
    """Print the data as a table."""
    headers = ["Revision", "Updated", "Age", "Status", "Chart", "App Version", "Description"]
    table = sorted([format_deployment(item) for item in data], key=lambda x: int(x[0]))
    print(tabulate(table, headers=headers))


cmd = f"helm history {' '.join(sys.argv[1:])}"
ret = subprocess.run([*cmd.split(), "-o", "json"], capture_output=True, check=False)
if ret.returncode != 0:
    print(ret.stderr.decode())
    raise SystemExit(1)

try:
    data = json.loads(ret.stdout)
except json.decoder.JSONDecodeError as e:
    # This is only known to happen with 'helm-history.py --help'
    print(ret.stdout.decode())
    raise SystemExit(0) from e

print_as_table(data)
