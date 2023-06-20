#!/bin/bash

# connection info
REMOTE_HOST=yourserver.yourdomain.com
REMOTE_USER=your-login-user
REMOTE_PORT=22

# path to private key
#KEY=/home/??/

# path to pull the files from
REMOTE_PATH=/home/backup/backuptest

# path to backup to files to
LOCAL_PATH=/home/backup/backuptest

#----------------------------------------
echo "Copying files from $REMOTE_HOST to backup server ........"

#rsync -rsh -e "ssh -i $KEY" $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH $LOCAL_PATH

rsync -avz -e ssh $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH $LOCAL_PATH
echo "Done"

#To delete files older than 14 days
find $LOCAL_PATH/* -mtime +14 -exec rm {} \;

