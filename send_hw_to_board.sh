#!/bin/bash

# Default design name
design_name="${1:-design_1}"

# Paths and names
targetdev="xilinx@192.168.2.99"
projname="vivado-accelerator"

basedir="/mnt/c/Users/mrflu/Projects"
projdir="$basedir/Vivado/$projname"
targetdir="/home/xilinx/mvm-project/hw"

# Create target directory if not exists
ssh "$targetdev" "mkdir -p '$targetdir'"

# Send .bit file and rename to match .hwh
scp "$projdir/$projname.runs/impl_1/${design_name}_wrapper.bit" \
    "$targetdev:$targetdir/${design_name}.bit"

# Send .hwh file (metadata)
scp "$projdir/$projname.gen/sources_1/bd/$design_name/hw_handoff/${design_name}.hwh" \
    "$targetdev:$targetdir"

# Compile and send .dtbo file
dtc -@ -O dtb -o "$basedir/Board/axi_ram.dtbo" "$basedir/Board/axi_ram.dts"
scp "$basedir/Board/axi_ram.dtbo" "$targetdev:$targetdir"
