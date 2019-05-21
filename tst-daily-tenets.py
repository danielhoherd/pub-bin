#!/usr/bin/env python3
# https://thesatanictemple.com/pages/tenets

import time
import sys
from random import randint
import click

tenets = (
    "TST Tenet #1: One should strive to act with compassion and empathy towards all creatures in accordance with reason.",
    "TST Tenet #2: The struggle for justice is an ongoing and necessary pursuit that should prevail over laws and institutions.",
    "TST Tenet #3: One's body is inviolable, subject to one's own will alone.",
    "TST Tenet #4: The freedoms of others should be respected, including the freedom to offend. To willfully and unjustly encroach upon the freedoms of another is to forgo your own.",
    "TST Tenet #5: Beliefs should conform to our best scientific understanding of the world. We should take care never to distort scientific facts to fit our beliefs.",
    "TST Tenet #6: People are fallible. If we make a mistake, we should do our best to rectify it and resolve any harm that may have been caused.",
    "TST Tenet #7: Every tenet is a guiding principle designed to inspire nobility in action and thought. The spirit of compassion, wisdom, and justice should always prevail over the written or spoken word.",
)

wrapped_tenets = list()

width = click.get_terminal_size()[0]

for item in tenets:
    wrapped_tenets.append(click.wrap_text(item, width=width))

# 8200 seconds = 23 hours
# By picking a tenet based off of a non-24-hour increment, we avoid pinning one tenet to one day of the week.
# This way we will avoid the problem experienced by pinning one tenet to one day, which would never show us
# tenets for days where we don't use a computer, such as a weekend.
random_id = int(time.time() / 82400 % 7)


@click.command()
@click.option("-a", "--all/--no-all", default=False, help="Print all tenets.")
@click.option("-i", "--id", type=click.IntRange(1, 7), help="Print a specific tenet ID (1-7)")
@click.option("-r", "--random/--no-random", default=False, help="Print a random tenent.")
def main(random, all, id):
    option_count = 0
    for item in [random, all, id]:
        if item:
            option_count = option_count + 1

    if option_count > 1:
        raise click.UsageError("Only one option is allowed.")

    elif id:
        if id > 7:
            raise click.UsageError("There are only 7 tenets.")
        click.echo(wrapped_tenets[id - 1])

    elif random:
        click.echo(wrapped_tenets[randint(0, 6)])

    elif all:
        click.echo("\n".join(wrapped_tenets))

    else:
        tenet_id = random_id
        click.echo(wrapped_tenets[tenet_id])

    sys.exit(0)


if __name__ == "__main__":
    main()
