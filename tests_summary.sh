#!/bin/bash
cd $(dirname $0)/..
grep 'skips$' $(./script/tests_last_log_all.sh)
