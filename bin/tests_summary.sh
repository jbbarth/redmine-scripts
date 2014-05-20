#!/bin/bash
cd $(dirname $0)/..
grep -e ' examples,' -e 'skips$' $(./script/tests_last_log_all.sh)
