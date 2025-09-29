#!/usr/bin/env python3
# Author: github.com/danielhoherd, copilot GPT-4.1
# License: MIT
"""Check a hostname against a list of DNS resolvers and return a single-character result status.

See also: https://www.whatsmydns.net"""

import asyncio
import datetime

import dns.asyncresolver
import typer

app = typer.Typer(pretty_exceptions_enable=False, help=__doc__)

local_timezone = datetime.datetime.now(datetime.UTC).astimezone().tzinfo

DEFAULT_NAMESERVERS = [
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


def parse_nameservers(value: str) -> list[str]:
    """Transform a comma-separated string into a list of nameservers, dropping empty values."""
    if not value:
        return DEFAULT_NAMESERVERS
    return [ns.strip() for ns in value.split(",") if ns.strip()]


async def async_lookup_host_in_nameserver(host, nameserver):
    resolver = dns.asyncresolver.Resolver()
    resolver.nameservers = [nameserver]
    try:
        await resolver.resolve(host, lifetime=2.0)
        return [nameserver, "•"]
    except (dns.resolver.NXDOMAIN, dns.resolver.NoAnswer):
        return [nameserver, "x"]
    except dns.resolver.LifetimeTimeout:
        return [nameserver, "?"]


@app.command()
def main(
    hosts: list[str] = typer.Argument(..., help="Host to check"),
    verbose: bool = typer.Option(False, "--verbose", "-v", help="Verbose mode"),
    servers: str = typer.Option(
        "",
        "--servers",
        "-s",
        help="Comma-separated list of DNS servers (default: well-known public resolvers)",
        callback=parse_nameservers,
    ),
):
    asyncio.run(async_main(hosts, verbose, servers))


async def async_main(hosts, verbose, servers):
    now = datetime.datetime.now(local_timezone).strftime("%FT%T%z")
    host_column_length = max(len(host) for host in hosts)
    for host in hosts:
        results = await asyncio.gather(*(async_lookup_host_in_nameserver(host, ns) for ns in servers))
        print(f"{now} {host:>{host_column_length}}", end=" ")
        for result in results:
            print(result[1], end="")
        failures = [result for result, server in zip(results, servers) if result[1] in ["x", "?"]]
        if verbose:
            for failure in failures:
                print(f"\n  Failure: {host} {failure[1]} {failure[0]:<15}", end="")
        print()


if __name__ == "__main__":
    main.__doc__ = __doc__
    app()
