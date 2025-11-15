#!/bin/bash

# Default impl name
impl_name="${1:-impl_1}"

# Paths and names
targetdev="ubuntu@192.168.195.196"
projname="kria-accelerator"
design_name="design_1"

basedir="$(pwd)"
projdir="$basedir/../../Vivado/kria/build"
boarddir="$basedir/../../Board/kria"
targetdir="/home/ubuntu/mvm-accelerator/hw"

# Create target directory if not exists
ssh "$targetdev" "mkdir -p '$targetdir'"

# Send .bit file and rename to match .hwh
scp "$projdir/$projname.runs/$impl_name/${design_name}_wrapper.bit" \
    "$targetdev:$targetdir/${design_name}.bit"

# Send .hwh file (metadata)
scp "$projdir/$projname.gen/sources_1/bd/$design_name/hw_handoff/${design_name}.hwh" \
    "$targetdev:$targetdir"

