#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
import json
import sys

import yaml  # pyyaml

files = sys.argv[1:]

if len(files) == 0:
    files.append("/dev/stdin")

try:
    for filename in files:
        with open(filename) as f:
            for doc in yaml.safe_load_all(f):
                print(json.dumps(doc))
except yaml.scanner.ScannerError as err:
    sys.stderr.write(f"ERROR: {filename} could not be parsed\n{err}\n")
except KeyboardInterrupt:
    sys.exit(1)
