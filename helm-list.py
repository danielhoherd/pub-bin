#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
"""Output `helm list` with iso-8601 timestamp formatting. The output is sorted by the last deploy datetime."""


import json
import os
import subprocess
import sys

import pendulum
from tabulate import tabulate

if len(sys.argv) < 2:
    print(subprocess.check_output("helm list --help".split()).decode())
    raise SystemExit(0)

try:
    tz = pendulum.timezone(TZ) if (TZ := os.getenv("TZ")) else pendulum.now().tz
except pendulum.tz.zoneinfo.exceptions.InvalidTimezone:
    print(
        f"ERROR: {TZ=} is an invalid timezone. Try using one from the TZ database column here https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List"
    )
    raise SystemExit(1)


def format_deployment(item):
    """Reformat the deployment with an age field and a corrected timestamp field."""
    name, namespace, revision, updated, status, chart, app_version = (str(x) for x in item.values())
    updated = pendulum.from_format(updated.rsplit(".")[0] + updated.split()[-2], "YYYY-MM-DD HH:mm:ssZZ").strftime("%FT%H:%M%z")
    age = (pendulum.now().replace(second=0) - pendulum.parse(updated)).in_words()
    return [namespace, name, revision, updated, age, status, chart, app_version]


def print_as_table(data):
    """Print the data as a table."""
    headers = ["namespace", "name", "revision", "updated", "age", "status", "chart", "app_version"]
    table = sorted([format_deployment(item) for item in data], key=lambda x: x[3])
    print(tabulate(table, headers=headers))


def main():
    cmd = f'helm list {" ".join(sys.argv[1:])} -o json'
    ret = subprocess.run(cmd.split(), capture_output=True)
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


if __name__ == "__main__":
    main()
