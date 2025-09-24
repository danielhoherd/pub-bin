#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
"""Check a hostname against a list of known public DNS resolvers and return a single-character result status.

See also: https://www.whatsmydns.net"""

import asyncio
import datetime

import dns.asyncresolver
import typer

app = typer.Typer(pretty_exceptions_enable=False, help=__doc__)

local_timezone = datetime.datetime.now(datetime.UTC).astimezone().tzinfo

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
):
    asyncio.run(async_main(hosts, verbose))


async def async_main(hosts, verbose):
    now = datetime.datetime.now(local_timezone).strftime("%FT%T%z")
    host_column_length = max(len(host) for host in hosts)
    for host in hosts:
        failures = []
        results = await asyncio.gather(*(async_lookup_host_in_nameserver(host, ns) for ns in nameservers))
        print(f"{now} {host:>{host_column_length}}", end=" ")
        for result in results:
            print(result[1], end="")
        for result, nameserver in zip(results, nameservers):
            if result[1] in ["x", "?"]:
                failures.append(result)
        if verbose:
            for failure in failures:
                print(f"\n  Failure: {host} {failure[1]} {failure[0]:<15}", end="")
        print()


if __name__ == "__main__":
    main.__doc__ = __doc__
    app()
