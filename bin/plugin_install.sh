#!/bin/bash
set -e

[ -z "$1" ] && echo "No redmine directory provided, exiting! (ex: /path/to/redmine)" >&2 && exit 1
[ -z "$2" ] && echo "No plugin source provided, exiting! (ex: jbbarth/redmine_base_rspec ; https://github.com will be inserted automatically)" >&2 && exit 1

redmine_directory=$(echo $1 | perl -pe 's#$#/plugins#;s#//+#/#g;s#/plugins/plugins#/plugins#')
plugin_source=$(echo $2 | perl -pe 's#^#https://github.com/#')
plugin_name=$(basename $2)

echo "* Installing in $redmine_directory"
cd $redmine_directory

if test -e $plugin_name; then
  echo "Error: $plugin_name is already present in $redmine_directory" >&2
  exit 1
fi

echo "* Downloading $plugin_source"
git clone $plugin_source $plugin_name

cd ..
if test -e $plugin_name/Gemfile; then
  echo "* Installing dependencies"
  bundle check || bundle install
fi

if test -e $plugin_name/db/migrate; then
  echo "* Migrating database"
  NAME=$plugin_name bundle exec rake db:migrate redmine:plugins:migrate
fi

if test -e $plugin_name/assets; then
  echo "* Copying assets"
  NAME=$plugin_name bundle exec rake redmine:plugins:assets
fi
