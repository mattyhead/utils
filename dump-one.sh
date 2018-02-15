if [ "$#" -eq 1 ]; then
source ~/bin/dbinfo
date
mysqldump --add-drop-table -h $host -u $dbuser -p $db $1 | gzip > ~/$db.$1.sql.gz
date
fi
