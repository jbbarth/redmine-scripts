#!/bin/bash
export RAILS_ENV=test
\cp db/test.template.sqlite3 db/test.sqlite3
rake test$1
rake redmine:plugins:test$1
