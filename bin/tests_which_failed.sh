#!/bin/bash
cd $(dirname $0)/..
grep -o '\[.*\]:$' "$(./script/tests_last_log_all.sh)" | \
  perl -pe 's/\[([^:]+):.*/\1/' | \
  sed -e "s#$(pwd)/##" | \
  sort -u
