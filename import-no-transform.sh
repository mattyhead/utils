#!/bin/bash

source ~/bin/dbinfo

if [ "x" == "x$1" ]
then
  script="${0##*/}"
  echo "usage: ${0##*/} [file to import (.sql.gz)]"
  exit 1
fi

if [ -f $1 ] 
then
  date 
  gunzip < $1 |mysql -h $host -u $dbuser -p $db
  date
  exit 0
fi
echo "file: $1"
echo "...not found"
exit 1
