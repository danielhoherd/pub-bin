#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Author: github.com/danielhoherd
# License: Unlicense
import json
import sys

import yaml  # pyyaml

if len(sys.argv) > 1:
    for filename in sys.argv[1:]:
        with open(filename) as f:
            try:
                for doc in yaml.safe_load_all(f):
                    print(json.dumps(doc))
            except yaml.scanner.ScannerError as err:
                sys.stderr.write("ERROR: {0} could not be parsed\n{1}\n".format(filename, err))
            except KeyboardInterrupt:
                sys.exit(1)

else:
    try:
        for doc in yaml.safe_load_all(sys.stdin):
            print(json.dumps(doc))
    except KeyboardInterrupt:
        sys.exit(1)
