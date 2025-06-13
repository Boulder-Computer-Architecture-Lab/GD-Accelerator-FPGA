############################################################
## This file is generated automatically by Vitis HLS.
## Please DO NOT edit it.
## Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
## Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
############################################################
open_project hls-proj
set_top loop_uhatfn_Row
open_solution "solution1" -flow_target vivado
set_part {xcvu11p-flga2577-1-e}
create_clock -period 10 -name default
#source "./hls-proj/solution1/directives.tcl"
#csim_design -ldflags {-I /home/drew/projects/spur/CU-Spur-Sean/spurFPGA/CCE-CChunk/library/}
csynth_design
#cosim_design -ldflags {-I /home/drew/projects/spur/CU-Spur-Sean/spurFPGA/CCE-CChunk/library/}
export_design -format ip_catalog
