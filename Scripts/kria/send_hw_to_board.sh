#!/bin/bash

# Default design name
design_name="${1:-design_1}"

# Paths and names
targetdev="ubuntu@192.168.195.196"
projname="kria-accelerator"

basedir="$(pwd)"
projdir="$basedir/../../Vivado/kria/$projname"
boarddir="$basedir/../../Board/kria"
targetdir="/home/ubuntu/mvm-accelerator/hw"

# Create target directory if not exists
ssh "$targetdev" "mkdir -p '$targetdir'"

# Send .bit file and rename to match .hwh
scp "$projdir/$projname.runs/impl_1/${design_name}_wrapper.bit" \
    "$targetdev:$targetdir/${design_name}.bit"

# Send .hwh file (metadata)
scp "$projdir/$projname.gen/sources_1/bd/$design_name/hw_handoff/${design_name}.hwh" \
    "$targetdev:$targetdir"

# Compile and send .dtbo file
dtc -@ -O dtb -o "$boarddir/axi_ram.dtbo" "$boarddir/axi_ram.dts" 2> >(grep -v "Warning")
scp "$boarddir/axi_ram.dtbo" "$targetdev:$targetdir"
