#!/bin/bash

source_dir='full_path_source_dir'

dest_dir='full_path_backup_dir'

if [ ! -d $dest_dir ]; then
  mkdir -p $dest_dir
fi

day_of_week=$(date +%u)

if [ $day_of_week -eq 0 ]; then 
    dest_file="$dest_dir/full_backup_$(date +%F).tar.gz"
    tar -zcf $dest_file $source_dir
else    
    dest_file="$dest_dir/inc_backup_$(date +%F).tar.gz" 
       
    last_full_backup=$(find $dest_dir -maxdepth 1 -type f -name 'full_backup_*' | sort -n | tail -n 1)    
    if [ -n "$last_full_backup" ]; then
        tar -g $last_full_backup -zcf $dest_file $source_dir    
    else
      tar -zcf $dest_file $source_dir
    fi
fi

echo "Done"

#To delete files older than 30 days
find $dest_dir/* -mtime +30 -exec rm {} \;



