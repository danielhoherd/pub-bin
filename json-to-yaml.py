#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
import json
import sys

import yaml

if len(sys.argv) > 1:
    for filename in sys.argv[1:]:
        with open(filename) as f:
            try:
                print(yaml.safe_dump(json.load(f), default_flow_style=False))
            except json.decoder.JSONDecodeError as err:
                sys.stderr.write(f"ERROR: {filename} could not be parsed\n{err}\n")
else:
    try:
        print(yaml.dump(json.load(sys.stdin), default_flow_style=False))
    except json.decoder.JSONDecodeError as err:
        sys.stderr.write(f"ERROR: stdin could not be parsed\n{err}\n")
    except KeyboardInterrupt:
        sys.exit(1)
