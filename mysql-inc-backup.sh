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
  
  day_of_week=$(date +%u)
if [ $day_of_week -eq 0 ]; then 
    
    mysqldump -u $USER -p$PASSWORD --no-tablespaces --single-transaction --skip-lock-tables --databases $db | gzip -c > $BACKUP_PATH/full_backup_$(date +%F)-$db.tar.gz
     #tar -zcf $BACKUP_PATH
else    

    mysqldump -u $USER -p$PASSWORD --no-tablespaces --single-transaction --skip-lock-tables --databases $db | gzip -c > $BACKUP_PATH/inc_backup_$(date +%F)-$db.tar.gz
    #tar -zcf $BACKUP_PATH
    last_full_backup=$(find $BACKUP_PATH -maxdepth 1 -type f -name 'full_backup_*' | sort -n | tail -n 1)    
    if [ -n "$last_full_backup" ]; then
        tar -g $last_full_backup -zcf $BACKUP_PATH  
    else
      mysqldump -u $USER -p$PASSWORD --no-tablespaces --single-transaction --skip-lock-tables --databases $db | gzip -c > $BACKUP_PATH/inc_backup_$(date +%F)-$db.tar.gz
      #tar -g  -zcf $BACKUP_PATH
    fi
fi
done

echo "Done"

#To delete files older than 30 days
find $BACKUP_PATH/* -mtime +30 -exec rm {} \;
