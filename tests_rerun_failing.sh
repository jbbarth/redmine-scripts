#!/bin/bash
cd $(dirname $0)/..
./script/tests_which_failed.sh | \
  sort -r | \
  xargs -n 1 ./script/tests_run_one.sh
