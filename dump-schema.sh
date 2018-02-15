source ~/bin/dbinfo
date
mysqldump --add-drop-table --no-data -h $host -u $dbuser -p $db | gzip > ~/$db.schema.sql.gz
date
