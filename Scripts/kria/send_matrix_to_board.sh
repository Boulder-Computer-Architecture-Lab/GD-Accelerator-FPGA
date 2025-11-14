#!/bin/bash

set -e # Exit immediately on errors

targetdev="ubuntu@192.168.195.196"
basedir="$(pwd)"
matrixpath="$basedir/../../Board/kria/matrix.npy"
targetdir="/home/ubuntu/mvm-accelerator/"
generator="$basedir/generate_random_matrix.py"

# Args
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <NUM_CHANNELS> <ROWS_PER_CHANNEL> <NUM_COLS>"
    exit 1
fi

num_channels="$1"
rows_per_channel="$2"
num_cols="$3"

# Generate matrix
echo "Generating matrix (${num_channels} x ${rows_per_channel} x ${num_cols})..."
python3 "$generator" "$num_channels" "$rows_per_channel" "$num_cols"

# Send file
echo "Transferring matrix to board..."
ssh "$targetdev" "mkdir -p '$targetdir'"
scp "$matrixpath" "$targetdev:$targetdir"

# Cleanup
echo "Cleaning up local matrix file..."
rm -f "$matrixpath"

echo "Done."
