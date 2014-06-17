#!/bin/bash
set -e

[ -z "$1" ] && echo "No plugin name provided, exiting!" >&2 && exit 1

cd $(dirname $0)/..

echo "* Give a plugin description"
echo -n "  Description: "
read description

#Plugin generation
echo "* Generating a new plugin $1"
rails g redmine_plugin $1 >/dev/null
cd plugins/$1

#Remove empty things + locales
echo "* Removing useless stuff"
find . -empty -delete
rm -r config

#README
echo "* Adapting README"
mv README.rdoc README.md
cat > README.md <<EOF
Redmine ${1/redmine_} plugin
======================

$description

Installation
------------

This plugin is compatible with Redmine 2.1.0+.

Please apply general instructions for plugins [here](http://www.redmine.org/wiki/redmine/Plugins).

First download the source or clone the plugin and put it in the "plugins/" directory of your redmine instance. Note that this is crucial that the directory is named $1 !

Then execute:

    $ bundle install
    $ rake redmine:plugins

And finally restart your Redmine instance.


Contributing
------------

1. Fork it
2. Create your feature branch (\`git checkout -b my-new-feature\`)
3. Commit your changes (\`git commit -am 'Add some feature'\`)
4. Push to the branch (\`git push origin my-new-feature\`)
5. Create new Pull Request
EOF

#adapt init.rb
echo "* Adapting init.rb to our needs"
sed -i '' "/^  author /s/.*/  author 'Jean-Baptiste BARTH'/" init.rb
sed -i '' "/^  url /s#.*#  url 'https://github.com/jbbarth/$1'#" init.rb
sed -i '' "/^  author_url /s/.*/  author_url 'jeanbaptiste.barth@gmail.com'/" init.rb

#git
git init
git add .
git ci -m "Initial commit"
git remote add origin git@github.com:jbbarth/$1
