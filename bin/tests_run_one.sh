#!/bin/bash
export RAILS_ENV=test
\cp db/test.template.sqlite3 db/test.sqlite3
ruby -Itest $1
