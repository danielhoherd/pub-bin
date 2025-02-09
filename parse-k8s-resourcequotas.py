#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">3.11"
# dependencies = [
#   "kubernetes",
#   "humanize",
#   "rich",
#   "typer",
# ]
# ///
# Author: github.com/danielhoherd
# License: MIT
"""Show a table of useful data from a kubernetes resourcequota json."""

import json
from operator import itemgetter
from pathlib import Path
from sys import stdin

import typer
from humanize import naturalsize
from kubernetes.utils.quantity import parse_quantity as pq
from rich import box
from rich.console import Console
from rich.table import Table


def parse_quota(item):
    status = item["status"]
    memory_utilization = pq(status["used"]["limits.memory"]) / pq(status["hard"]["limits.memory"])
    cpu_utilization = pq(status["used"]["limits.cpu"]) / pq(status["hard"]["limits.cpu"])
    return {
        "namespace": item["metadata"]["namespace"],
        "cpu_used": pq(status["used"]["limits.cpu"]),
        "cpu_limit": pq(status["hard"]["limits.cpu"]),
        "cpu_utilization": cpu_utilization,
        "cpu_free": pq(status["hard"]["limits.cpu"]) - pq(status["used"]["limits.cpu"]),
        "memory_used": pq(status["used"]["limits.memory"]),
        "memory_limit": pq(status["hard"]["limits.memory"]),
        "memory_utilization": memory_utilization,
        "memory_free": pq(status["hard"]["limits.memory"]) - pq(status["used"]["limits.memory"]),
    }


def main(
    file: str, sort_by: str = "namespace", reverse: bool = typer.Option(False, "--reverse", "-r", help="Reverse the sort order")
):
    """Show a table of useful data from a kubernetes resourcequota json.

    Example

        kubectl get resourcequota -A -l platform=astronomer -o json > quotas.json

        ./parse-k8s-resourcequotas.py quotas.json
    """
    if file == "stdin":
        quotas = json.load(stdin)
    else:
        quotas = json.loads(Path(file).read_text())

    output_data = [parse_quota(item) for item in quotas["items"]]

    console = Console()
    table = Table(title="quota data", show_lines=False, style="grey19", box=box.MINIMAL)
    table.add_column("namespace")
    table.add_column("cpu_used", justify="right")
    table.add_column("cpu_limit", justify="right")
    table.add_column("cpu_utilization", justify="right")
    table.add_column("cpu_free", justify="right")
    table.add_column("memory_used", justify="right")
    table.add_column("memory_limit", justify="right")
    table.add_column("memory_utilization", justify="right")
    table.add_column("memory_free", justify="right")

    if reverse:
        output_data = sorted(output_data, key=itemgetter(sort_by))[::-1]
    else:
        output_data = sorted(output_data, key=itemgetter(sort_by))

    for row in output_data:
        table.add_row(
            row["namespace"],
            f"{row['cpu_used']:.2f}",
            f"{row['cpu_limit']:.2f}",
            f"{row['cpu_utilization'] * 100:.1f}%",
            f"{row['cpu_free']:.2f}",
            naturalsize(row["memory_used"]),
            naturalsize(row["memory_limit"]),
            f"{row['memory_utilization'] * 100:.1f} %",
            naturalsize(row["memory_free"]),
        )

    console.print(table)


if __name__ == "__main__":
    typer.run(main)
