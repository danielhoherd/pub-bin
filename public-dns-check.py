#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
"""Check a hostname against a list of known public DNS resolvers and return a single-character result status.

See also: https://www.whatsmydns.net"""

import dns.resolver
import typer
import datetime

app = typer.Typer(pretty_exceptions_enable=False, help=__doc__)

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
    except (dns.resolver.NXDOMAIN, dns.resolver.NoAnswer):
        return "x"
    except dns.resolver.LifetimeTimeout:
        return "?"


@app.command()
def main(
    hosts: list[str] = typer.Argument(..., help="Host to check"),
    verbose: bool = typer.Option(False, "--verbose", "-v", help="Verbose mode"),
):
    now = datetime.datetime.now(local_timezone).strftime("%FT%T%z")
    host_column_length = max(len(host) for host in hosts)
    for host in hosts:
        print(f"{now} {host:>{host_column_length}}", end=" ")
        failures = []
        for nameserver in nameservers:
            res = lookup_host_in_nameserver(host, nameserver)
            if res == "x":
                failures.append(nameserver)
            print(lookup_host_in_nameserver(host, nameserver), end="", flush=True)
        if verbose:
            for failure in failures:
                print(f"\n  {host} failed on {failure}", end="")

        print("")


if __name__ == "__main__":
    main.__doc__ = __doc__
    app()
