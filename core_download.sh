#!/bin/bash
set -e

#base rubyforge url
BASE_URL=http://rubyforge.org/frs/download.php
#releases
REDMINE_2_0_0=76134/redmine-2.0.0.tar.gz
REDMINE_2_0_1=76154/redmine-2.0.1.tar.gz
REDMINE_2_0_2=76189/redmine-2.0.2.tar.gz
REDMINE_2_0_3=76259/redmine-2.0.3.tar.gz
REDMINE_2_0_4=76444/redmine-2.0.4.tar.gz
REDMINE_2_1_0=76448/redmine-2.1.0.tar.gz
REDMINE_2_1_2=76495/redmine-2.1.2.tar.gz
REDMINE_2_1_3=76578/redmine-2.1.3.tar.gz
REDMINE_2_1_4=76589/redmine-2.1.4.tar.gz
REDMINE_2_1_5=76623/redmine-2.1.5.tar.gz
REDMINE_2_2_0=76627/redmine-2.2.0.tar.gz
REDMINE_2_1_6=76681/redmine-2.1.6.tar.gz
REDMINE_2_2_1=76677/redmine-2.2.1.tar.gz
REDMINE_2_2_2=76722/redmine-2.2.2.tar.gz
REDMINE_2_2_3=76771/redmine-2.2.3.tar.gz
REDMINE_2_2_4=76863/redmine-2.2.4.tar.gz
REDMINE_2_3_0=76867/redmine-2.3.0.tar.gz
REDMINE_2_3_1=76933/redmine-2.3.1.tar.gz
#latest
LATEST=76933/redmine-2.3.1.tar.gz

#download
rel=${1:-LATEST}
rel=$(eval "echo \$${rel}")
url="$BASE_URL/$rel"
echo "* Downloading $(basename $url)"
wget --quiet "$url" -O /tmp/redmine.tgz

#unpack
echo "* Unpacking archive"
dirname=$(tar -tf /tmp/redmine.tgz |head -n 1|cut -d"/" -f 1)
tar xzf /tmp/redmine.tgz
mv $dirname redmine

#cleanup
echo "* Cleaning download file"
rm /tmp/redmine.tgz
