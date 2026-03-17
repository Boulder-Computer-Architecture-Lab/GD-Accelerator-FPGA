// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Thu Mar  5 14:24:54 2026
// Host        : drews_laptop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub c:/Users/mrflu/MVM-Accel/Vivado/kria/ip/fp64_cmplt/fp64_cmplt_stub.v
// Design      : fp64_cmplt
// Purpose     : Stub declaration of top-level module interface
// Device      : xck26-sfvc784-2LV-c
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "floating_point_v7_1_16,Vivado 2023.2" *)
module fp64_cmplt(aclk, aresetn, s_axis_a_tvalid, 
  s_axis_a_tready, s_axis_a_tdata, s_axis_b_tvalid, s_axis_b_tready, s_axis_b_tdata, 
  m_axis_result_tvalid, m_axis_result_tready, m_axis_result_tdata)
/* synthesis syn_black_box black_box_pad_pin="aresetn,s_axis_a_tvalid,s_axis_a_tready,s_axis_a_tdata[63:0],s_axis_b_tvalid,s_axis_b_tready,s_axis_b_tdata[63:0],m_axis_result_tvalid,m_axis_result_tready,m_axis_result_tdata[7:0]" */
/* synthesis syn_force_seq_prim="aclk" */;
  input aclk /* synthesis syn_isclock = 1 */;
  input aresetn;
  input s_axis_a_tvalid;
  output s_axis_a_tready;
  input [63:0]s_axis_a_tdata;
  input s_axis_b_tvalid;
  output s_axis_b_tready;
  input [63:0]s_axis_b_tdata;
  output m_axis_result_tvalid;
  input m_axis_result_tready;
  output [7:0]m_axis_result_tdata;
endmodule
