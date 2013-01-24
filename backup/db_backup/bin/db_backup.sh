#!/bin/sh

WORKING_PATH=$(cd `dirname ${0}`/..; pwd)
FILES_DIR="$WORKING_PATH/files"
ARCHIVED_DIR="$WORKING_PATH/archived"
S3_BACKUP="$WORKING_PATH/bin/backup_to_s3.rb"

RESERV_DAYS=30
LOG_FILE="$WORKING_PATH/log/db_backup.log"

# System ENV
export PATH=$PATH:$HOME/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin

cd $FILES_DIR
mv $FILES_DIR/*.bz2 $ARCHIVED_DIR
echo "======================================" >>$LOG_FILE
echo "DB backup starting at:"`date +%Y-%m-%d_%H:%M:%S` >>$LOG_FILE

#rake db:dump:all >>$LOG_FILE 2>&1
rake db:dump:black_mode >>$LOG_FILE 2>&1

echo "Send backup files to S3..." >>$LOG_FILE
$S3_BACKUP >>$LOG_FILE

echo "removing old files $RESERV_DAYS days ago..." >>$LOG_FILE
find $ARCHIVED_DIR -mtime +$RESERV_DAYS -exec rm -f {} \;

echo "DB backup finished at:"`date +%Y-%m-%d_%H:%M:%S` >>$LOG_FILE
