#!/bin/bash
set -e

[ -z "$1" ] && echo "No plugin name provided, exiting!" >&2 && exit 1

cd $(dirname $0)/..

echo "* Give a plugin description"
echo -n "  Description: "
read description

#Plugin generation
echo "* Generating a new plugin $1"
rails g redmine_plugin $1 >/dev/null 2>&1
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

This plugin is compatible with Redmine 2.1.0+. It is distributed as a ruby gem.

Add this line to your redmine's Gemfile.local:

    gem '$1'

And then execute:

    $ bundle install

Then restart your Redmine instance.

Note that general instructions for plugins [here](http://www.redmine.org/wiki/redmine/Plugins) don't apply here.


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

#turn it into a gem
echo "* Turning the plugin into a gem"
bundle gem $1 >/dev/null
mv $1/.gitignore $1/LICENSE.txt $1/lib $1/$1.gemspec $1/Gemfile $1/Rakefile .
rm -rf $1/README.md $1/.git/
rmdir $1

#adapt gemspec
echo "* Adapting $1.gemspec"
sed -i '' "/spec.authors /s/jbbarth/Jean-Baptiste Barth/" $1.gemspec
sed -i '' "/spec.description /s/TODO: Write a gem description/$description/" $1.gemspec
sed -i '' "/spec.summary /s/TODO: Write a gem summary/$description/" $1.gemspec
sed -i '' "/spec.homepage /s#\"\"#\"https://github.com/jbbarth/$1\"#" $1.gemspec

#adapt init.rb for gem
echo "* Adapting init.rb for gemification"
(echo "require '$1/version'"; echo; cat init.rb) > init.rb.new; mv init.rb.new init.rb #<3 shell :/
modulename=$(grep module lib/$1.rb |cut -d" " -f 2)
sed -i '' "/^  version /s#.*#  version $modulename::VERSION#" init.rb

#adapt redmine_xxx.rb
echo "* Adapting lib/$1.rb for engine-ification"
sed -i '' "/^end$/d" lib/$1.rb
sed -i '' "/Your code goes here/d" lib/$1.rb
cat >> lib/$1.rb <<EOF
  # Run the classic redmine plugin initializer after rails boot
  class Plugin < ::Rails::Engine
    config.after_initialize do
      require File.expand_path("../../init", __FILE__)
    end
  end
end
EOF

#git
git init
git add .
git ci -m "Initial commit"
git remote add origin git@github.com:jbbarth/$1
