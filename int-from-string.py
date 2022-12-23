#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
import hashlib

import typer


def int_for_string(input_string: str, sha: bool = False):
    """This script takes an alphanumeric string input and deterministically
    returns an integer.

    By default, the text converts the string from base-36 to decimal,
    which gives output that varies in length based on the input length.
    Optionally it can hash the input before conversion, which gives a
    somewhat more fixed length output, though it does still vary.
    """
    if sha:
        hash_object = hashlib.new("SHA224")
        hash_object.update(bytes(input_string, "utf-8"))
        print(int(hash_object.hexdigest(), 16))
    else:
        print(int(input_string, 36))


if __name__ == "__main__":
    typer.run(int_for_string)
