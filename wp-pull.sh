#!/bin/bash

NOW=$(date +'%m/%d/%Y')
DAYS_TO_KEEP=14
REMOTE_HOST=yourserver.yourdomain.com
REMOTE_USER=your-login-user
REMOTE_PORT=22

# path to private key
#KEY=/home/forge/.ssh/authorized_keys

# path to pull the files from
REMOTE_PATH=/home/forge/missntd.org/* 

# path to backup to files to
LOCAL_PATH=/root/missntd.org

#----------------------------------------
echo "Copying files from $REMOTE_HOST to backup server ........"

#rsync -rsh -e "ssh -i $KEY" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH $LOCAL_PATH

rsync -avz -e ssh $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH $LOCAL_PATH
echo "Done"

PRODUCTION_DB="missntdprd"
mysql -u root -p $PRODUCTION_DB < /root/missntd.org/missntd.org-"`date "+%d-%m-%Y"`".sql

# Delete old backups
#if [ "$DAYS_TO_KEEP" -gt $NOW ] ; then
  #echo "Deleting backups older than $DAYS_TO_KEEP days"
 # find $LOCAL_PATH/ -mtime +$DAYS_TO_KEEP -exec rm {} \;
#fi

