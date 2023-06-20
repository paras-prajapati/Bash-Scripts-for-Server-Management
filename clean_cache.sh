#!/bin/bash

# Specify the directory to clean
directory="/var/cache/*/"

# Check if the directory exists
if [ -d "$directory" ]; then
  # Remove all folders inside the directory
  find "$directory" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;

  echo "All folders inside $directory have been removed."
else
  echo "Directory $directory does not exist."
fi