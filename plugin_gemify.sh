#!/bin/bash
set -e

[ -z "$1" ] && echo "No plugin name provided, exiting!" >&2 && exit 1

cd $1/
name=$(basename $1)

echo "* Creating a new branch ('gem')"
git checkout -b gem

echo "* Give a plugin description"
echo -n "  Description: "
read description

#README
echo "* Adapting README"
test -e README.rdoc && mv README.rdoc README.md
cat >> README.md <<EOF
---------------------------------

Redmine ${name/redmine_} plugin
======================

$description

Installation
------------

This plugin is compatible with Redmine 2.1.0+. It is distributed as a ruby gem.

Add this line to your redmine's Gemfile.local:

    gem '$name'

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

#turn it into a gem
echo "* Turning the plugin into a gem"
bundle gem $name >/dev/null
mv $name/.gitignore $name/LICENSE.txt $name/$name.gemspec $name/Gemfile $name/Rakefile .
cat $name/lib/$name.rb >> lib/$name.rb; rm $name/lib/$name.rb
test -e lib/$name || mkdir lib/$name; mv $name/lib/$name/version.rb lib/$name/; rmdir $name/lib/$name; rmdir $name/lib
rm -rf $name/README.md $name/.git/
rmdir $name

#adapt gemspec
echo "* Adapting $name.gemspec"
sed -i '' "/spec.authors /s/jbbarth/Jean-Baptiste Barth/" $name.gemspec
sed -i '' "/spec.description /s/TODO: Write a gem description/$description/" $name.gemspec
sed -i '' "/spec.summary /s/TODO: Write a gem summary/$description/" $name.gemspec
sed -i '' "/spec.homepage /s#\"\"#\"https://github.com/jbbarth/$name\"#" $name.gemspec

#adapt init.rb for gem
echo "* Adapting init.rb for gemification"
(echo "require '$name/version'"; echo; cat init.rb) > init.rb.new; mv init.rb.new init.rb #<3 shell :/
modulename=$(grep module lib/$name.rb | tail -n 1 | cut -d" " -f 2)
sed -i '' "/^  version /s#.*#  version $modulename::VERSION#" init.rb

#adapt redmine_xxx.rb
echo "* Adapting lib/$name.rb for engine-ification"
sed -i '' '$d' lib/$name.rb #last line is a "end" we replace in the following section
sed -i '' "/Your code goes here/d" lib/$name.rb
cat >> lib/$name.rb <<EOF
  # Run the classic redmine plugin initializer after rails boot
  class Plugin < ::Rails::Engine
    config.after_initialize do
      require File.expand_path("../../init", __FILE__)
    end
  end
end
EOF

echo "* Done gemifying $name!"
