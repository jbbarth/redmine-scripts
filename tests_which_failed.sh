#!/bin/bash

cd $(dirname $0)/..
lastlog=$(ls log/test-all-* | tail -n 1)
grep -o '\[.*\]:$' "$lastlog" | \
  perl -pe 's/\[([^:]+):.*/\1/' | \
  sed -e "s#$(pwd)/##" | \
  sort -u
