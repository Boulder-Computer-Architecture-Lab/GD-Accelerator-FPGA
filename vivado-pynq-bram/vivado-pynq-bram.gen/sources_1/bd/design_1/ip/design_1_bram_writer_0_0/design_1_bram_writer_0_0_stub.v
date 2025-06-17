// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Sat Jun 14 20:22:40 2025
// Host        : drews_laptop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/mrflu/Projects/vivado-pynq-bram/vivado-pynq-bram.gen/sources_1/bd/design_1/ip/design_1_bram_writer_0_0/design_1_bram_writer_0_0_stub.v
// Design      : design_1_bram_writer_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "bram_writer,Vivado 2023.2" *)
module design_1_bram_writer_0_0(clk, rst, addr, din, we, enb)
/* synthesis syn_black_box black_box_pad_pin="rst,addr[10:0],din[31:0],we,enb" */
/* synthesis syn_force_seq_prim="clk" */;
  input clk /* synthesis syn_isclock = 1 */;
  input rst;
  output [10:0]addr;
  output [31:0]din;
  output we;
  output enb;
endmodule
