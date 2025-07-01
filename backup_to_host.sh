#!/bin/bash

# Local base directory
basedir="$(pwd)"
backup_root="$basedir/Board"

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

