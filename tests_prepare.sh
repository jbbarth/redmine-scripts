#!/bin/bash
export RAILS_ENV=test
cp -f plugins/*/test/fixtures/*yml test/fixtures/
rake db:drop db:create db:migrate redmine:plugins db:schema:dump db:fixtures:load
cp -f db/test.sqlite3 db/test.template.sqlite3
