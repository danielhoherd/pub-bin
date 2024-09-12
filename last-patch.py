#!/usr/bin/env python3
# Author: github.com/danielhoherd
# License: MIT
"""Print only the last patch version for each major.minor. Expects semver versions as stdin with optional v prefix."""

import sys

import semver


def find_newest_versions(versions):
    newest_versions = {}
    for version in versions:
        has_v_prefix = version.startswith("v")  # Check if the version has a 'v' prefix
        version_stripped = version.lstrip("v") if has_v_prefix else version  # Remove 'v' if present
        parsed_version = semver.VersionInfo.parse(version_stripped)
        major_minor = f"{parsed_version.major}.{parsed_version.minor}"
        if major_minor not in newest_versions:
            newest_versions[major_minor] = parsed_version
        else:
            if parsed_version > newest_versions[major_minor]:
                newest_versions[major_minor] = parsed_version

    return newest_versions.values()


def main():
    versions = [line.strip() for line in sys.stdin.readlines()]
    newest_versions = find_newest_versions(versions)

    for version in newest_versions:
        # Check if the original version had a 'v' prefix and include it if necessary
        version_with_v = f"v{version}" if versions[0].startswith("v") else version
        print(version_with_v)


if __name__ == "__main__":
    main()
