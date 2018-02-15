if [ -f $1 ] 
then
source ~/bin/dbinfo
  date 
  gunzip < $1 | sed 's/charset \= utf8/charset \= utf8mb4/g' | mysql -h $host -u $dbuser -p $db 
  date
exit 0
fi
echo "filename: $1"
echo "...not found."
exit 1
