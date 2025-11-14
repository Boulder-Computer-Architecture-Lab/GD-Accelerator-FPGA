#!/bin/bash
set -euo pipefail

# Local base directory
basedir="$(pwd)"
backup_root="$basedir/../../Board/kria"

# Timestamped backup directory
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
destdir="$backup_root/backup_$timestamp"

# Remote board location
targetdev="ubuntu@192.168.195.196"
remotedir="/home/ubuntu/mvm-accelerator"
notebookdir="/root/jupyter_notebooks/mvm-accelerator"

# Create destination directory
mkdir -p "$destdir"

# Use rsync to get all files (except matrix)
rsync -avz \
	--exclude="matrix.npy" \
	--exclude="trmult_reduced.bin" \
	--exclude="trmult_reduced16.bin" \
	--exclude="trmult_reduced64.bin" \
	--exclude="*.un~" \
    -e ssh \
    "$targetdev:$remotedir/" \
    "$destdir/"

# Get root owned notebook
#ssh -t "$targetdev" \
#  "sudo tar -C '$notebookdir' -cf - ." \
#| tar -C "$destdir/notebooks" -xpf -

# Keep only the 2 most recent backups, delete older ones
find "$backup_root" -maxdepth 1 -type d -name 'backup_*' \
  | sort -r \
  | tail -n +3 \
  | xargs -r rm -rf
