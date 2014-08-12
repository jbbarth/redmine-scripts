#!/bin/bash
cd $(dirname $0)/..

./script/tests_prepare.sh >/dev/null
./script/tests_run_all.sh|tee log/test-all-$(date +'%Y%m%d-%H%M').log

echo

echo "SUMMARY:"
./script/tests_summary.sh | perl -pe 's/^/  /'

echo "FAILURES:"
./script/tests_which_failed.sh |perl -pe 's/^/  /'
