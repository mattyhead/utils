#!/bin/bash

source ~/bin/dbinfo

date
echo "starting"
mysqldump --add-drop-table --no-data -h $host -u $dbuser -p $db | gzip > ~/$db.schema.sql.gz
date
echo "done"
