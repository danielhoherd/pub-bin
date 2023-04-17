#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
"""Check a hostname against a list of known public DNS resolvers and return a single-character result status."""

import dns.resolver
import typer
import datetime

app = typer.Typer(pretty_exceptions_enable=False)

local_timezone = datetime.datetime.now(datetime.timezone.utc).astimezone().tzinfo

nameservers = [
    "1.1.1.1",
    "4.2.2.1",
    "4.2.2.2",
    "4.2.2.3",
    "4.2.2.4",
    "4.2.2.5",
    "4.2.2.6",
    "8.8.4.4",
    "8.8.8.8",
    "9.9.9.9",
    "149.112.112.112",
    "156.154.70.1",
    "156.154.71.1",
    "198.6.1.4",
    "208.67.220.220",
    "208.67.222.222",
]


def lookup_host_in_nameserver(host, nameserver):
    resolver = dns.resolver.Resolver()
    resolver.nameservers = [nameserver]
    try:
        resolver.resolve(host, lifetime=2.0)
        return "•"
    except dns.resolver.NXDOMAIN:
        return "x"
    except dns.resolver.LifetimeTimeout:
        return "?"


@app.command()
def main(hosts: list[str] = typer.Argument(..., help="Host to check")):
    now = datetime.datetime.now(local_timezone).strftime("%FT%T%z")
    host_column_length = max(len(host) for host in hosts)
    for host in hosts:
        print(f"{now} {host:>{host_column_length}}", end=" ")
        for nameserver in nameservers:
            print(lookup_host_in_nameserver(host, nameserver), end="", flush=True)
        print("")


if __name__ == "__main__":
    app()
