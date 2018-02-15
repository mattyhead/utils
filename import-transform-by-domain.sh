#!/bin/bash

source ~/bin/dbinfo

if [ -f $1 ] 
then
  date
  gunzip < $1 | sed 's/www\.philadelphiavotes\.com/$dbuser\.com/g' | sed  's/philadelphiavotes\.com/$dbuser\.com/g' | sed 's/\/home\/citycom2/\/home\/$dbuser/g' | sed "s/MyISAM/Aria/g" | sed "s/InnoDB/Aria/g" | mysql -h $host -u $dbuser -p $db
  date
exit 0
fi
echo "filename: $1"
echo "...not found."
exit 1
