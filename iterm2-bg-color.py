#!/usr/bin/env python3
# Author: github.com/danielhoherd (and gh copilot GPT-4.1)
# License: MIT
"""Change the background color of an iTerm2 terminal window."""

import argparse
import random
import re
import sys


def hex_to_rgb(hex_color):
    """Convert hex color string to R/G/B as two-digit hex strings."""
    hex_color = hex_color.lstrip("#")
    if len(hex_color) != 6 or not re.match(r"^[0-9a-fA-F]{6}$", hex_color):
        raise ValueError("Please provide a valid 6-digit hex color code, e.g., #1e1e1e")
    return [hex_color[i : i + 2] for i in (0, 2, 4)]


def set_iterm2_bg(hex_color):
    r, g, b = hex_to_rgb(hex_color)
    # Print the escape code for iTerm2 to set the background color
    print(f"\033]11;rgb:{r}/{g}/{b}\a", end="")


def random_color(low=8, high=24):
    """Generate a random hex color where each component is in [low, high]."""
    return "#{:02x}{:02x}{:02x}".format(*(random.randint(low, high) for _ in range(3)))


def main():
    parser = argparse.ArgumentParser(description="iTerm2 CLI utilities")
    parser.add_argument("color", nargs="?", help="Background color in hex format, e.g. #1e1e1e")
    parser.add_argument("--random", action="store_true", help="Set a random background color")
    parser.add_argument("--low", type=int, default=8, help="Lower bound (inclusive) for random RGB components (0-255, default: 8)")
    parser.add_argument(
        "--high", type=int, default=24, help="Upper bound (inclusive) for random RGB components (0-255, default: 24)"
    )

    args = parser.parse_args()

    # Validate --low and --high
    if args.random:
        if not (0 <= args.low <= 255):
            parser.error("--low must be between 0 and 255")
        if not (0 <= args.high <= 255):
            parser.error("--high must be between 0 and 255")
        if args.low > args.high:
            parser.error("--low cannot be greater than --high")
        color = random_color(args.low, args.high)
    elif args.color:
        color = args.color
    else:
        parser.error("You must specify a color or use --random")

    try:
        set_iterm2_bg(color)
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
