# go to the install directory
rm ~/.wp-cli/cache/core/*
rm ~/.wp-cli/cache/plugin/*
bin_dir=`dirname $0`
source $bin_dir/dbinfo

wp_dir=~/public_html
plugins_dir=~/public_html/wp-content/plugins
mu_plugins_dir=~/public_html/wp-content/mu-plugins
bcrypt_plugin=password-bcrypt
bcrypt_plugin_file=wp-password-bcrypt.php

cd $wp_dir
pwd
# let's grab some passwords
echo "supply password for mysql user: wordpress"
read NPASS
if [ "$NPASS" == "" ]
then
  echo "no password, no install... quitting."
  exit 1
fi

#echo "supply password for mysql user: pvotes"
#read OPASS
#if [ "$OPASS" == "" ]
#then
#  echo "no pvotes password, no install... quitting."
#  exit 2
#fi

# set some variables
#google-authenticator
#wp_plugins="wp-cleanup-and-basic-functions $bcrypt_plugin debug-bar kint-debugger meta-box admin-email-as-from-address easy-wp-smtp google-calendar-events simple-301-redirects wordpress-importer loco-translate wpglobus amazon-web-services amazon-s3-and-cloudfront front-page-category wp-login-recaptcha theme-check restrict-categories"
wp_plugins="wp-cleanup-and-basic-functions $bcrypt_plugin loco-translate debug-bar kint-debugger amazon-s3-and-cloudfront amazon-web-services wp-login-recaptcha theme-check"
wp_title="Test WP" 
wp_site="http://wp.phillyvotes.org"
wp_admin="pvotes"
wp_db=$db
wp_dbuser=$dbuser
wp_email="matthew.e.murphy@phila.gov"
#wp_extra="define( 'FORCE_SSL_ADMIN', true );"
#wp_insertion_point="\$table_prefix = 'wp_';"
jos_dbuser="pvotes"
jos_db="pvotes"
mysql_cmd="mysql -u$jos_dbuser -p$OPASS -sN -e"

wp core download
#echo $wp_extra | wp core config --dbname=$wp_db --dbuser=$wp_dbuser --dbpass="$NPASS" --extra-php
wp core config --dbname=$wp_db --dbuser=$wp_dbuser --dbpass="$NPASS" --dbhost=$host
wp core install --url="$wp_site" --title="$wp_title" --admin_user=$wp_admin --admin_email=$wp_email
echo "Note the admin password here and when ready, continue by hitting [ENTER]"
read value
wp plugin install $wp_plugins
mkdir $mu_plugins_dir
echo  "<?php" > $mu_plugins_dir/load.php
echo "require WPMU_PLUGIN_DIR.'/$bcrypt_plugin/$bcrypt_plugin_file';" >> $mu_plugins_dir/load.php
mv $plugins_dir/$bcrypt_plugin $mu_plugins_dir
rm $plugins_dir/$bcrypt_plugin -Rf
wp plugin activate $wp_plugins
wp plugin install https://github.com/bueltge/WordPress-Admin-Style/archive/master.zip

wp plugin update --all
exit 0
echo "----------------not doing anything under here\/" 

wp theme install https://github.com/CityOfPhiladelphia/phila.gov-theme/archive/master.zip

# phl customization install
wp plugin install https://github.com/CityOfPhiladelphia/phila.gov-customization/archive/master.zip

echo "If any config is needed before category migration, do so now and, when complete, hit [ENTER]"
read value
categories=`$mysql_cmd "select id from $jos_db.jos_k2_categories where name not like 'Uncategorized'"`

echo "" > ~/categories.txt
for id in $categories; do

  name=`$mysql_cmd "select name from $jos_db.jos_k2_categories where id=$id"`
  slug=`$mysql_cmd "select alias from $jos_db.jos_k2_categories where id=$id"`
  desc=`$mysql_cmd "select replace(replace(replace(description,'\t', ' '), '\n', ''), '\r', '') from $jos_db.jos_k2_categories where id=$id"`
  parent=`$mysql_cmd "select parent from $jos_db.jos_k2_categories where id=$id"`
  sname=`$mysql_cmd "select value from $jos_db.jos_jf_content where reference_id=$id and reference_table='k2_categories' and language_id=2 and reference_field='name' "`
  sdesc=`$mysql_cmd "select replace(replace(replace(value,'\t', ' '), '\r', ''), '\n', '') from $jos_db.jos_jf_content where reference_id=$id and reference_table='k2_categories' and language_id=2 and reference_field='description' "`
  if [ "$name" == "Candidates for Office" ]; then
    slug='candidates-for-office'
  fi
  slugblock="--slug='$slug'"
  if [ "$parent" == "0" ]; then
    parent=""
  else
    parent="--parent=$parent"
  fi
  if [ "$desc" != "" ];then
    desc=`echo $desc | sed 's/"/\"/g'`
  fi
  return=`wp term create category "{:en}$name{:}{:es}$sname{:}" $slugblock $parent --description="{:en}$desc{:}{:es}$sdesc{:}"`
  newid="${return//[!0-9]/}"
  echo "$id, $newid, $slug">>~/categories.txt
  echo $return 
done

echo "Category import complete.  If any configuration is needed prior to item migration, do so now and, when complete, hit [ENTER]"
read value

items=`$mysql_cmd "select id from $jos_db.jos_k2_items"`
echo "" > ~/items.txt

for id in $items; do
  published=`$mysql_cmd "select published from $jos_db.jos_k2_items where id=$id"`
  post_status="trash"
  if [ "$published" == "1" ]; then
    post_status="publish"
  fi
  catid=`$mysql_cmd "select catid from $jos_db.jos_k2_items where id=$id"`
  post_date=`$mysql_cmd "select created from $jos_db.jos_k2_items where id=$id"`

  post_title=`$mysql_cmd "select title from $jos_db.jos_k2_items where id=$id"`
  spost_title=`$mysql_cmd "select replace(replace(replace(value,'\t', ' '), '\r', ''), '\n', '') from $jos_db.jos_jf_content where reference_id=$id and reference_table='k2_items' and language_id=2 and reference_field='title' "`

  post_name=`$mysql_cmd "select alias from $jos_db.jos_k2_items where id=$id"`
  spost_name=`$mysql_cmd "select value from $jos_db.jos_jf_content where reference_id=$id and reference_table='k2_items' and language_id=2 and reference_field='alias' "`

  post_content=`$mysql_cmd "select replace(replace(replace(introtext,'\t', ' '), '\r', ''), '\n', '') from $jos_db.jos_k2_items where id=$id" | sed 's/"/\"/g' | sed 's/  */ /g' | sed 's/ class="[^"]*"//g' | sed 's/ class="[^"]*"//g'`
  spost_content=`$mysql_cmd "select replace(replace(replace(value,'\t', ' '), '\r', ''), '\n', '') from $jos_db.jos_jf_content where reference_id=$id and reference_table='k2_items' and language_id=2 and reference_field='introtext' " | sed 's/"/\"/g' | sed 's/  */ /g' | sed 's/ class="[^"]*"//g' | sed 's/ style="[^"]*"//g'`
  if [ "$spost_content" == "" ]; then
    # no translation available, duplicate english post
    spost_content=$post_content
  fi
  if [ "$spost_title" == "" ]; then
    # no translation available, duplicate english post
    spost_title=$post_title
  fi
  if [ "$spost_name" == "" ]; then
    # no translation available, duplicate english post
    spost_name=$post_name
  fi
  echo "{:en}$post_content{:}{:es}$spost_content{:}" > post_content.txt
  if [ "$catid" == "12" ]; then 
    return=`wp post --post_type="news_post" create ./post_content.txt --post_status="$post_status" --post_category="$catid" --post_date="$post_date" --post_title="{:en}$post_title{:}{:es}$spost_title{:}" --post_name="{:en}$post_name{:}{:es}$spost_name{:}"`
  else
    return=`wp post --post_type="department_page" create ./post_content.txt --post_status="$post_status" --post_category="$catid" --post_date="$post_date" --post_title="{:en}$post_title{:}{:es}$spost_title{:}" --post_name="{:en}$post_name{:}{:es}$spost_name{:}"`
  fi
  newid="${return//[!0-9]/}"
  echo "$id, $newid, $post_name, $spost_name">>~/items.txt
  echo $return
done

rm ./post_content.txt

# cleanup
wp term delete category 14
wp term delete category 10
wp term delete category 17
wp term delete category 11
wp term delete category 9
wp term delete category 8
wp post update 1 --post_status="trash"
