#!/bin/bash

source ~/bin/dbinfo

if [ "x" == "x$1" ]
then
  script="${0##*/}"
  echo "usage: ${0##*/} [table to dump]"
  exit 1
fi

date
echo "starting"
mysqldump --add-drop-table -h $host -u $dbuser -p $db $1 | gzip > ~/$db.$1.sql.gz
date
echo "done"

exit 0