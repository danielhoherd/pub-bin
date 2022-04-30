#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
# Description: sorts a space-separated list on a single line

import sys

print(" ".join(sorted(sys.argv[1:])))
