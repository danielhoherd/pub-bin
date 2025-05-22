#!/usr/bin/env python3
# Author: github.com/danielhoherd (and GH Copilot GPT-4.1)
# License: MIT
# Original inspiration: https://slack.engineering/a-faster-smarter-quick-switcher
"""Show frecency scores for git files and authors."""

import argparse
import signal
import subprocess
from collections import defaultdict
from datetime import datetime, timedelta
from pathlib import Path

signal.signal(signal.SIGPIPE, signal.SIG_DFL)


def run_git_log(path):
    cmd = ["git", "log", "--pretty=format:%at|%an <%ae>", "--name-only", "--", path]
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    out, err = p.communicate()
    if p.returncode != 0:
        raise RuntimeError(f"git log failed: {err.strip()}")
    return out


def parse_log_files(log):
    # Returns {file: [timestamps]}
    files = defaultdict(list)
    lines = log.strip().split("\n")
    current_time = None
    for line in lines:
        if "|" in line:  # Timestamp and author
            ts, _ = line.split("|", 1)
            current_time = int(ts)
        elif line.strip():
            files[line.strip()].append(current_time)
    return files


def parse_log_authors(log):
    # Returns {author: [timestamps]}
    authors = defaultdict(list)
    lines = log.strip().split("\n")
    current_time = None
    current_author = None
    for line in lines:
        if "|" in line:
            ts, author = line.split("|", 1)
            current_time = int(ts)
            current_author = author.strip()
        elif line.strip():
            authors[current_author].append(current_time)
    return authors


def recency_weight(ts):
    """Assigns a weight based on how recent the timestamp is."""
    dt = datetime.fromtimestamp(ts)
    now_dt = datetime.now()
    delta = now_dt - dt

    match True:
        case _ if delta <= timedelta(hours=4):
            return 10
        case _ if delta <= timedelta(hours=24):
            return 8
        case _ if delta <= timedelta(hours=72):  # 3 days
            return 6
        case _ if delta <= timedelta(hours=168):  # 7 days
            return 4
        case _ if dt > now_dt - timedelta(days=90):
            return 1
        case _:
            return 0


def compute_frecency(timestamps):
    """Sum the decay weights for all timestamps."""
    if not timestamps:
        return 0
    return sum(recency_weight(ts) for ts in timestamps)


def show_files(path, include_zero=False):
    log = run_git_log(path)
    files = parse_log_files(log)
    files = {k: v for k, v in files.items() if Path(k).exists()}
    frecencys = [(f, compute_frecency(ts)) for f, ts in files.items()]
    for f, score in sorted(frecencys, key=lambda x: -x[1]):
        if include_zero or score > 0:
            print(f"{score}\t{f}")


def show_authors(path, include_zero=False):
    log = run_git_log(path)
    authors = parse_log_authors(log)
    frecencys = [(a, compute_frecency(ts)) for a, ts in authors.items()]
    # Prepare table header
    print(f"{'Score':>10}  {'Author':<25}  E-mail")
    print("-" * 55)
    for a, score in sorted(frecencys, key=lambda x: -x[1]):
        if include_zero or score > 0:
            # Split "Name <email>"
            if "<" in a and ">" in a:
                name, email = a.split("<", 1)
                email = email.strip(">")
                name = name.strip()
            else:
                name = a
                email = ""
            score_str = f"{score:g}"
            print(f"{score_str:>10}  {name:<25}  {email}")


def main():
    parser = argparse.ArgumentParser(description="Git frecency tool")
    parser.add_argument("--include-zero", action="store_true", help="Include files/authors with zero frecency score")
    subparsers = parser.add_subparsers(dest="command")

    files_parser = subparsers.add_parser("files", help="Show frecency-sorted files")
    files_parser.add_argument("path", help="Directory or file to analyze")

    authors_parser = subparsers.add_parser("authors", help="Show frecency-sorted authors")
    authors_parser.add_argument("path", help="Directory or file to analyze")

    args = parser.parse_args()
    if args.command == "files":
        show_files(args.path, include_zero=args.include_zero)
    elif args.command == "authors":
        show_authors(args.path, include_zero=args.include_zero)
    else:
        parser.print_help()


if __name__ == "__main__":
    try:
        main()
    except (KeyboardInterrupt, BrokenPipeError):
        pass
