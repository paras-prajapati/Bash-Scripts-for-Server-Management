#!/bin/bash

# A BASH script for deploying WordPress content changes from staging to production.

STAGING_DIR="/var/www/staging.ntdbeautypageant.com"
PRODUCTION_DIR="/var/www/missntd.org"
STAGING_DB="stagingntdbeau"
PRODUCTION_DB="missntdprd"

# Get list of currently installed plugins from production site
cd $PRODUCTION_DIR
production_plugin_status=`tempfile 2>/dev/null` || tempfile=/tmp/temp$$
wp plugin status --porcelain > $production_plugin_status 

# Dump the staging database to temp file; import into production site
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/temp$$
mysqldump -u root -p $STAGING_DB | sed "s/staging.ntdbeautypageant.com/missntd.org/g" > $tempfile


mysql -u root -p $PRODUCTION_DB < $tempfile

# Get list of installed plugins after copying the database over
staging_plugin_status=`tempfile 2>/dev/null` || tempfile=/tmp/temp$$
wp plugin status --porcelain > $staging_plugin_status

echo 'Syncing uploads folders...'

rsync -a $STAGING_DIR/* $PRODUCTION_DIR/

echo "Done"

# Compare before/after status of installed plugins; activate or deactivate as necessary
STATUS_DIFF=`paste $production_plugin_status $staging_plugin_status | grep -v 'Installed plugins' | grep -v 'Legend:' | awk '$1 != $3'`
if [ -n "$STATUS_DIFF" ]; then
	echo $STATUS_DIFF | while read line; do
		PLUGIN_SLUG=`echo $line | awk '{print $2}'`
		PLUGIN_STATUS=`echo $line | awk '{print $1}'`
		if grep -q 'A' <<<$PLUGIN_STATUS; then
			echo "$PLUGIN_SLUG should be active."
			wp plugin activate `echo ${PLUGIN_SLUG}`
		else 
			echo "$PLUGIN_SLUG should not be active."
			wp plugin deactivate ${PLUGIN_SLUG}
		fi
	done
fi

echo 'Flushing rewrite rules...'
wp rewrite flush

echo 'Rebuilding sitemap...'
wp google-sitemap rebuild

echo 'Updating WADL file for console...'
wp wadl update

