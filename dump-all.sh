#!/bin/bash

source ~/bin/dbinfo

date
echo "starting"
mysqldump --add-drop-table -h $host -u $dbuser -p $db | gzip > ~/$db.all.sql.gz
date
echo "done"
