#!/bin/bash
set -e

#empty?
[ -z "$1" ] && echo "Please give me a directory where to find a redmine archive !" >&2 && exit 1

env=$(basename $1|sed 's/-blank$//')

cd $1/

echo "* Verifying if it's a redmine directory"
test -e lib/redmine.rb || (echo "Error: not a redmine directory !!" && exit 1)

echo "* Creating a RVM environment for this release (2.2.3@$env)"
set +e
rm -f .rvmrc* .ruby-version* .ruby-gemset*
source "${rvm_path:-/usr/local/rvm}/scripts/rvm"
rvm 2.3.4@$env --ruby-version --create
set -e
rvm_setup_ok=$(rvm gemset list |grep =|grep redmine|wc -l)
[ $rvm_setup_ok -eq 0 ] && echo "Error: rvm setup probably failed !! Exiting." && exit 1

if ! test -e config/database.yml; then
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
else
  echo "* Skipping config/database.yml (already exists)"
fi

if ! which Magick-config >/dev/null; then
  if which lsb_release && [[ "$(lsb_release -si)" == "Debian" ]]; then
    echo "* Installing 'libmagickwand-dev' package for Debian"
    sudo apt-get install -y libmagickwand-dev
  fi
fi


echo "* Installing gems (can take some time)"
if [[ "$OSTYPE" == "darwin"* ]]; then
  if which Magick-config >/dev/null 2>/dev/null; then
    export C_INCLUDE_PATH=$(Magick-config --prefix)/include/ImageMagick-6/
    export PKG_CONFIG_PATH=$(Magick-config --prefix)/lib/pkgconfig/
  else
    echo "Error: cannot find Magick-config, maybe you should install imagemagick with: brew install imagemagick"
  fi
fi

which bundle >/dev/null || gem install bundler

bundle check || bundle install

echo "* Generating secret token"
bundle exec rake generate_session_store >/dev/null 2>/dev/null

echo "* Migrating database (can take some time)"
bundle exec rake db:migrate >/dev/null

echo "* Loading default data (en)"
REDMINE_LANG=en rake redmine:load_default_data >/dev/null

echo "* Filesystem permissions"
mkdir -p tmp tmp/pdf public/plugin_assets
user=$(getent passwd www-data >/dev/null 2>/dev/null && echo "www-data" || id -un)
group=$(id -gn)
sudo chown -R $user:$group files log tmp public/plugin_assets
sudo chmod -R 755 files log tmp public/plugin_assets

echo -n "* Testing installation: "
rails runner "puts 'OK.'" 2>/dev/null

if test -e ~/.pow; then
  echo "* Generating config for pow"
  ln -s $(pwd) ~/.pow/redmine.standard.$env
  cat > .powrc <<EOF
if [ -f "$rvm_path/scripts/rvm" ] && [ -f ".ruby-version" ]; then
  source "$rvm_path/scripts/rvm"
   if [ -f ".ruby-gemset" ]; then
    rvm use \$(cat .ruby-version)@\$(cat .ruby-gemset)
  else
    rvm use \$(cat .ruby-version)
  fi
fi
#export RAILS_ENV=production
EOF
fi

echo "* Finished!"
if test -e ~/.pow; then
  echo
  echo "  Browse to http://redmine.standard.$env.dev/"
fi
echo
