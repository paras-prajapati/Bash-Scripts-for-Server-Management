#!/bin/bash

USER='username'       # MySQL User
PASSWORD='mysql_passwd' # MySQL Password
BACKUP_PATH='full_path_backup_dir' #Full Path to Backup Dir
#----------------------------------------

# Create the backup folder
if [ ! -d $BACKUP_PATH ]; then
  mkdir -p $BACKUP_PATH
fi

# Get list of database names
databases=`mysql -u $USER -p$PASSWORD -e "SHOW DATABASES;" | tr -d "|" | grep -v Database`

for db in $databases; do

  if [ $db == 'information_schema' ] || [ $db == 'performance_schema' ] || [ $db == 'mysql' ] || [ $db == 'sys' ]; then
    echo "Skipping database: $db"
    continue
  fi
  
  date=$(date -I)
  if [ "$GZIP" -eq 0 ] ; then
    echo "Backing up database: $db without compression"   
    mysqldump -u $USER -p$PASSWORD --no-tablespaces --single-transaction --skip-lock-tables --databases $db > $BACKUP_PATH/$date-$db.sql
  else
    echo "Backing up database: $db with compression"
    mysqldump -u $USER -p$PASSWORD --no-tablespaces --single-transaction --skip-lock-tables --databases $db | gzip -c > $BACKUP_PATH/$date-$db.gz
  fi
done

echo "Done"

#To delete files older than 30 days
find $BACKUP_PATH/* -mtime +30 -exec rm {} \;
