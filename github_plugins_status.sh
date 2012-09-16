#!/bin/bash

cd $(dirname $0)/../

for i in plugins/redmine_* public/themes/ministere; do
  cd $i >/dev/null
  lines=$(git status --short|wc -l)
  if [ "$lines" -eq "0" ]; then
    echo "$i : no change"
  else
    echo "$i : CHANGED"
    git status --short
  fi
  cd - >/dev/null
done
