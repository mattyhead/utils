if [ -f $1 ] 
then
  source ~/bin/dbinfo
  date 
  gunzip < $1 |mysql -h $host -u $dbuser -p $db
  date
exit 0
fi
echo "file: $1"
echo "...not found"
exit 1

