#!/usr/bin/env bash
# Author: github.com/danielhoherd
# License: Unlicense
# Delete all local tmutil snapshots. Useful for when you've been doing data heavy
# things that don't need to be backed up, but were snapshotted, and now you need
# that disk space back.

/usr/bin/tmutil listlocalsnapshots / |
while read -r SNAPSHOT_NAME ; do
  /usr/bin/tmutil deletelocalsnapshots "${SNAPSHOT_NAME##*.}"
done
