#!/bin/bash
cd $(dirname $0)/..
ls log/test-all-* | tail -n 1
