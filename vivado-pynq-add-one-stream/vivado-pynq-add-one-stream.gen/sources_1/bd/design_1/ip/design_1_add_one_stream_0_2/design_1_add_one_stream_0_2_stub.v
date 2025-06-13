// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Mon Jun  9 16:44:47 2025
// Host        : drews_laptop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/mrflu/Projects/vivado-pynq-add-one-stream/vivado-pynq-add-one-stream.gen/sources_1/bd/design_1/ip/design_1_add_one_stream_0_2/design_1_add_one_stream_0_2_stub.v
// Design      : design_1_add_one_stream_0_2
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "add_one_stream_v2_0,Vivado 2023.2" *)
module design_1_add_one_stream_0_2(s00_axis_aclk, s00_axis_aresetn, 
  s00_axis_tdata, s00_axis_tstrb, s00_axis_tvalid, s00_axis_tready, s00_axis_tlast, 
  m00_axis_aclk, m00_axis_aresetn, m00_axis_tdata, m00_axis_tstrb, m00_axis_tvalid, 
  m00_axis_tready, m00_axis_tlast)
/* synthesis syn_black_box black_box_pad_pin="s00_axis_aresetn,s00_axis_tdata[31:0],s00_axis_tstrb[3:0],s00_axis_tvalid,s00_axis_tready,s00_axis_tlast,m00_axis_aresetn,m00_axis_tdata[31:0],m00_axis_tstrb[3:0],m00_axis_tvalid,m00_axis_tready,m00_axis_tlast" */
/* synthesis syn_force_seq_prim="s00_axis_aclk" */
/* synthesis syn_force_seq_prim="m00_axis_aclk" */;
  input s00_axis_aclk /* synthesis syn_isclock = 1 */;
  input s00_axis_aresetn;
  input [31:0]s00_axis_tdata;
  input [3:0]s00_axis_tstrb;
  input s00_axis_tvalid;
  output s00_axis_tready;
  input s00_axis_tlast;
  input m00_axis_aclk /* synthesis syn_isclock = 1 */;
  input m00_axis_aresetn;
  output [31:0]m00_axis_tdata;
  output [3:0]m00_axis_tstrb;
  output m00_axis_tvalid;
  input m00_axis_tready;
  output m00_axis_tlast;
endmodule
