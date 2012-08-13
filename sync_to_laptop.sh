#!/bin/sh
cd $(dirname $0)/..
rsync -avz $* ~/dev/work/redmine-2.0.3/plugins/* 192.168.0.222:dev/work/redmine-2.0.3/plugins/
rsync -avz $* public/themes/* 192.168.0.222:dev/work/redmine-2.0.3/public/themes/
