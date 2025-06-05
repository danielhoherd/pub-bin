#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">3.13"
# dependencies = [
#   "croniter",
# ]
# ///
# Author: github.com/danielhoherd (and Copilot GPT-4.1)
# License: MIT
"""Show scheduled cron job entries as wall clock times.

Usage: crontab -l | cron-to-wall-clock.py [--since ISO8601] [--job-run-count N]
"""

import argparse
import sys
from datetime import datetime

from croniter import croniter

if sys.stdin.isatty():
    print("ERROR: This script expects crontabs as an input, EG: 'crontab -l | cron-to-wall-clock.py'", file=sys.stderr)
    sys.exit(1)


def parse_args():
    parser = argparse.ArgumentParser(description="Show scheduled cron job run times as wall clock times.")
    parser.add_argument(
        "--since",
        help="Start time for calculations, in ISO8601 format (e.g., 2025-06-05T10:00:00 or 2025-06-05T10:00:00-04:00). Defaults to now.",
        default=None,
    )
    parser.add_argument(
        "--job-run-count", "-n", type=int, default=1, help="Number of upcoming runs to show per job entry (default: 1)."
    )
    return parser.parse_args()


def main():
    args = parse_args()
    # Python 3.13+: datetime.now().astimezone() is always timezone aware and local
    if args.since:
        try:
            start_time = datetime.fromisoformat(args.since)
            if start_time.tzinfo is None:
                # Assign system local timezone if not provided
                start_time = start_time.astimezone()
        except ValueError as e:
            print(f"Invalid --since value: {args.since} ({e})", file=sys.stderr)
            sys.exit(1)
    else:
        start_time = datetime.now().astimezone()

    runs = []
    for line in sys.stdin:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        parts = line.split()
        if len(parts) < 6:
            continue  # Skip incomplete lines
        cron_expr = " ".join(parts[:5])
        command = " ".join(parts[5:])
        try:
            it = croniter(cron_expr, start_time)
            for _ in range(args.job_run_count):
                next_run = it.get_next(datetime)
                # Should always be tz-aware because our start_time is
                runs.append((next_run, command))
        except croniter.croniter.CroniterBadCronError as e:
            print(f"Error parsing line: {line} ({e})", file=sys.stderr)

    # Sort by datetime
    for run_time, command in sorted(runs):
        print(f"{run_time.isoformat()} {command}")


if __name__ == "__main__":
    main()
