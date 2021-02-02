#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
import json
import sys

import yaml

files = sys.argv[1:]

if len(files) == 0:
    files.append("/dev/stdin")

try:
    for filename in files:
        with open(filename) as f:
            print(yaml.safe_dump(json.load(f), default_flow_style=False))

except json.decoder.JSONDecodeError as err:
    sys.stderr.write(f"ERROR: {filename} could not be parsed\n{err}\n")
except BrokenPipeError:
    pass
except KeyboardInterrupt:
    sys.exit(1)
