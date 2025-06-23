#!/usr/bin/env python3
# Author: github.com/danielhoherd (and copilot GPT-4o)
# License: MIT
"""Track report on time spent in zoom meetings.

To enable tracking, create a crontab that runs this script with no args every minute.
"""

import argparse
import contextlib
import os
import sqlite3
import subprocess
from datetime import UTC, datetime, timedelta

# Define the database path
DB_PATH = os.path.expanduser("~/.local/share/zoom_tracker/zoom_tracker.db")


def initialize_database():
    """Initialize the SQLite3 database and create the table and view."""
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()
        # Create the table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS zoom_logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TEXT NOT NULL,
                result INTEGER NOT NULL
            )
        """)
        conn.commit()

        # Create the view for unique active Zoom minutes
        cursor.execute("""
            CREATE VIEW IF NOT EXISTS zoom_active_minutes AS
            SELECT DISTINCT strftime('%Y-%m-%dT%H:%M', timestamp) AS active_minute
            FROM zoom_logs
            WHERE result = 1
        """)
        conn.commit()


def check_for_zoom_meeting():
    """Check if a zoom meeting is in progress.

    The current implementation Uses lsof to find UDP connections related to zoom.us.
    """
    with contextlib.suppress(subprocess.CalledProcessError):
        cmd = ["lsof", "-i", "4UDP"]
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True, check=True)
        for line in result.stdout.splitlines():
            if "zoom.us:" in line:
                return 1  # Found a connection
    return 0  # No connection found


def log_to_database(result):
    """Log the current datetime and result to the database."""
    timestamp = datetime.now(UTC).isoformat()
    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()
        cursor.execute(
            """
            INSERT INTO zoom_logs (timestamp, result)
            VALUES (?, ?)
        """,
            (timestamp, result),
        )
        conn.commit()


def calculate_zoom_time(period):
    """
    Calculate the total time spent on Zoom in the given period.

    Args:
        period (str): The period to check (day, week, month).

    Returns:
        tuple: Total hours and minutes spent on Zoom.
    """
    now = datetime.now(UTC)
    match period:
        case "hour":
            start_time = now - timedelta(hours=1)
        case "day":
            start_time = now - timedelta(days=1)
        case "week":
            start_time = now - timedelta(weeks=1)
        case "month":
            start_time = now - timedelta(days=30)
        case _:
            raise ValueError("Invalid period. Use 'day', 'week', or 'month'.")

    with sqlite3.connect(DB_PATH) as conn:
        cursor = conn.cursor()
        # Use the view to count active minutes
        cursor.execute(
            """
            SELECT COUNT(*)
            FROM zoom_active_minutes
            WHERE active_minute >= ?
            """,
            (start_time.strftime("%Y-%m-%dT%H:%M"),),
        )
        total_minutes = cursor.fetchone()[0]

    # Use divmod to calculate hours and minutes
    hours, minutes = divmod(total_minutes, 60)
    return hours, minutes


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Track and report Zoom usage.")
    parser.add_argument("--report", choices=["hour", "day", "week", "month"], help="Report Zoom usage for the specified period.")
    args = parser.parse_args()

    initialize_database()

    if args.report:
        hours, minutes = calculate_zoom_time(args.report)
        match hours:
            case 0:
                print(f"Total time spent on Zoom in the last {args.report}: {minutes} minutes")
            case 1:
                print(f"Total time spent on Zoom in the last {args.report}: {hours} hour and {minutes} minutes")
            case _:
                print(f"Total time spent on Zoom in the last {args.report}: {hours} hours and {minutes} minutes")

    else:
        result = check_for_zoom_meeting()
        log_to_database(result)
