#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
import sys

import yaml

if len(sys.argv) > 1:
    for filename in sys.argv[1:]:
        with open(filename) as f:
            try:
                print(yaml.safe_dump(json.load(f), default_flow_style=False))
            except json.decoder.JSONDecodeError as err:
                sys.stderr.write("ERROR: {0} could not be parsed\n{1}\n".format(filename, err))
else:
    try:
        print(yaml.dump(json.load(sys.stdin), default_flow_style=False))
    except json.decoder.JSONDecodeError as err:
        sys.stderr.write("ERROR: stdin could not be parsed\n{0}\n".format(err))
    except KeyboardInterrupt:
        sys.exit(1)
