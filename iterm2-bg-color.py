#!/usr/bin/env python3
# Author: github.com/danielhoherd (and gh copilot GPT-4.1)
# License: MIT
"""Change the background color of an iTerm2 terminal window."""

import argparse
import colorsys
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
    print(f"\033]11;rgb:{r}/{g}/{b}\a", end="")


def random_vibrant_color(low, high):
    """Generate a random vibrant hex color, with lightness in [low, high]%."""
    h = random.random()  # Random hue [0, 1]
    l = random.uniform(low / 100.0, high / 100.0)  # noqa: E741
    s = random.uniform(0.8, 1.0)  # High saturation for vibrance
    r, g, b = colorsys.hls_to_rgb(h, l, s)
    return f"#{int(r * 255):02x}{int(g * 255):02x}{int(b * 255):02x}"


def main():
    parser = argparse.ArgumentParser(description="iTerm2 CLI utilities")
    parser.add_argument("color", nargs="?", help="Background color in hex format, e.g. #1e1e1e")
    parser.add_argument("--random", action="store_true", help="Set a random vibrant background color")
    parser.add_argument("--low", type=int, default=2, help="Lower bound (inclusive) for lightness (0-100, default: 2)")
    parser.add_argument("--high", type=int, default=5, help="Upper bound (inclusive) for lightness (0-100, default: 5)")

    args = parser.parse_args()

    # Validate --low and --high for lightness
    if args.random:
        if not (0 <= args.low <= 100):
            parser.error("--low must be between 0 and 100")
        if not (0 <= args.high <= 100):
            parser.error("--high must be between 0 and 100")
        if args.low > args.high:
            parser.error("--low cannot be greater than --high")
        color = random_vibrant_color(args.low, args.high)
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
