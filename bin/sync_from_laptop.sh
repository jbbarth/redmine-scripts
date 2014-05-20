#!/bin/sh
cd $(dirname $0)/..
rsync -avz 192.168.0.222:dev/work/redmine-2.0.3/plugins/* ~/dev/work/redmine-2.0.3/plugins/
rsync -avz 192.168.0.222:dev/work/redmine-2.0.3/public/themes/* public/themes/
