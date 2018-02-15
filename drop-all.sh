source ~/bin/dbinfo
date

MUSER=$dbuser
MDB=$db 
MHOST=$host

# Detect paths
MYSQL=$(which mysql)
AWK=$(which awk)
GREP=$(which grep)
 
echo "please provide the password for user: $MUSER"
read MPASS

if [ "$MPASS" == "" ]
then
 echo "Hell no, I'm not asking for that password over and over... quitting."
 exit 1
fi
 
# make sure we can connect to server
$MYSQL -u $MUSER -p$MPASS -h $MHOST -e "use $MDB"  &>/dev/null
if [ $? -ne 0 ]
then
 echo "Error - Cannot connect to mysql server using given username, password or database does not exits!"
 exit 2
fi
 
TABLES=$($MYSQL -u $MUSER -p$MPASS -h $MHOST $MDB -e 'show tables' | $AWK '{ print $1}' | $GREP -v '^Tables' )
 
# make sure tables exits
if [ "$TABLES" == "" ]
then
 echo "Error - No table found in $MDB database!"
 exit 3
fi
 
# let us do it
for t in $TABLES
do
 echo "Deleting $t table from $MDB database..."
 $MYSQL -u $MUSER -p$MPASS -h $MHOST $MDB -e "drop table $t"
done
date
