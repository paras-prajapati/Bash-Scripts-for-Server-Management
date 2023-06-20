#!/bin/bash

# Set your variables
s3_bucket="s3://e2e-cpanel-backup/cpanel_backups/"
backup_dir="/backup/cpanel_users"
date=$(date +"%Y-%m-%d")

# Create backup directory if it doesn't exist
mkdir -p "${backup_dir}/${date}"

# Loop through all cPanel users and create backups
for user in $(ls -A /var/cpanel/users); do
  /scripts/pkgacct --dbbackup=all --skipapitokens --skipbwdata --skipdnszones --skipdomains --skipftpusers --skipintegrationlinks --skiplinkednodes --skiplocale --skiplogs --skipmail --skipmailconfig --skipmailman --skipquota --skipresellerconfig --skipshell --skipssl "${user}" "${backup_dir}/${date}"
done

/scripts/pkgacct --dbbackup=all --skipapitokens --skipbwdata --skipdnszones --skipdomains --skipftpusers --skipintegrationlinks --skiplinkednodes --skiplocale --skiplogs --skipmail --skipmailconfig --skipmailman --skipquota --skipresellerconfig --skipshell --skipssl "${user}" "${backup_dir}/${date}"

# Sync backup directory to S3 bucket
/usr/local/bin/aws s3 cp $backup_dir $s3_bucket --recursive

# Remove local backup files older than 7 days (optional)
rm -r /backup/cpanel_users/