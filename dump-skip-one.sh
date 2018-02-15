#!/bin/bash
source ~/bin/dbinfo
if [ "x" == "x$1" ]
then
  script="${0##*/}"
  echo "usage: ${0##*/} [table to skip]"
  exit 1
else
date
echo "starting"
  mysqldump --ignore-table=$db.$1 --add-drop-table -h $host -u $dbuser -p $db | gzip > ~/$db.$1.sql.gz
date
echo "done"
fi
exit 0
