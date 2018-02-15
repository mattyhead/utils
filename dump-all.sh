source ~/bin/dbinfo
date
mysqldump --add-drop-table -h $host -u $dbuser -p $db | gzip > ~/$db.all.sql.gz
date
