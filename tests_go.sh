#!/bin/bash
cd $(dirname $0)/..
./script/tests_prepare.sh >/dev/null 2>&1
./script/tests_run_all.sh|tee log/test-all-$(date +'%Y%m%d-%H%M').log
