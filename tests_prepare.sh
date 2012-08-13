#!/bin/bash
export RAILS_ENV=test
rake db:drop db:create db:migrate redmine:plugins db:schema:dump db:fixtures:load
cp db/test.sqlite3 db/test.template.sqlite3
