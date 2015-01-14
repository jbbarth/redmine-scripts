#!/bin/bash
set -e

#releases
REDMINE_2_0_0=http://rubyforge.org/frs/download.php/76134/redmine-2.0.0.tar.gz
REDMINE_2_0_1=http://rubyforge.org/frs/download.php/76154/redmine-2.0.1.tar.gz
REDMINE_2_0_2=http://rubyforge.org/frs/download.php/76189/redmine-2.0.2.tar.gz
REDMINE_2_0_3=http://rubyforge.org/frs/download.php/76259/redmine-2.0.3.tar.gz
REDMINE_2_0_4=http://rubyforge.org/frs/download.php/76444/redmine-2.0.4.tar.gz
REDMINE_2_1_0=http://rubyforge.org/frs/download.php/76448/redmine-2.1.0.tar.gz
REDMINE_2_1_2=http://rubyforge.org/frs/download.php/76495/redmine-2.1.2.tar.gz
REDMINE_2_1_3=http://rubyforge.org/frs/download.php/76578/redmine-2.1.3.tar.gz
REDMINE_2_1_4=http://rubyforge.org/frs/download.php/76589/redmine-2.1.4.tar.gz
REDMINE_2_1_5=http://rubyforge.org/frs/download.php/76623/redmine-2.1.5.tar.gz
REDMINE_2_2_0=http://rubyforge.org/frs/download.php/76627/redmine-2.2.0.tar.gz
REDMINE_2_1_6=http://rubyforge.org/frs/download.php/76681/redmine-2.1.6.tar.gz
REDMINE_2_2_1=http://rubyforge.org/frs/download.php/76677/redmine-2.2.1.tar.gz
REDMINE_2_2_2=http://rubyforge.org/frs/download.php/76722/redmine-2.2.2.tar.gz
REDMINE_2_2_3=http://rubyforge.org/frs/download.php/76771/redmine-2.2.3.tar.gz
REDMINE_2_2_4=http://rubyforge.org/frs/download.php/76863/redmine-2.2.4.tar.gz
REDMINE_2_3_0=http://rubyforge.org/frs/download.php/76867/redmine-2.3.0.tar.gz
REDMINE_2_3_1=http://rubyforge.org/frs/download.php/76933/redmine-2.3.1.tar.gz
REDMINE_2_3_2=http://rubyforge.org/frs/download.php/77023/redmine-2.3.2.tar.gz
REDMINE_2_3_3=http://rubyforge.org/frs/download.php/77138/redmine-2.3.3.tar.gz
REDMINE_2_4_1=http://www.redmine.org/releases/redmine-2.4.1.tar.gz
REDMINE_2_4_2=http://www.redmine.org/releases/redmine-2.4.2.tar.gz
REDMINE_2_4_3=http://www.redmine.org/releases/redmine-2.4.3.tar.gz
REDMINE_2_4_4=http://www.redmine.org/releases/redmine-2.4.4.tar.gz
REDMINE_2_4_5=http://www.redmine.org/releases/redmine-2.4.5.tar.gz
REDMINE_2_4_6=http://www.redmine.org/releases/redmine-2.4.6.tar.gz
REDMINE_2_4_7=http://www.redmine.org/releases/redmine-2.4.7.tar.gz
REDMINE_2_5_0=http://www.redmine.org/releases/redmine-2.5.0.tar.gz
REDMINE_2_5_1=http://www.redmine.org/releases/redmine-2.5.1.tar.gz
REDMINE_2_5_2=http://www.redmine.org/releases/redmine-2.5.2.tar.gz
REDMINE_2_5_3=http://www.redmine.org/releases/redmine-2.5.3.tar.gz
REDMINE_2_6_0=http://www.redmine.org/releases/redmine-2.6.0.tar.gz
REDMINE_2_6_1=http://www.redmine.org/releases/redmine-2.6.1.tar.gz
#latest
LATEST=$REDMINE_2_6_1

#download
rel=${1:-LATEST}
url=$(eval "echo \$${rel}")
echo "* Downloading $(basename $url)"
wget --quiet "$url" -O /tmp/redmine.tgz

#unpack
to=$2
[ -z "$to" ] && to=$(echo $url|awk -F'/' '{print $NF}'|sed 's/.tar.gz$/-blank/') # => redmine-X.X.X-blank
echo "* Unpacking archive to $to/"
dirname=$(tar -tf /tmp/redmine.tgz |head -n 1|cut -d"/" -f 1)
if [ -e "$dirname" ]; then
  echo "Error: $dirname already exists, not doing anything" >&2
else
  tar xzf /tmp/redmine.tgz
  if [ -e "$to" ]; then
    echo "Warning: $to already exists, leaving $dirname as is" >&2
  else
    mv $dirname $to
  fi
fi

#cleanup
echo "* Cleaning download file"
rm /tmp/redmine.tgz
