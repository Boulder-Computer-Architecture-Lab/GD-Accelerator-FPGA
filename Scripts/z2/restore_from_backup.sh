#!/bin/bash

# Local base directory
basedir="$(pwd)"
backup_root="$basedir/../../Board/z2"

# Remote board location
targetdev="xilinx@192.168.2.99"
remotedir="/home/xilinx/mvm-project"

# Find the most recent backup directory
latest_backup=$(ls -dt "$backup_root"/backup_* 2>/dev/null | head -n 1)
if [[ -z "$latest_backup" ]]; then
    echo "No backup directories found in $backup_root"
    exit 1
fi

echo "Restoring from latest backup: $latest_backup"
rsync -avz \
    --exclude="trmult_reduced.bin" \
    --exclude="*.un~" \
    -e ssh "$latest_backup/" "$targetdev:$remotedir/"

ssh "$targetdev" "find '$remotedir' -type f ! \( -name '*.py' -o -name 'dma_transfer' \) -exec chmod -x {} \;"
