#!/bin/bash
export RAILS_ENV=test
test -e test/.fixtures.core || cp -a test/fixtures test/.fixtures.core
rm -rf test/fixtures
cp -a test/.fixtures.core test/fixtures
cp -i plugins/*/test/fixtures/*yml test/fixtures/
bundle exec rake db:drop db:create db:migrate redmine:plugins db:schema:dump #db:fixtures:load
cp -f db/test.sqlite3 db/test.template.sqlite3
