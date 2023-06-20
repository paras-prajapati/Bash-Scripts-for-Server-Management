#!/bin/bash

# A BASH script for deploying WordPress content changes from staging to production.

echo -e "Starting MySQL backup. Please wait ..."

WPDBNAME=`cat /home/forge/staging.ntdbeautypageant.com/public/wp-config.php | grep DB_NAME | cut -d \' -f 4`
WPDBUSER=`cat /home/forge/staging.ntdbeautypageant.com/public/wp-config.php | grep DB_USER | cut -d \' -f 4`
WPDBPASS=`cat /home/forge/staging.ntdbeautypageant.com/public/wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`

PRODUCTION_DIR="/home/forge/missntd.org"

STAGING_DB=$PRODUCTION_DIR/missntd.org-"`date "+%d-%m-%Y"`".sql
mysqldump -u$WPDBUSER -p$WPDBPASS $WPDBNAME | sed "s/staging.ntdbeautypageant.com/missntd.org/g" > $STAGING_DB

echo -e "MySQL backup done - $mysql_backup_file"

echo -e "Starting web site backup. Please wait ..."

STAGING_DIR="/home/forge/staging.ntdbeautypageant.com"
PRODUCTION_DIR="/home/forge/missntd.org"

echo 'Syncing uploads folders...'
rsync -a $STAGING_DIR/* $PRODUCTION_DIR/

echo -e "Web site backup done - $site_backup_file"

echo -e "Thank you!"

