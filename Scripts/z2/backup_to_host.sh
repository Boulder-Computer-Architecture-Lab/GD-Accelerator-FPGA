#!/bin/bash

# Local base directory
basedir="$(pwd)"
backup_root="$basedir/../../Board/z2"

# Timestamped backup directory
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
destdir="$backup_root/backup_$timestamp"

# Remote board location
targetdev="xilinx@192.168.2.99"
remotedir="/home/xilinx/mvm-project"

# Create destination directory
mkdir -p "$destdir"

# Use rsync to copy all files except the excluded one
rsync -avz \
	--exclude="trmult_reduced.bin" \
	--exclude="*.un~" \
    -e ssh "$targetdev:$remotedir/" "$destdir/"

# Keep only the 2 most recent backups, delete older ones
find "$backup_root" -maxdepth 1 -type d -name 'backup_*' \
  | sort -r \
  | tail -n +3 \
  | xargs -r rm -rf
