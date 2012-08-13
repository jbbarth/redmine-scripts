#!/bin/bash

cd $(dirname $0)/../

for i in plugins/redmine_* public/themes/ministere; do
  cd $i >/dev/null
  echo $i |tr 'a-z' 'A-Z'
  git checkout master
  git config --get remote.origin.url |grep jbbarth >/dev/null && git pull --rebase origin master
  cd - >/dev/null
done
