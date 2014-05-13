#!/bin/bash
set -e

#empty?
[ -z "$1" ] && echo "Please give me a directory where to find a redmine archive !" >&2 && exit 1

env=$(basename $1)

cd $1/

echo "* Verifying if it's a redmine directory"
test -e lib/redmine.rb || (echo "Error: not a redmine directory !!" && exit 1)

echo "* Creating a RVM environment for this release (1.9.3@$env)"
set +e
rm -f .rvmrc*
source "${rvm_path:-/usr/local/rvm}/scripts/rvm"
rvm 1.9.3@$env --rvmrc --create
set -e
rvm_setup_ok=$(rvm gemset list |grep =|grep redmine|wc -l)
[ $rvm_setup_ok -eq 0 ] && echo "Error: rvm setup probably failed !! Exiting." && exit 1

echo "* Creating config/database.yml"
cat > config/database.yml <<EOF
production:
  adapter: sqlite3
  database: db/redmine.sqlite3

development:
  adapter: sqlite3
  database: db/redmine.sqlite3

test:
  adapter: sqlite3
  database: db/test.sqlite3
EOF

echo "* Installing gems (can take some time)"
bundle install

echo "* Generating secret token"
bundle exec rake generate_session_store >/dev/null 2>/dev/null

echo "* Migrating database (can take some time)"
bundle exec rake db:migrate >/dev/null

echo "* Loading default data (en)"
REDMINE_LANG=en rake redmine:load_default_data >/dev/null

echo "* Filesystem permissions"
mkdir -p tmp tmp/pdf public/plugin_assets
sudo chown -R jbbarth:staff files log tmp public/plugin_assets
sudo chmod -R 755 files log tmp public/plugin_assets

echo -n "* Testing installation: "
rails runner "puts 'OK.'" 2>/dev/null

if test -e ~/.pow; then
  echo "* Generating config for pow"
  ln -s $(pwd) ~/.pow/redmine.standard.$env
  cat > .powrc <<EOF
  if [ -f "$rvm_path/scripts/rvm" ] && [ -f ".rvmrc" ]; then
    source "$rvm_path/scripts/rvm"
    source ".rvmrc"
  fi
  #export RAILS_ENV=production
EOF
fi

echo "* Finished!"
echo
echo "  Browse to http://redmine.standard.$env.dev/"
echo
