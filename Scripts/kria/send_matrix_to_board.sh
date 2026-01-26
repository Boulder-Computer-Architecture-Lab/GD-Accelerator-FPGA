#!/bin/bash

set -e # Exit immediately on errors

targetdev="ubuntu@192.168.195.196"
basedir="$(pwd)"
targetdir="/home/ubuntu/mvm-accelerator/"
generator="$basedir/generate_random_matrix.py"

# Args
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <NUM_CHANNELS> <ROWS_PER_CHANNEL> <NUM_COLS> <DTYPE>=[fp16|fp32|fp64]"
    exit 1
fi

num_channels="$1"
rows_per_channel="$2"
num_cols="$3"
dtype="$4"

case "$dtype" in
    fp16) matrixfile="matrix16.npy" ;;
    fp32) matrixfile="matrix32.npy" ;;
    fp64) matrixfile="matrix64.npy" ;;
    *)
        echo "Invalid dtype: $dtype (expected fp16, fp32, or fp64)"
        exit 1
        ;;
esac

matrixpath="$basedir/../../Board/kria/$matrixfile"

# Generate matrix
echo "Generating matrix (${num_channels} x ${rows_per_channel} x ${num_cols}), dtype=${dtype}..."
python3 "$generator" "$num_channels" "$rows_per_channel" "$num_cols" --dtype "$dtype"

# Send file
echo "Transferring matrix to board..."
ssh "$targetdev" "mkdir -p '$targetdir'"
scp "$matrixpath" "$targetdev:$targetdir"

# Cleanup
echo "Cleaning up local matrix file..."
rm -f "$matrixpath"

echo "Done."
