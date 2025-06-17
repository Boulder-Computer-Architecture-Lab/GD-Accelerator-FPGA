// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Mon Jun 16 10:38:42 2025
// Host        : drews_laptop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top design_1_auto_pc_1 -prefix
//               design_1_auto_pc_1_ design_1_auto_pc_1_sim_netlist.v
// Design      : design_1_auto_pc_1
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_auto_pc_1_axi_data_fifo_v2_1_28_axic_fifo
   (dout,
    empty,
    SR,
    aresetn_0,
    m_axi_awvalid,
    length_counter_1_reg_1_sp_1,
    empty_fwft_i_reg,
    m_axi_wvalid,
    S_AXI_AREADY_I_reg,
    \areset_d_reg[1] ,
    aclk,
    m_axi_awlen,
    rd_en,
    aresetn,
    m_axi_awvalid_0,
    command_ongoing,
    m_axi_awready,
    length_counter_1_reg,
    first_mi_word,
    s_axi_wvalid,
    m_axi_wready,
    E,
    s_axi_awvalid,
    Q);
  output [3:0]dout;
  output empty;
  output [0:0]SR;
  output aresetn_0;
  output m_axi_awvalid;
  output length_counter_1_reg_1_sp_1;
  output empty_fwft_i_reg;
  output m_axi_wvalid;
  output S_AXI_AREADY_I_reg;
  output \areset_d_reg[1] ;
  input aclk;
  input [3:0]m_axi_awlen;
  input rd_en;
  input aresetn;
  input m_axi_awvalid_0;
  input command_ongoing;
  input m_axi_awready;
  input [1:0]length_counter_1_reg;
  input first_mi_word;
  input s_axi_wvalid;
  input m_axi_wready;
  input [0:0]E;
  input s_axi_awvalid;
  input [1:0]Q;

  wire [0:0]E;
  wire [1:0]Q;
  wire [0:0]SR;
  wire S_AXI_AREADY_I_reg;
  wire aclk;
  wire \areset_d_reg[1] ;
  wire aresetn;
  wire aresetn_0;
  wire command_ongoing;
  wire [3:0]dout;
  wire empty;
  wire empty_fwft_i_reg;
  wire first_mi_word;
  wire [1:0]length_counter_1_reg;
  wire length_counter_1_reg_1_sn_1;
  wire [3:0]m_axi_awlen;
  wire m_axi_awready;
  wire m_axi_awvalid;
  wire m_axi_awvalid_0;
  wire m_axi_wready;
  wire m_axi_wvalid;
  wire rd_en;
  wire s_axi_awvalid;
  wire s_axi_wvalid;

  assign length_counter_1_reg_1_sp_1 = length_counter_1_reg_1_sn_1;
  design_1_auto_pc_1_axi_data_fifo_v2_1_28_fifo_gen inst
       (.E(E),
        .Q(Q),
        .SR(SR),
        .S_AXI_AREADY_I_reg(S_AXI_AREADY_I_reg),
        .aclk(aclk),
        .\areset_d_reg[1] (\areset_d_reg[1] ),
        .aresetn(aresetn),
        .aresetn_0(aresetn_0),
        .command_ongoing(command_ongoing),
        .dout(dout),
        .empty(empty),
        .empty_fwft_i_reg(empty_fwft_i_reg),
        .first_mi_word(first_mi_word),
        .length_counter_1_reg(length_counter_1_reg),
        .length_counter_1_reg_1_sp_1(length_counter_1_reg_1_sn_1),
        .m_axi_awlen(m_axi_awlen),
        .m_axi_awready(m_axi_awready),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_awvalid_0(m_axi_awvalid_0),
        .m_axi_wready(m_axi_wready),
        .m_axi_wvalid(m_axi_wvalid),
        .rd_en(rd_en),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_wvalid(s_axi_wvalid));
endmodule

module design_1_auto_pc_1_axi_data_fifo_v2_1_28_fifo_gen
   (dout,
    empty,
    SR,
    aresetn_0,
    m_axi_awvalid,
    length_counter_1_reg_1_sp_1,
    empty_fwft_i_reg,
    m_axi_wvalid,
    S_AXI_AREADY_I_reg,
    \areset_d_reg[1] ,
    aclk,
    m_axi_awlen,
    rd_en,
    aresetn,
    m_axi_awvalid_0,
    command_ongoing,
    m_axi_awready,
    length_counter_1_reg,
    first_mi_word,
    s_axi_wvalid,
    m_axi_wready,
    E,
    s_axi_awvalid,
    Q);
  output [3:0]dout;
  output empty;
  output [0:0]SR;
  output aresetn_0;
  output m_axi_awvalid;
  output length_counter_1_reg_1_sp_1;
  output empty_fwft_i_reg;
  output m_axi_wvalid;
  output S_AXI_AREADY_I_reg;
  output \areset_d_reg[1] ;
  input aclk;
  input [3:0]m_axi_awlen;
  input rd_en;
  input aresetn;
  input m_axi_awvalid_0;
  input command_ongoing;
  input m_axi_awready;
  input [1:0]length_counter_1_reg;
  input first_mi_word;
  input s_axi_wvalid;
  input m_axi_wready;
  input [0:0]E;
  input s_axi_awvalid;
  input [1:0]Q;

  wire [0:0]E;
  wire [1:0]Q;
  wire [0:0]SR;
  wire S_AXI_AREADY_I_i_3_n_0;
  wire S_AXI_AREADY_I_reg;
  wire aclk;
  wire \areset_d_reg[1] ;
  wire aresetn;
  wire aresetn_0;
  wire cmd_push;
  wire command_ongoing;
  wire command_ongoing_i_2_n_0;
  wire [3:0]dout;
  wire empty;
  wire empty_fwft_i_reg;
  wire first_mi_word;
  wire full;
  wire [1:0]length_counter_1_reg;
  wire length_counter_1_reg_1_sn_1;
  wire [3:0]m_axi_awlen;
  wire m_axi_awready;
  wire m_axi_awvalid;
  wire m_axi_awvalid_0;
  wire m_axi_wready;
  wire m_axi_wvalid;
  wire rd_en;
  wire s_axi_awvalid;
  wire s_axi_wvalid;
  wire NLW_fifo_gen_inst_almost_empty_UNCONNECTED;
  wire NLW_fifo_gen_inst_almost_full_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_ar_dbiterr_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_ar_overflow_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_ar_prog_empty_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_ar_prog_full_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_ar_sbiterr_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_ar_underflow_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_aw_dbiterr_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_aw_overflow_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_aw_prog_empty_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_aw_prog_full_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_aw_sbiterr_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_aw_underflow_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_b_dbiterr_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_b_overflow_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_b_prog_empty_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_b_prog_full_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_b_sbiterr_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_b_underflow_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_r_dbiterr_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_r_overflow_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_r_prog_empty_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_r_prog_full_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_r_sbiterr_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_r_underflow_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_w_dbiterr_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_w_overflow_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_w_prog_empty_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_w_prog_full_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_w_sbiterr_UNCONNECTED;
  wire NLW_fifo_gen_inst_axi_w_underflow_UNCONNECTED;
  wire NLW_fifo_gen_inst_axis_dbiterr_UNCONNECTED;
  wire NLW_fifo_gen_inst_axis_overflow_UNCONNECTED;
  wire NLW_fifo_gen_inst_axis_prog_empty_UNCONNECTED;
  wire NLW_fifo_gen_inst_axis_prog_full_UNCONNECTED;
  wire NLW_fifo_gen_inst_axis_sbiterr_UNCONNECTED;
  wire NLW_fifo_gen_inst_axis_underflow_UNCONNECTED;
  wire NLW_fifo_gen_inst_dbiterr_UNCONNECTED;
  wire NLW_fifo_gen_inst_m_axi_arvalid_UNCONNECTED;
  wire NLW_fifo_gen_inst_m_axi_awvalid_UNCONNECTED;
  wire NLW_fifo_gen_inst_m_axi_bready_UNCONNECTED;
  wire NLW_fifo_gen_inst_m_axi_rready_UNCONNECTED;
  wire NLW_fifo_gen_inst_m_axi_wlast_UNCONNECTED;
  wire NLW_fifo_gen_inst_m_axi_wvalid_UNCONNECTED;
  wire NLW_fifo_gen_inst_m_axis_tlast_UNCONNECTED;
  wire NLW_fifo_gen_inst_m_axis_tvalid_UNCONNECTED;
  wire NLW_fifo_gen_inst_overflow_UNCONNECTED;
  wire NLW_fifo_gen_inst_prog_empty_UNCONNECTED;
  wire NLW_fifo_gen_inst_prog_full_UNCONNECTED;
  wire NLW_fifo_gen_inst_rd_rst_busy_UNCONNECTED;
  wire NLW_fifo_gen_inst_s_axi_arready_UNCONNECTED;
  wire NLW_fifo_gen_inst_s_axi_awready_UNCONNECTED;
  wire NLW_fifo_gen_inst_s_axi_bvalid_UNCONNECTED;
  wire NLW_fifo_gen_inst_s_axi_rlast_UNCONNECTED;
  wire NLW_fifo_gen_inst_s_axi_rvalid_UNCONNECTED;
  wire NLW_fifo_gen_inst_s_axi_wready_UNCONNECTED;
  wire NLW_fifo_gen_inst_s_axis_tready_UNCONNECTED;
  wire NLW_fifo_gen_inst_sbiterr_UNCONNECTED;
  wire NLW_fifo_gen_inst_underflow_UNCONNECTED;
  wire NLW_fifo_gen_inst_valid_UNCONNECTED;
  wire NLW_fifo_gen_inst_wr_ack_UNCONNECTED;
  wire NLW_fifo_gen_inst_wr_rst_busy_UNCONNECTED;
  wire [4:0]NLW_fifo_gen_inst_axi_ar_data_count_UNCONNECTED;
  wire [4:0]NLW_fifo_gen_inst_axi_ar_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_fifo_gen_inst_axi_ar_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_fifo_gen_inst_axi_aw_data_count_UNCONNECTED;
  wire [4:0]NLW_fifo_gen_inst_axi_aw_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_fifo_gen_inst_axi_aw_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_fifo_gen_inst_axi_b_data_count_UNCONNECTED;
  wire [4:0]NLW_fifo_gen_inst_axi_b_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_fifo_gen_inst_axi_b_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_fifo_gen_inst_axi_r_data_count_UNCONNECTED;
  wire [10:0]NLW_fifo_gen_inst_axi_r_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_fifo_gen_inst_axi_r_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_fifo_gen_inst_axi_w_data_count_UNCONNECTED;
  wire [10:0]NLW_fifo_gen_inst_axi_w_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_fifo_gen_inst_axi_w_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_fifo_gen_inst_axis_data_count_UNCONNECTED;
  wire [10:0]NLW_fifo_gen_inst_axis_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_fifo_gen_inst_axis_wr_data_count_UNCONNECTED;
  wire [5:0]NLW_fifo_gen_inst_data_count_UNCONNECTED;
  wire [4:4]NLW_fifo_gen_inst_dout_UNCONNECTED;
  wire [31:0]NLW_fifo_gen_inst_m_axi_araddr_UNCONNECTED;
  wire [1:0]NLW_fifo_gen_inst_m_axi_arburst_UNCONNECTED;
  wire [3:0]NLW_fifo_gen_inst_m_axi_arcache_UNCONNECTED;
  wire [3:0]NLW_fifo_gen_inst_m_axi_arid_UNCONNECTED;
  wire [7:0]NLW_fifo_gen_inst_m_axi_arlen_UNCONNECTED;
  wire [1:0]NLW_fifo_gen_inst_m_axi_arlock_UNCONNECTED;
  wire [2:0]NLW_fifo_gen_inst_m_axi_arprot_UNCONNECTED;
  wire [3:0]NLW_fifo_gen_inst_m_axi_arqos_UNCONNECTED;
  wire [3:0]NLW_fifo_gen_inst_m_axi_arregion_UNCONNECTED;
  wire [2:0]NLW_fifo_gen_inst_m_axi_arsize_UNCONNECTED;
  wire [0:0]NLW_fifo_gen_inst_m_axi_aruser_UNCONNECTED;
  wire [31:0]NLW_fifo_gen_inst_m_axi_awaddr_UNCONNECTED;
  wire [1:0]NLW_fifo_gen_inst_m_axi_awburst_UNCONNECTED;
  wire [3:0]NLW_fifo_gen_inst_m_axi_awcache_UNCONNECTED;
  wire [3:0]NLW_fifo_gen_inst_m_axi_awid_UNCONNECTED;
  wire [7:0]NLW_fifo_gen_inst_m_axi_awlen_UNCONNECTED;
  wire [1:0]NLW_fifo_gen_inst_m_axi_awlock_UNCONNECTED;
  wire [2:0]NLW_fifo_gen_inst_m_axi_awprot_UNCONNECTED;
  wire [3:0]NLW_fifo_gen_inst_m_axi_awqos_UNCONNECTED;
  wire [3:0]NLW_fifo_gen_inst_m_axi_awregion_UNCONNECTED;
  wire [2:0]NLW_fifo_gen_inst_m_axi_awsize_UNCONNECTED;
  wire [0:0]NLW_fifo_gen_inst_m_axi_awuser_UNCONNECTED;
  wire [63:0]NLW_fifo_gen_inst_m_axi_wdata_UNCONNECTED;
  wire [3:0]NLW_fifo_gen_inst_m_axi_wid_UNCONNECTED;
  wire [7:0]NLW_fifo_gen_inst_m_axi_wstrb_UNCONNECTED;
  wire [0:0]NLW_fifo_gen_inst_m_axi_wuser_UNCONNECTED;
  wire [63:0]NLW_fifo_gen_inst_m_axis_tdata_UNCONNECTED;
  wire [3:0]NLW_fifo_gen_inst_m_axis_tdest_UNCONNECTED;
  wire [7:0]NLW_fifo_gen_inst_m_axis_tid_UNCONNECTED;
  wire [3:0]NLW_fifo_gen_inst_m_axis_tkeep_UNCONNECTED;
  wire [3:0]NLW_fifo_gen_inst_m_axis_tstrb_UNCONNECTED;
  wire [3:0]NLW_fifo_gen_inst_m_axis_tuser_UNCONNECTED;
  wire [5:0]NLW_fifo_gen_inst_rd_data_count_UNCONNECTED;
  wire [3:0]NLW_fifo_gen_inst_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_fifo_gen_inst_s_axi_bresp_UNCONNECTED;
  wire [0:0]NLW_fifo_gen_inst_s_axi_buser_UNCONNECTED;
  wire [63:0]NLW_fifo_gen_inst_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_fifo_gen_inst_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_fifo_gen_inst_s_axi_rresp_UNCONNECTED;
  wire [0:0]NLW_fifo_gen_inst_s_axi_ruser_UNCONNECTED;
  wire [5:0]NLW_fifo_gen_inst_wr_data_count_UNCONNECTED;

  assign length_counter_1_reg_1_sp_1 = length_counter_1_reg_1_sn_1;
  LUT1 #(
    .INIT(2'h1)) 
    S_AXI_AREADY_I_i_1
       (.I0(aresetn),
        .O(SR));
  LUT6 #(
    .INIT(64'h22722272FFFF2272)) 
    S_AXI_AREADY_I_i_2
       (.I0(E),
        .I1(s_axi_awvalid),
        .I2(m_axi_awready),
        .I3(S_AXI_AREADY_I_i_3_n_0),
        .I4(Q[1]),
        .I5(Q[0]),
        .O(S_AXI_AREADY_I_reg));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'h4F)) 
    S_AXI_AREADY_I_i_3
       (.I0(m_axi_awvalid_0),
        .I1(full),
        .I2(command_ongoing),
        .O(S_AXI_AREADY_I_i_3_n_0));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT5 #(
    .INIT(32'h00888A88)) 
    cmd_push_block_i_1
       (.I0(aresetn),
        .I1(m_axi_awvalid_0),
        .I2(full),
        .I3(command_ongoing),
        .I4(m_axi_awready),
        .O(aresetn_0));
  LUT6 #(
    .INIT(64'hF222FFFFD000D000)) 
    command_ongoing_i_1
       (.I0(Q[1]),
        .I1(Q[0]),
        .I2(E),
        .I3(s_axi_awvalid),
        .I4(command_ongoing_i_2_n_0),
        .I5(command_ongoing),
        .O(\areset_d_reg[1] ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'h8808)) 
    command_ongoing_i_2
       (.I0(m_axi_awready),
        .I1(command_ongoing),
        .I2(full),
        .I3(m_axi_awvalid_0),
        .O(command_ongoing_i_2_n_0));
  (* C_ADD_NGC_CONSTRAINT = "0" *) 
  (* C_APPLICATION_TYPE_AXIS = "0" *) 
  (* C_APPLICATION_TYPE_RACH = "0" *) 
  (* C_APPLICATION_TYPE_RDCH = "0" *) 
  (* C_APPLICATION_TYPE_WACH = "0" *) 
  (* C_APPLICATION_TYPE_WDCH = "0" *) 
  (* C_APPLICATION_TYPE_WRCH = "0" *) 
  (* C_AXIS_TDATA_WIDTH = "64" *) 
  (* C_AXIS_TDEST_WIDTH = "4" *) 
  (* C_AXIS_TID_WIDTH = "8" *) 
  (* C_AXIS_TKEEP_WIDTH = "4" *) 
  (* C_AXIS_TSTRB_WIDTH = "4" *) 
  (* C_AXIS_TUSER_WIDTH = "4" *) 
  (* C_AXIS_TYPE = "0" *) 
  (* C_AXI_ADDR_WIDTH = "32" *) 
  (* C_AXI_ARUSER_WIDTH = "1" *) 
  (* C_AXI_AWUSER_WIDTH = "1" *) 
  (* C_AXI_BUSER_WIDTH = "1" *) 
  (* C_AXI_DATA_WIDTH = "64" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_LEN_WIDTH = "8" *) 
  (* C_AXI_LOCK_WIDTH = "2" *) 
  (* C_AXI_RUSER_WIDTH = "1" *) 
  (* C_AXI_TYPE = "0" *) 
  (* C_AXI_WUSER_WIDTH = "1" *) 
  (* C_COMMON_CLOCK = "1" *) 
  (* C_COUNT_TYPE = "0" *) 
  (* C_DATA_COUNT_WIDTH = "6" *) 
  (* C_DEFAULT_VALUE = "BlankString" *) 
  (* C_DIN_WIDTH = "5" *) 
  (* C_DIN_WIDTH_AXIS = "1" *) 
  (* C_DIN_WIDTH_RACH = "32" *) 
  (* C_DIN_WIDTH_RDCH = "64" *) 
  (* C_DIN_WIDTH_WACH = "32" *) 
  (* C_DIN_WIDTH_WDCH = "64" *) 
  (* C_DIN_WIDTH_WRCH = "2" *) 
  (* C_DOUT_RST_VAL = "0" *) 
  (* C_DOUT_WIDTH = "5" *) 
  (* C_ENABLE_RLOCS = "0" *) 
  (* C_ENABLE_RST_SYNC = "1" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_ERROR_INJECTION_TYPE = "0" *) 
  (* C_ERROR_INJECTION_TYPE_AXIS = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WRCH = "0" *) 
  (* C_FAMILY = "zynq" *) 
  (* C_FULL_FLAGS_RST_VAL = "0" *) 
  (* C_HAS_ALMOST_EMPTY = "0" *) 
  (* C_HAS_ALMOST_FULL = "0" *) 
  (* C_HAS_AXIS_TDATA = "0" *) 
  (* C_HAS_AXIS_TDEST = "0" *) 
  (* C_HAS_AXIS_TID = "0" *) 
  (* C_HAS_AXIS_TKEEP = "0" *) 
  (* C_HAS_AXIS_TLAST = "0" *) 
  (* C_HAS_AXIS_TREADY = "1" *) 
  (* C_HAS_AXIS_TSTRB = "0" *) 
  (* C_HAS_AXIS_TUSER = "0" *) 
  (* C_HAS_AXI_ARUSER = "0" *) 
  (* C_HAS_AXI_AWUSER = "0" *) 
  (* C_HAS_AXI_BUSER = "0" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_AXI_RD_CHANNEL = "0" *) 
  (* C_HAS_AXI_RUSER = "0" *) 
  (* C_HAS_AXI_WR_CHANNEL = "0" *) 
  (* C_HAS_AXI_WUSER = "0" *) 
  (* C_HAS_BACKUP = "0" *) 
  (* C_HAS_DATA_COUNT = "0" *) 
  (* C_HAS_DATA_COUNTS_AXIS = "0" *) 
  (* C_HAS_DATA_COUNTS_RACH = "0" *) 
  (* C_HAS_DATA_COUNTS_RDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WACH = "0" *) 
  (* C_HAS_DATA_COUNTS_WDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WRCH = "0" *) 
  (* C_HAS_INT_CLK = "0" *) 
  (* C_HAS_MASTER_CE = "0" *) 
  (* C_HAS_MEMINIT_FILE = "0" *) 
  (* C_HAS_OVERFLOW = "0" *) 
  (* C_HAS_PROG_FLAGS_AXIS = "0" *) 
  (* C_HAS_PROG_FLAGS_RACH = "0" *) 
  (* C_HAS_PROG_FLAGS_RDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WACH = "0" *) 
  (* C_HAS_PROG_FLAGS_WDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WRCH = "0" *) 
  (* C_HAS_RD_DATA_COUNT = "0" *) 
  (* C_HAS_RD_RST = "0" *) 
  (* C_HAS_RST = "1" *) 
  (* C_HAS_SLAVE_CE = "0" *) 
  (* C_HAS_SRST = "0" *) 
  (* C_HAS_UNDERFLOW = "0" *) 
  (* C_HAS_VALID = "0" *) 
  (* C_HAS_WR_ACK = "0" *) 
  (* C_HAS_WR_DATA_COUNT = "0" *) 
  (* C_HAS_WR_RST = "0" *) 
  (* C_IMPLEMENTATION_TYPE = "0" *) 
  (* C_IMPLEMENTATION_TYPE_AXIS = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RACH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WACH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WRCH = "1" *) 
  (* C_INIT_WR_PNTR_VAL = "0" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_MEMORY_TYPE = "2" *) 
  (* C_MIF_FILE_NAME = "BlankString" *) 
  (* C_MSGON_VAL = "1" *) 
  (* C_OPTIMIZATION_MODE = "0" *) 
  (* C_OVERFLOW_LOW = "0" *) 
  (* C_POWER_SAVING_MODE = "0" *) 
  (* C_PRELOAD_LATENCY = "0" *) 
  (* C_PRELOAD_REGS = "1" *) 
  (* C_PRIM_FIFO_TYPE = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_AXIS = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_RACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_RDCH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_WACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_WDCH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_WRCH = "512x36" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL = "4" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_NEGATE_VAL = "5" *) 
  (* C_PROG_EMPTY_TYPE = "0" *) 
  (* C_PROG_EMPTY_TYPE_AXIS = "0" *) 
  (* C_PROG_EMPTY_TYPE_RACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_RDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WRCH = "0" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL = "31" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_AXIS = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WRCH = "1023" *) 
  (* C_PROG_FULL_THRESH_NEGATE_VAL = "30" *) 
  (* C_PROG_FULL_TYPE = "0" *) 
  (* C_PROG_FULL_TYPE_AXIS = "0" *) 
  (* C_PROG_FULL_TYPE_RACH = "0" *) 
  (* C_PROG_FULL_TYPE_RDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WACH = "0" *) 
  (* C_PROG_FULL_TYPE_WDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WRCH = "0" *) 
  (* C_RACH_TYPE = "0" *) 
  (* C_RDCH_TYPE = "0" *) 
  (* C_RD_DATA_COUNT_WIDTH = "6" *) 
  (* C_RD_DEPTH = "32" *) 
  (* C_RD_FREQ = "1" *) 
  (* C_RD_PNTR_WIDTH = "5" *) 
  (* C_REG_SLICE_MODE_AXIS = "0" *) 
  (* C_REG_SLICE_MODE_RACH = "0" *) 
  (* C_REG_SLICE_MODE_RDCH = "0" *) 
  (* C_REG_SLICE_MODE_WACH = "0" *) 
  (* C_REG_SLICE_MODE_WDCH = "0" *) 
  (* C_REG_SLICE_MODE_WRCH = "0" *) 
  (* C_SELECT_XPM = "0" *) 
  (* C_SYNCHRONIZER_STAGE = "3" *) 
  (* C_UNDERFLOW_LOW = "0" *) 
  (* C_USE_COMMON_OVERFLOW = "0" *) 
  (* C_USE_COMMON_UNDERFLOW = "0" *) 
  (* C_USE_DEFAULT_SETTINGS = "0" *) 
  (* C_USE_DOUT_RST = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_ECC_AXIS = "0" *) 
  (* C_USE_ECC_RACH = "0" *) 
  (* C_USE_ECC_RDCH = "0" *) 
  (* C_USE_ECC_WACH = "0" *) 
  (* C_USE_ECC_WDCH = "0" *) 
  (* C_USE_ECC_WRCH = "0" *) 
  (* C_USE_EMBEDDED_REG = "0" *) 
  (* C_USE_FIFO16_FLAGS = "0" *) 
  (* C_USE_FWFT_DATA_COUNT = "1" *) 
  (* C_USE_PIPELINE_REG = "0" *) 
  (* C_VALID_LOW = "0" *) 
  (* C_WACH_TYPE = "0" *) 
  (* C_WDCH_TYPE = "0" *) 
  (* C_WRCH_TYPE = "0" *) 
  (* C_WR_ACK_LOW = "0" *) 
  (* C_WR_DATA_COUNT_WIDTH = "6" *) 
  (* C_WR_DEPTH = "32" *) 
  (* C_WR_DEPTH_AXIS = "1024" *) 
  (* C_WR_DEPTH_RACH = "16" *) 
  (* C_WR_DEPTH_RDCH = "1024" *) 
  (* C_WR_DEPTH_WACH = "16" *) 
  (* C_WR_DEPTH_WDCH = "1024" *) 
  (* C_WR_DEPTH_WRCH = "16" *) 
  (* C_WR_FREQ = "1" *) 
  (* C_WR_PNTR_WIDTH = "5" *) 
  (* C_WR_PNTR_WIDTH_AXIS = "10" *) 
  (* C_WR_PNTR_WIDTH_RACH = "4" *) 
  (* C_WR_PNTR_WIDTH_RDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WACH = "4" *) 
  (* C_WR_PNTR_WIDTH_WDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WRCH = "4" *) 
  (* C_WR_RESPONSE_LATENCY = "1" *) 
  (* KEEP_HIERARCHY = "soft" *) 
  (* is_du_within_envelope = "true" *) 
  design_1_auto_pc_1_fifo_generator_v13_2_9 fifo_gen_inst
       (.almost_empty(NLW_fifo_gen_inst_almost_empty_UNCONNECTED),
        .almost_full(NLW_fifo_gen_inst_almost_full_UNCONNECTED),
        .axi_ar_data_count(NLW_fifo_gen_inst_axi_ar_data_count_UNCONNECTED[4:0]),
        .axi_ar_dbiterr(NLW_fifo_gen_inst_axi_ar_dbiterr_UNCONNECTED),
        .axi_ar_injectdbiterr(1'b0),
        .axi_ar_injectsbiterr(1'b0),
        .axi_ar_overflow(NLW_fifo_gen_inst_axi_ar_overflow_UNCONNECTED),
        .axi_ar_prog_empty(NLW_fifo_gen_inst_axi_ar_prog_empty_UNCONNECTED),
        .axi_ar_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_prog_full(NLW_fifo_gen_inst_axi_ar_prog_full_UNCONNECTED),
        .axi_ar_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_rd_data_count(NLW_fifo_gen_inst_axi_ar_rd_data_count_UNCONNECTED[4:0]),
        .axi_ar_sbiterr(NLW_fifo_gen_inst_axi_ar_sbiterr_UNCONNECTED),
        .axi_ar_underflow(NLW_fifo_gen_inst_axi_ar_underflow_UNCONNECTED),
        .axi_ar_wr_data_count(NLW_fifo_gen_inst_axi_ar_wr_data_count_UNCONNECTED[4:0]),
        .axi_aw_data_count(NLW_fifo_gen_inst_axi_aw_data_count_UNCONNECTED[4:0]),
        .axi_aw_dbiterr(NLW_fifo_gen_inst_axi_aw_dbiterr_UNCONNECTED),
        .axi_aw_injectdbiterr(1'b0),
        .axi_aw_injectsbiterr(1'b0),
        .axi_aw_overflow(NLW_fifo_gen_inst_axi_aw_overflow_UNCONNECTED),
        .axi_aw_prog_empty(NLW_fifo_gen_inst_axi_aw_prog_empty_UNCONNECTED),
        .axi_aw_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_prog_full(NLW_fifo_gen_inst_axi_aw_prog_full_UNCONNECTED),
        .axi_aw_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_rd_data_count(NLW_fifo_gen_inst_axi_aw_rd_data_count_UNCONNECTED[4:0]),
        .axi_aw_sbiterr(NLW_fifo_gen_inst_axi_aw_sbiterr_UNCONNECTED),
        .axi_aw_underflow(NLW_fifo_gen_inst_axi_aw_underflow_UNCONNECTED),
        .axi_aw_wr_data_count(NLW_fifo_gen_inst_axi_aw_wr_data_count_UNCONNECTED[4:0]),
        .axi_b_data_count(NLW_fifo_gen_inst_axi_b_data_count_UNCONNECTED[4:0]),
        .axi_b_dbiterr(NLW_fifo_gen_inst_axi_b_dbiterr_UNCONNECTED),
        .axi_b_injectdbiterr(1'b0),
        .axi_b_injectsbiterr(1'b0),
        .axi_b_overflow(NLW_fifo_gen_inst_axi_b_overflow_UNCONNECTED),
        .axi_b_prog_empty(NLW_fifo_gen_inst_axi_b_prog_empty_UNCONNECTED),
        .axi_b_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_prog_full(NLW_fifo_gen_inst_axi_b_prog_full_UNCONNECTED),
        .axi_b_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_rd_data_count(NLW_fifo_gen_inst_axi_b_rd_data_count_UNCONNECTED[4:0]),
        .axi_b_sbiterr(NLW_fifo_gen_inst_axi_b_sbiterr_UNCONNECTED),
        .axi_b_underflow(NLW_fifo_gen_inst_axi_b_underflow_UNCONNECTED),
        .axi_b_wr_data_count(NLW_fifo_gen_inst_axi_b_wr_data_count_UNCONNECTED[4:0]),
        .axi_r_data_count(NLW_fifo_gen_inst_axi_r_data_count_UNCONNECTED[10:0]),
        .axi_r_dbiterr(NLW_fifo_gen_inst_axi_r_dbiterr_UNCONNECTED),
        .axi_r_injectdbiterr(1'b0),
        .axi_r_injectsbiterr(1'b0),
        .axi_r_overflow(NLW_fifo_gen_inst_axi_r_overflow_UNCONNECTED),
        .axi_r_prog_empty(NLW_fifo_gen_inst_axi_r_prog_empty_UNCONNECTED),
        .axi_r_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_prog_full(NLW_fifo_gen_inst_axi_r_prog_full_UNCONNECTED),
        .axi_r_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_rd_data_count(NLW_fifo_gen_inst_axi_r_rd_data_count_UNCONNECTED[10:0]),
        .axi_r_sbiterr(NLW_fifo_gen_inst_axi_r_sbiterr_UNCONNECTED),
        .axi_r_underflow(NLW_fifo_gen_inst_axi_r_underflow_UNCONNECTED),
        .axi_r_wr_data_count(NLW_fifo_gen_inst_axi_r_wr_data_count_UNCONNECTED[10:0]),
        .axi_w_data_count(NLW_fifo_gen_inst_axi_w_data_count_UNCONNECTED[10:0]),
        .axi_w_dbiterr(NLW_fifo_gen_inst_axi_w_dbiterr_UNCONNECTED),
        .axi_w_injectdbiterr(1'b0),
        .axi_w_injectsbiterr(1'b0),
        .axi_w_overflow(NLW_fifo_gen_inst_axi_w_overflow_UNCONNECTED),
        .axi_w_prog_empty(NLW_fifo_gen_inst_axi_w_prog_empty_UNCONNECTED),
        .axi_w_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_prog_full(NLW_fifo_gen_inst_axi_w_prog_full_UNCONNECTED),
        .axi_w_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_rd_data_count(NLW_fifo_gen_inst_axi_w_rd_data_count_UNCONNECTED[10:0]),
        .axi_w_sbiterr(NLW_fifo_gen_inst_axi_w_sbiterr_UNCONNECTED),
        .axi_w_underflow(NLW_fifo_gen_inst_axi_w_underflow_UNCONNECTED),
        .axi_w_wr_data_count(NLW_fifo_gen_inst_axi_w_wr_data_count_UNCONNECTED[10:0]),
        .axis_data_count(NLW_fifo_gen_inst_axis_data_count_UNCONNECTED[10:0]),
        .axis_dbiterr(NLW_fifo_gen_inst_axis_dbiterr_UNCONNECTED),
        .axis_injectdbiterr(1'b0),
        .axis_injectsbiterr(1'b0),
        .axis_overflow(NLW_fifo_gen_inst_axis_overflow_UNCONNECTED),
        .axis_prog_empty(NLW_fifo_gen_inst_axis_prog_empty_UNCONNECTED),
        .axis_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_prog_full(NLW_fifo_gen_inst_axis_prog_full_UNCONNECTED),
        .axis_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_rd_data_count(NLW_fifo_gen_inst_axis_rd_data_count_UNCONNECTED[10:0]),
        .axis_sbiterr(NLW_fifo_gen_inst_axis_sbiterr_UNCONNECTED),
        .axis_underflow(NLW_fifo_gen_inst_axis_underflow_UNCONNECTED),
        .axis_wr_data_count(NLW_fifo_gen_inst_axis_wr_data_count_UNCONNECTED[10:0]),
        .backup(1'b0),
        .backup_marker(1'b0),
        .clk(aclk),
        .data_count(NLW_fifo_gen_inst_data_count_UNCONNECTED[5:0]),
        .dbiterr(NLW_fifo_gen_inst_dbiterr_UNCONNECTED),
        .din({1'b0,m_axi_awlen}),
        .dout({NLW_fifo_gen_inst_dout_UNCONNECTED[4],dout}),
        .empty(empty),
        .full(full),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .int_clk(1'b0),
        .m_aclk(1'b0),
        .m_aclk_en(1'b0),
        .m_axi_araddr(NLW_fifo_gen_inst_m_axi_araddr_UNCONNECTED[31:0]),
        .m_axi_arburst(NLW_fifo_gen_inst_m_axi_arburst_UNCONNECTED[1:0]),
        .m_axi_arcache(NLW_fifo_gen_inst_m_axi_arcache_UNCONNECTED[3:0]),
        .m_axi_arid(NLW_fifo_gen_inst_m_axi_arid_UNCONNECTED[3:0]),
        .m_axi_arlen(NLW_fifo_gen_inst_m_axi_arlen_UNCONNECTED[7:0]),
        .m_axi_arlock(NLW_fifo_gen_inst_m_axi_arlock_UNCONNECTED[1:0]),
        .m_axi_arprot(NLW_fifo_gen_inst_m_axi_arprot_UNCONNECTED[2:0]),
        .m_axi_arqos(NLW_fifo_gen_inst_m_axi_arqos_UNCONNECTED[3:0]),
        .m_axi_arready(1'b0),
        .m_axi_arregion(NLW_fifo_gen_inst_m_axi_arregion_UNCONNECTED[3:0]),
        .m_axi_arsize(NLW_fifo_gen_inst_m_axi_arsize_UNCONNECTED[2:0]),
        .m_axi_aruser(NLW_fifo_gen_inst_m_axi_aruser_UNCONNECTED[0]),
        .m_axi_arvalid(NLW_fifo_gen_inst_m_axi_arvalid_UNCONNECTED),
        .m_axi_awaddr(NLW_fifo_gen_inst_m_axi_awaddr_UNCONNECTED[31:0]),
        .m_axi_awburst(NLW_fifo_gen_inst_m_axi_awburst_UNCONNECTED[1:0]),
        .m_axi_awcache(NLW_fifo_gen_inst_m_axi_awcache_UNCONNECTED[3:0]),
        .m_axi_awid(NLW_fifo_gen_inst_m_axi_awid_UNCONNECTED[3:0]),
        .m_axi_awlen(NLW_fifo_gen_inst_m_axi_awlen_UNCONNECTED[7:0]),
        .m_axi_awlock(NLW_fifo_gen_inst_m_axi_awlock_UNCONNECTED[1:0]),
        .m_axi_awprot(NLW_fifo_gen_inst_m_axi_awprot_UNCONNECTED[2:0]),
        .m_axi_awqos(NLW_fifo_gen_inst_m_axi_awqos_UNCONNECTED[3:0]),
        .m_axi_awready(1'b0),
        .m_axi_awregion(NLW_fifo_gen_inst_m_axi_awregion_UNCONNECTED[3:0]),
        .m_axi_awsize(NLW_fifo_gen_inst_m_axi_awsize_UNCONNECTED[2:0]),
        .m_axi_awuser(NLW_fifo_gen_inst_m_axi_awuser_UNCONNECTED[0]),
        .m_axi_awvalid(NLW_fifo_gen_inst_m_axi_awvalid_UNCONNECTED),
        .m_axi_bid({1'b0,1'b0,1'b0,1'b0}),
        .m_axi_bready(NLW_fifo_gen_inst_m_axi_bready_UNCONNECTED),
        .m_axi_bresp({1'b0,1'b0}),
        .m_axi_buser(1'b0),
        .m_axi_bvalid(1'b0),
        .m_axi_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_axi_rid({1'b0,1'b0,1'b0,1'b0}),
        .m_axi_rlast(1'b0),
        .m_axi_rready(NLW_fifo_gen_inst_m_axi_rready_UNCONNECTED),
        .m_axi_rresp({1'b0,1'b0}),
        .m_axi_ruser(1'b0),
        .m_axi_rvalid(1'b0),
        .m_axi_wdata(NLW_fifo_gen_inst_m_axi_wdata_UNCONNECTED[63:0]),
        .m_axi_wid(NLW_fifo_gen_inst_m_axi_wid_UNCONNECTED[3:0]),
        .m_axi_wlast(NLW_fifo_gen_inst_m_axi_wlast_UNCONNECTED),
        .m_axi_wready(1'b0),
        .m_axi_wstrb(NLW_fifo_gen_inst_m_axi_wstrb_UNCONNECTED[7:0]),
        .m_axi_wuser(NLW_fifo_gen_inst_m_axi_wuser_UNCONNECTED[0]),
        .m_axi_wvalid(NLW_fifo_gen_inst_m_axi_wvalid_UNCONNECTED),
        .m_axis_tdata(NLW_fifo_gen_inst_m_axis_tdata_UNCONNECTED[63:0]),
        .m_axis_tdest(NLW_fifo_gen_inst_m_axis_tdest_UNCONNECTED[3:0]),
        .m_axis_tid(NLW_fifo_gen_inst_m_axis_tid_UNCONNECTED[7:0]),
        .m_axis_tkeep(NLW_fifo_gen_inst_m_axis_tkeep_UNCONNECTED[3:0]),
        .m_axis_tlast(NLW_fifo_gen_inst_m_axis_tlast_UNCONNECTED),
        .m_axis_tready(1'b0),
        .m_axis_tstrb(NLW_fifo_gen_inst_m_axis_tstrb_UNCONNECTED[3:0]),
        .m_axis_tuser(NLW_fifo_gen_inst_m_axis_tuser_UNCONNECTED[3:0]),
        .m_axis_tvalid(NLW_fifo_gen_inst_m_axis_tvalid_UNCONNECTED),
        .overflow(NLW_fifo_gen_inst_overflow_UNCONNECTED),
        .prog_empty(NLW_fifo_gen_inst_prog_empty_UNCONNECTED),
        .prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full(NLW_fifo_gen_inst_prog_full_UNCONNECTED),
        .prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .rd_clk(1'b0),
        .rd_data_count(NLW_fifo_gen_inst_rd_data_count_UNCONNECTED[5:0]),
        .rd_en(rd_en),
        .rd_rst(1'b0),
        .rd_rst_busy(NLW_fifo_gen_inst_rd_rst_busy_UNCONNECTED),
        .rst(SR),
        .s_aclk(1'b0),
        .s_aclk_en(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlock({1'b0,1'b0}),
        .s_axi_arprot({1'b0,1'b0,1'b0}),
        .s_axi_arqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_fifo_gen_inst_s_axi_arready_UNCONNECTED),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_aruser(1'b0),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlock({1'b0,1'b0}),
        .s_axi_awprot({1'b0,1'b0,1'b0}),
        .s_axi_awqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_fifo_gen_inst_s_axi_awready_UNCONNECTED),
        .s_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awuser(1'b0),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_fifo_gen_inst_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_fifo_gen_inst_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_buser(NLW_fifo_gen_inst_s_axi_buser_UNCONNECTED[0]),
        .s_axi_bvalid(NLW_fifo_gen_inst_s_axi_bvalid_UNCONNECTED),
        .s_axi_rdata(NLW_fifo_gen_inst_s_axi_rdata_UNCONNECTED[63:0]),
        .s_axi_rid(NLW_fifo_gen_inst_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_fifo_gen_inst_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_fifo_gen_inst_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_ruser(NLW_fifo_gen_inst_s_axi_ruser_UNCONNECTED[0]),
        .s_axi_rvalid(NLW_fifo_gen_inst_s_axi_rvalid_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_fifo_gen_inst_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wuser(1'b0),
        .s_axi_wvalid(1'b0),
        .s_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tdest({1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tkeep({1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tlast(1'b0),
        .s_axis_tready(NLW_fifo_gen_inst_s_axis_tready_UNCONNECTED),
        .s_axis_tstrb({1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tuser({1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tvalid(1'b0),
        .sbiterr(NLW_fifo_gen_inst_sbiterr_UNCONNECTED),
        .sleep(1'b0),
        .srst(1'b0),
        .underflow(NLW_fifo_gen_inst_underflow_UNCONNECTED),
        .valid(NLW_fifo_gen_inst_valid_UNCONNECTED),
        .wr_ack(NLW_fifo_gen_inst_wr_ack_UNCONNECTED),
        .wr_clk(1'b0),
        .wr_data_count(NLW_fifo_gen_inst_wr_data_count_UNCONNECTED[5:0]),
        .wr_en(cmd_push),
        .wr_rst(1'b0),
        .wr_rst_busy(NLW_fifo_gen_inst_wr_rst_busy_UNCONNECTED));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT3 #(
    .INIT(8'h02)) 
    fifo_gen_inst_i_1
       (.I0(command_ongoing),
        .I1(full),
        .I2(m_axi_awvalid_0),
        .O(cmd_push));
  LUT6 #(
    .INIT(64'hE4E4CC664E4ECC66)) 
    \length_counter_1[1]_i_1 
       (.I0(empty_fwft_i_reg),
        .I1(length_counter_1_reg[1]),
        .I2(dout[1]),
        .I3(length_counter_1_reg[0]),
        .I4(first_mi_word),
        .I5(dout[0]),
        .O(length_counter_1_reg_1_sn_1));
  LUT3 #(
    .INIT(8'hA2)) 
    m_axi_awvalid_INST_0
       (.I0(command_ongoing),
        .I1(full),
        .I2(m_axi_awvalid_0),
        .O(m_axi_awvalid));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT2 #(
    .INIT(4'h2)) 
    m_axi_wvalid_INST_0
       (.I0(s_axi_wvalid),
        .I1(empty),
        .O(m_axi_wvalid));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT3 #(
    .INIT(8'h40)) 
    s_axi_wready_INST_0
       (.I0(empty),
        .I1(s_axi_wvalid),
        .I2(m_axi_wready),
        .O(empty_fwft_i_reg));
endmodule

module design_1_auto_pc_1_axi_protocol_converter_v2_1_29_a_axi3_conv
   (dout,
    empty,
    SR,
    m_axi_awlen,
    m_axi_awlock,
    E,
    m_axi_awvalid,
    length_counter_1_reg_1_sp_1,
    empty_fwft_i_reg,
    m_axi_wvalid,
    m_axi_awaddr,
    m_axi_awsize,
    m_axi_awburst,
    m_axi_awcache,
    m_axi_awprot,
    m_axi_awqos,
    aclk,
    rd_en,
    s_axi_awlock,
    aresetn,
    m_axi_awready,
    length_counter_1_reg,
    first_mi_word,
    s_axi_wvalid,
    m_axi_wready,
    s_axi_awvalid,
    s_axi_awaddr,
    s_axi_awlen,
    s_axi_awsize,
    s_axi_awburst,
    s_axi_awcache,
    s_axi_awprot,
    s_axi_awqos);
  output [3:0]dout;
  output empty;
  output [0:0]SR;
  output [3:0]m_axi_awlen;
  output [0:0]m_axi_awlock;
  output [0:0]E;
  output m_axi_awvalid;
  output length_counter_1_reg_1_sp_1;
  output empty_fwft_i_reg;
  output m_axi_wvalid;
  output [31:0]m_axi_awaddr;
  output [2:0]m_axi_awsize;
  output [1:0]m_axi_awburst;
  output [3:0]m_axi_awcache;
  output [2:0]m_axi_awprot;
  output [3:0]m_axi_awqos;
  input aclk;
  input rd_en;
  input [0:0]s_axi_awlock;
  input aresetn;
  input m_axi_awready;
  input [1:0]length_counter_1_reg;
  input first_mi_word;
  input s_axi_wvalid;
  input m_axi_wready;
  input s_axi_awvalid;
  input [31:0]s_axi_awaddr;
  input [3:0]s_axi_awlen;
  input [2:0]s_axi_awsize;
  input [1:0]s_axi_awburst;
  input [3:0]s_axi_awcache;
  input [2:0]s_axi_awprot;
  input [3:0]s_axi_awqos;

  wire [0:0]E;
  wire [0:0]SR;
  wire \USE_BURSTS.cmd_queue_n_11 ;
  wire \USE_BURSTS.cmd_queue_n_12 ;
  wire \USE_BURSTS.cmd_queue_n_6 ;
  wire aclk;
  wire [1:0]areset_d;
  wire aresetn;
  wire cmd_push_block_reg_n_0;
  wire command_ongoing;
  wire [3:0]dout;
  wire empty;
  wire empty_fwft_i_reg;
  wire first_mi_word;
  wire [1:0]length_counter_1_reg;
  wire length_counter_1_reg_1_sn_1;
  wire [31:0]m_axi_awaddr;
  wire [1:0]m_axi_awburst;
  wire [3:0]m_axi_awcache;
  wire [3:0]m_axi_awlen;
  wire [0:0]m_axi_awlock;
  wire [2:0]m_axi_awprot;
  wire [3:0]m_axi_awqos;
  wire m_axi_awready;
  wire [2:0]m_axi_awsize;
  wire m_axi_awvalid;
  wire m_axi_wready;
  wire m_axi_wvalid;
  wire rd_en;
  wire [31:0]s_axi_awaddr;
  wire [1:0]s_axi_awburst;
  wire [3:0]s_axi_awcache;
  wire [3:0]s_axi_awlen;
  wire [0:0]s_axi_awlock;
  wire [2:0]s_axi_awprot;
  wire [3:0]s_axi_awqos;
  wire [2:0]s_axi_awsize;
  wire s_axi_awvalid;
  wire s_axi_wvalid;

  assign length_counter_1_reg_1_sp_1 = length_counter_1_reg_1_sn_1;
  FDRE \S_AXI_AADDR_Q_reg[0] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[0]),
        .Q(m_axi_awaddr[0]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[10] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[10]),
        .Q(m_axi_awaddr[10]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[11] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[11]),
        .Q(m_axi_awaddr[11]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[12] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[12]),
        .Q(m_axi_awaddr[12]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[13] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[13]),
        .Q(m_axi_awaddr[13]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[14] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[14]),
        .Q(m_axi_awaddr[14]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[15] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[15]),
        .Q(m_axi_awaddr[15]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[16] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[16]),
        .Q(m_axi_awaddr[16]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[17] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[17]),
        .Q(m_axi_awaddr[17]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[18] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[18]),
        .Q(m_axi_awaddr[18]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[19] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[19]),
        .Q(m_axi_awaddr[19]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[1] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[1]),
        .Q(m_axi_awaddr[1]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[20] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[20]),
        .Q(m_axi_awaddr[20]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[21] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[21]),
        .Q(m_axi_awaddr[21]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[22] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[22]),
        .Q(m_axi_awaddr[22]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[23] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[23]),
        .Q(m_axi_awaddr[23]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[24] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[24]),
        .Q(m_axi_awaddr[24]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[25] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[25]),
        .Q(m_axi_awaddr[25]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[26] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[26]),
        .Q(m_axi_awaddr[26]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[27] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[27]),
        .Q(m_axi_awaddr[27]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[28] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[28]),
        .Q(m_axi_awaddr[28]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[29] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[29]),
        .Q(m_axi_awaddr[29]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[2] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[2]),
        .Q(m_axi_awaddr[2]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[30] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[30]),
        .Q(m_axi_awaddr[30]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[31] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[31]),
        .Q(m_axi_awaddr[31]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[3] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[3]),
        .Q(m_axi_awaddr[3]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[4] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[4]),
        .Q(m_axi_awaddr[4]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[5] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[5]),
        .Q(m_axi_awaddr[5]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[6] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[6]),
        .Q(m_axi_awaddr[6]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[7] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[7]),
        .Q(m_axi_awaddr[7]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[8] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[8]),
        .Q(m_axi_awaddr[8]),
        .R(SR));
  FDRE \S_AXI_AADDR_Q_reg[9] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awaddr[9]),
        .Q(m_axi_awaddr[9]),
        .R(SR));
  FDRE \S_AXI_ABURST_Q_reg[0] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awburst[0]),
        .Q(m_axi_awburst[0]),
        .R(SR));
  FDRE \S_AXI_ABURST_Q_reg[1] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awburst[1]),
        .Q(m_axi_awburst[1]),
        .R(SR));
  FDRE \S_AXI_ACACHE_Q_reg[0] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awcache[0]),
        .Q(m_axi_awcache[0]),
        .R(SR));
  FDRE \S_AXI_ACACHE_Q_reg[1] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awcache[1]),
        .Q(m_axi_awcache[1]),
        .R(SR));
  FDRE \S_AXI_ACACHE_Q_reg[2] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awcache[2]),
        .Q(m_axi_awcache[2]),
        .R(SR));
  FDRE \S_AXI_ACACHE_Q_reg[3] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awcache[3]),
        .Q(m_axi_awcache[3]),
        .R(SR));
  FDRE \S_AXI_ALEN_Q_reg[0] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awlen[0]),
        .Q(m_axi_awlen[0]),
        .R(SR));
  FDRE \S_AXI_ALEN_Q_reg[1] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awlen[1]),
        .Q(m_axi_awlen[1]),
        .R(SR));
  FDRE \S_AXI_ALEN_Q_reg[2] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awlen[2]),
        .Q(m_axi_awlen[2]),
        .R(SR));
  FDRE \S_AXI_ALEN_Q_reg[3] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awlen[3]),
        .Q(m_axi_awlen[3]),
        .R(SR));
  FDRE \S_AXI_ALOCK_Q_reg[0] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awlock),
        .Q(m_axi_awlock),
        .R(SR));
  FDRE \S_AXI_APROT_Q_reg[0] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awprot[0]),
        .Q(m_axi_awprot[0]),
        .R(SR));
  FDRE \S_AXI_APROT_Q_reg[1] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awprot[1]),
        .Q(m_axi_awprot[1]),
        .R(SR));
  FDRE \S_AXI_APROT_Q_reg[2] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awprot[2]),
        .Q(m_axi_awprot[2]),
        .R(SR));
  FDRE \S_AXI_AQOS_Q_reg[0] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awqos[0]),
        .Q(m_axi_awqos[0]),
        .R(SR));
  FDRE \S_AXI_AQOS_Q_reg[1] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awqos[1]),
        .Q(m_axi_awqos[1]),
        .R(SR));
  FDRE \S_AXI_AQOS_Q_reg[2] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awqos[2]),
        .Q(m_axi_awqos[2]),
        .R(SR));
  FDRE \S_AXI_AQOS_Q_reg[3] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awqos[3]),
        .Q(m_axi_awqos[3]),
        .R(SR));
  FDRE #(
    .INIT(1'b0)) 
    S_AXI_AREADY_I_reg
       (.C(aclk),
        .CE(1'b1),
        .D(\USE_BURSTS.cmd_queue_n_11 ),
        .Q(E),
        .R(SR));
  FDRE \S_AXI_ASIZE_Q_reg[0] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awsize[0]),
        .Q(m_axi_awsize[0]),
        .R(SR));
  FDRE \S_AXI_ASIZE_Q_reg[1] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awsize[1]),
        .Q(m_axi_awsize[1]),
        .R(SR));
  FDRE \S_AXI_ASIZE_Q_reg[2] 
       (.C(aclk),
        .CE(E),
        .D(s_axi_awsize[2]),
        .Q(m_axi_awsize[2]),
        .R(SR));
  design_1_auto_pc_1_axi_data_fifo_v2_1_28_axic_fifo \USE_BURSTS.cmd_queue 
       (.E(E),
        .Q(areset_d),
        .SR(SR),
        .S_AXI_AREADY_I_reg(\USE_BURSTS.cmd_queue_n_11 ),
        .aclk(aclk),
        .\areset_d_reg[1] (\USE_BURSTS.cmd_queue_n_12 ),
        .aresetn(aresetn),
        .aresetn_0(\USE_BURSTS.cmd_queue_n_6 ),
        .command_ongoing(command_ongoing),
        .dout(dout),
        .empty(empty),
        .empty_fwft_i_reg(empty_fwft_i_reg),
        .first_mi_word(first_mi_word),
        .length_counter_1_reg(length_counter_1_reg),
        .length_counter_1_reg_1_sp_1(length_counter_1_reg_1_sn_1),
        .m_axi_awlen(m_axi_awlen),
        .m_axi_awready(m_axi_awready),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_awvalid_0(cmd_push_block_reg_n_0),
        .m_axi_wready(m_axi_wready),
        .m_axi_wvalid(m_axi_wvalid),
        .rd_en(rd_en),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_wvalid(s_axi_wvalid));
  FDRE #(
    .INIT(1'b0)) 
    \areset_d_reg[0] 
       (.C(aclk),
        .CE(1'b1),
        .D(SR),
        .Q(areset_d[0]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \areset_d_reg[1] 
       (.C(aclk),
        .CE(1'b1),
        .D(areset_d[0]),
        .Q(areset_d[1]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    cmd_push_block_reg
       (.C(aclk),
        .CE(1'b1),
        .D(\USE_BURSTS.cmd_queue_n_6 ),
        .Q(cmd_push_block_reg_n_0),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    command_ongoing_reg
       (.C(aclk),
        .CE(1'b1),
        .D(\USE_BURSTS.cmd_queue_n_12 ),
        .Q(command_ongoing),
        .R(SR));
endmodule

module design_1_auto_pc_1_axi_protocol_converter_v2_1_29_axi3_conv
   (m_axi_awlen,
    m_axi_awaddr,
    E,
    m_axi_awsize,
    m_axi_awburst,
    m_axi_awlock,
    m_axi_awcache,
    m_axi_awprot,
    m_axi_awqos,
    m_axi_awvalid,
    empty_fwft_i_reg,
    m_axi_wvalid,
    m_axi_wlast,
    aresetn,
    m_axi_awready,
    aclk,
    s_axi_awaddr,
    s_axi_awlen,
    s_axi_awsize,
    s_axi_awburst,
    s_axi_awlock,
    s_axi_awcache,
    s_axi_awprot,
    s_axi_awqos,
    m_axi_wready,
    s_axi_wvalid,
    s_axi_awvalid);
  output [3:0]m_axi_awlen;
  output [31:0]m_axi_awaddr;
  output [0:0]E;
  output [2:0]m_axi_awsize;
  output [1:0]m_axi_awburst;
  output [0:0]m_axi_awlock;
  output [3:0]m_axi_awcache;
  output [2:0]m_axi_awprot;
  output [3:0]m_axi_awqos;
  output m_axi_awvalid;
  output empty_fwft_i_reg;
  output m_axi_wvalid;
  output m_axi_wlast;
  input aresetn;
  input m_axi_awready;
  input aclk;
  input [31:0]s_axi_awaddr;
  input [3:0]s_axi_awlen;
  input [2:0]s_axi_awsize;
  input [1:0]s_axi_awburst;
  input [0:0]s_axi_awlock;
  input [3:0]s_axi_awcache;
  input [2:0]s_axi_awprot;
  input [3:0]s_axi_awqos;
  input m_axi_wready;
  input s_axi_wvalid;
  input s_axi_awvalid;

  wire [0:0]E;
  wire \USE_BURSTS.cmd_queue/inst/empty ;
  wire [3:0]\USE_WRITE.wr_cmd_length ;
  wire \USE_WRITE.wr_cmd_ready ;
  wire \USE_WRITE.write_addr_inst_n_13 ;
  wire \USE_WRITE.write_addr_inst_n_5 ;
  wire aclk;
  wire aresetn;
  wire empty_fwft_i_reg;
  wire first_mi_word;
  wire [1:0]length_counter_1_reg;
  wire [31:0]m_axi_awaddr;
  wire [1:0]m_axi_awburst;
  wire [3:0]m_axi_awcache;
  wire [3:0]m_axi_awlen;
  wire [0:0]m_axi_awlock;
  wire [2:0]m_axi_awprot;
  wire [3:0]m_axi_awqos;
  wire m_axi_awready;
  wire [2:0]m_axi_awsize;
  wire m_axi_awvalid;
  wire m_axi_wlast;
  wire m_axi_wready;
  wire m_axi_wvalid;
  wire [31:0]s_axi_awaddr;
  wire [1:0]s_axi_awburst;
  wire [3:0]s_axi_awcache;
  wire [3:0]s_axi_awlen;
  wire [0:0]s_axi_awlock;
  wire [2:0]s_axi_awprot;
  wire [3:0]s_axi_awqos;
  wire [2:0]s_axi_awsize;
  wire s_axi_awvalid;
  wire s_axi_wvalid;

  design_1_auto_pc_1_axi_protocol_converter_v2_1_29_a_axi3_conv \USE_WRITE.write_addr_inst 
       (.E(E),
        .SR(\USE_WRITE.write_addr_inst_n_5 ),
        .aclk(aclk),
        .aresetn(aresetn),
        .dout(\USE_WRITE.wr_cmd_length ),
        .empty(\USE_BURSTS.cmd_queue/inst/empty ),
        .empty_fwft_i_reg(empty_fwft_i_reg),
        .first_mi_word(first_mi_word),
        .length_counter_1_reg(length_counter_1_reg),
        .length_counter_1_reg_1_sp_1(\USE_WRITE.write_addr_inst_n_13 ),
        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awburst(m_axi_awburst),
        .m_axi_awcache(m_axi_awcache),
        .m_axi_awlen(m_axi_awlen),
        .m_axi_awlock(m_axi_awlock),
        .m_axi_awprot(m_axi_awprot),
        .m_axi_awqos(m_axi_awqos),
        .m_axi_awready(m_axi_awready),
        .m_axi_awsize(m_axi_awsize),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_wready(m_axi_wready),
        .m_axi_wvalid(m_axi_wvalid),
        .rd_en(\USE_WRITE.wr_cmd_ready ),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_awcache(s_axi_awcache),
        .s_axi_awlen(s_axi_awlen),
        .s_axi_awlock(s_axi_awlock),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awqos(s_axi_awqos),
        .s_axi_awsize(s_axi_awsize),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_wvalid(s_axi_wvalid));
  design_1_auto_pc_1_axi_protocol_converter_v2_1_29_w_axi3_conv \USE_WRITE.write_data_inst 
       (.SR(\USE_WRITE.write_addr_inst_n_5 ),
        .aclk(aclk),
        .dout(\USE_WRITE.wr_cmd_length ),
        .empty(\USE_BURSTS.cmd_queue/inst/empty ),
        .first_mi_word(first_mi_word),
        .\length_counter_1_reg[1]_0 (length_counter_1_reg),
        .\length_counter_1_reg[1]_1 (\USE_WRITE.write_addr_inst_n_13 ),
        .\length_counter_1_reg[2]_0 (empty_fwft_i_reg),
        .m_axi_wlast(m_axi_wlast),
        .m_axi_wready(m_axi_wready),
        .rd_en(\USE_WRITE.wr_cmd_ready ),
        .s_axi_wvalid(s_axi_wvalid));
endmodule

(* C_AXI_ADDR_WIDTH = "32" *) (* C_AXI_ARUSER_WIDTH = "1" *) (* C_AXI_AWUSER_WIDTH = "1" *) 
(* C_AXI_BUSER_WIDTH = "1" *) (* C_AXI_DATA_WIDTH = "32" *) (* C_AXI_ID_WIDTH = "1" *) 
(* C_AXI_RUSER_WIDTH = "1" *) (* C_AXI_SUPPORTS_READ = "0" *) (* C_AXI_SUPPORTS_USER_SIGNALS = "0" *) 
(* C_AXI_SUPPORTS_WRITE = "1" *) (* C_AXI_WUSER_WIDTH = "1" *) (* C_FAMILY = "zynq" *) 
(* C_IGNORE_ID = "1" *) (* C_M_AXI_PROTOCOL = "1" *) (* C_S_AXI_PROTOCOL = "0" *) 
(* C_TRANSLATION_MODE = "0" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* P_AXI3 = "1" *) 
(* P_AXI4 = "0" *) (* P_AXILITE = "2" *) (* P_AXILITE_SIZE = "3'b010" *) 
(* P_CONVERSION = "2" *) (* P_DECERR = "2'b11" *) (* P_INCR = "2'b01" *) 
(* P_PROTECTION = "1" *) (* P_SLVERR = "2'b10" *) 
module design_1_auto_pc_1_axi_protocol_converter_v2_1_29_axi_protocol_converter
   (aclk,
    aresetn,
    s_axi_awid,
    s_axi_awaddr,
    s_axi_awlen,
    s_axi_awsize,
    s_axi_awburst,
    s_axi_awlock,
    s_axi_awcache,
    s_axi_awprot,
    s_axi_awregion,
    s_axi_awqos,
    s_axi_awuser,
    s_axi_awvalid,
    s_axi_awready,
    s_axi_wid,
    s_axi_wdata,
    s_axi_wstrb,
    s_axi_wlast,
    s_axi_wuser,
    s_axi_wvalid,
    s_axi_wready,
    s_axi_bid,
    s_axi_bresp,
    s_axi_buser,
    s_axi_bvalid,
    s_axi_bready,
    s_axi_arid,
    s_axi_araddr,
    s_axi_arlen,
    s_axi_arsize,
    s_axi_arburst,
    s_axi_arlock,
    s_axi_arcache,
    s_axi_arprot,
    s_axi_arregion,
    s_axi_arqos,
    s_axi_aruser,
    s_axi_arvalid,
    s_axi_arready,
    s_axi_rid,
    s_axi_rdata,
    s_axi_rresp,
    s_axi_rlast,
    s_axi_ruser,
    s_axi_rvalid,
    s_axi_rready,
    m_axi_awid,
    m_axi_awaddr,
    m_axi_awlen,
    m_axi_awsize,
    m_axi_awburst,
    m_axi_awlock,
    m_axi_awcache,
    m_axi_awprot,
    m_axi_awregion,
    m_axi_awqos,
    m_axi_awuser,
    m_axi_awvalid,
    m_axi_awready,
    m_axi_wid,
    m_axi_wdata,
    m_axi_wstrb,
    m_axi_wlast,
    m_axi_wuser,
    m_axi_wvalid,
    m_axi_wready,
    m_axi_bid,
    m_axi_bresp,
    m_axi_buser,
    m_axi_bvalid,
    m_axi_bready,
    m_axi_arid,
    m_axi_araddr,
    m_axi_arlen,
    m_axi_arsize,
    m_axi_arburst,
    m_axi_arlock,
    m_axi_arcache,
    m_axi_arprot,
    m_axi_arregion,
    m_axi_arqos,
    m_axi_aruser,
    m_axi_arvalid,
    m_axi_arready,
    m_axi_rid,
    m_axi_rdata,
    m_axi_rresp,
    m_axi_rlast,
    m_axi_ruser,
    m_axi_rvalid,
    m_axi_rready);
  input aclk;
  input aresetn;
  input [0:0]s_axi_awid;
  input [31:0]s_axi_awaddr;
  input [7:0]s_axi_awlen;
  input [2:0]s_axi_awsize;
  input [1:0]s_axi_awburst;
  input [0:0]s_axi_awlock;
  input [3:0]s_axi_awcache;
  input [2:0]s_axi_awprot;
  input [3:0]s_axi_awregion;
  input [3:0]s_axi_awqos;
  input [0:0]s_axi_awuser;
  input s_axi_awvalid;
  output s_axi_awready;
  input [0:0]s_axi_wid;
  input [31:0]s_axi_wdata;
  input [3:0]s_axi_wstrb;
  input s_axi_wlast;
  input [0:0]s_axi_wuser;
  input s_axi_wvalid;
  output s_axi_wready;
  output [0:0]s_axi_bid;
  output [1:0]s_axi_bresp;
  output [0:0]s_axi_buser;
  output s_axi_bvalid;
  input s_axi_bready;
  input [0:0]s_axi_arid;
  input [31:0]s_axi_araddr;
  input [7:0]s_axi_arlen;
  input [2:0]s_axi_arsize;
  input [1:0]s_axi_arburst;
  input [0:0]s_axi_arlock;
  input [3:0]s_axi_arcache;
  input [2:0]s_axi_arprot;
  input [3:0]s_axi_arregion;
  input [3:0]s_axi_arqos;
  input [0:0]s_axi_aruser;
  input s_axi_arvalid;
  output s_axi_arready;
  output [0:0]s_axi_rid;
  output [31:0]s_axi_rdata;
  output [1:0]s_axi_rresp;
  output s_axi_rlast;
  output [0:0]s_axi_ruser;
  output s_axi_rvalid;
  input s_axi_rready;
  output [0:0]m_axi_awid;
  output [31:0]m_axi_awaddr;
  output [3:0]m_axi_awlen;
  output [2:0]m_axi_awsize;
  output [1:0]m_axi_awburst;
  output [1:0]m_axi_awlock;
  output [3:0]m_axi_awcache;
  output [2:0]m_axi_awprot;
  output [3:0]m_axi_awregion;
  output [3:0]m_axi_awqos;
  output [0:0]m_axi_awuser;
  output m_axi_awvalid;
  input m_axi_awready;
  output [0:0]m_axi_wid;
  output [31:0]m_axi_wdata;
  output [3:0]m_axi_wstrb;
  output m_axi_wlast;
  output [0:0]m_axi_wuser;
  output m_axi_wvalid;
  input m_axi_wready;
  input [0:0]m_axi_bid;
  input [1:0]m_axi_bresp;
  input [0:0]m_axi_buser;
  input m_axi_bvalid;
  output m_axi_bready;
  output [0:0]m_axi_arid;
  output [31:0]m_axi_araddr;
  output [3:0]m_axi_arlen;
  output [2:0]m_axi_arsize;
  output [1:0]m_axi_arburst;
  output [1:0]m_axi_arlock;
  output [3:0]m_axi_arcache;
  output [2:0]m_axi_arprot;
  output [3:0]m_axi_arregion;
  output [3:0]m_axi_arqos;
  output [0:0]m_axi_aruser;
  output m_axi_arvalid;
  input m_axi_arready;
  input [0:0]m_axi_rid;
  input [31:0]m_axi_rdata;
  input [1:0]m_axi_rresp;
  input m_axi_rlast;
  input [0:0]m_axi_ruser;
  input m_axi_rvalid;
  output m_axi_rready;

  wire \<const0> ;
  wire aclk;
  wire aresetn;
  wire [31:0]m_axi_awaddr;
  wire [1:0]m_axi_awburst;
  wire [3:0]m_axi_awcache;
  wire [3:0]m_axi_awlen;
  wire [0:0]\^m_axi_awlock ;
  wire [2:0]m_axi_awprot;
  wire [3:0]m_axi_awqos;
  wire m_axi_awready;
  wire [2:0]m_axi_awsize;
  wire m_axi_awvalid;
  wire [1:0]m_axi_bresp;
  wire m_axi_bvalid;
  wire m_axi_wlast;
  wire m_axi_wready;
  wire m_axi_wvalid;
  wire [31:0]s_axi_awaddr;
  wire [1:0]s_axi_awburst;
  wire [3:0]s_axi_awcache;
  wire [7:0]s_axi_awlen;
  wire [0:0]s_axi_awlock;
  wire [2:0]s_axi_awprot;
  wire [3:0]s_axi_awqos;
  wire s_axi_awready;
  wire [2:0]s_axi_awsize;
  wire s_axi_awvalid;
  wire s_axi_bready;
  wire [31:0]s_axi_wdata;
  wire s_axi_wready;
  wire [3:0]s_axi_wstrb;
  wire s_axi_wvalid;

  assign m_axi_araddr[31] = \<const0> ;
  assign m_axi_araddr[30] = \<const0> ;
  assign m_axi_araddr[29] = \<const0> ;
  assign m_axi_araddr[28] = \<const0> ;
  assign m_axi_araddr[27] = \<const0> ;
  assign m_axi_araddr[26] = \<const0> ;
  assign m_axi_araddr[25] = \<const0> ;
  assign m_axi_araddr[24] = \<const0> ;
  assign m_axi_araddr[23] = \<const0> ;
  assign m_axi_araddr[22] = \<const0> ;
  assign m_axi_araddr[21] = \<const0> ;
  assign m_axi_araddr[20] = \<const0> ;
  assign m_axi_araddr[19] = \<const0> ;
  assign m_axi_araddr[18] = \<const0> ;
  assign m_axi_araddr[17] = \<const0> ;
  assign m_axi_araddr[16] = \<const0> ;
  assign m_axi_araddr[15] = \<const0> ;
  assign m_axi_araddr[14] = \<const0> ;
  assign m_axi_araddr[13] = \<const0> ;
  assign m_axi_araddr[12] = \<const0> ;
  assign m_axi_araddr[11] = \<const0> ;
  assign m_axi_araddr[10] = \<const0> ;
  assign m_axi_araddr[9] = \<const0> ;
  assign m_axi_araddr[8] = \<const0> ;
  assign m_axi_araddr[7] = \<const0> ;
  assign m_axi_araddr[6] = \<const0> ;
  assign m_axi_araddr[5] = \<const0> ;
  assign m_axi_araddr[4] = \<const0> ;
  assign m_axi_araddr[3] = \<const0> ;
  assign m_axi_araddr[2] = \<const0> ;
  assign m_axi_araddr[1] = \<const0> ;
  assign m_axi_araddr[0] = \<const0> ;
  assign m_axi_arburst[1] = \<const0> ;
  assign m_axi_arburst[0] = \<const0> ;
  assign m_axi_arcache[3] = \<const0> ;
  assign m_axi_arcache[2] = \<const0> ;
  assign m_axi_arcache[1] = \<const0> ;
  assign m_axi_arcache[0] = \<const0> ;
  assign m_axi_arid[0] = \<const0> ;
  assign m_axi_arlen[3] = \<const0> ;
  assign m_axi_arlen[2] = \<const0> ;
  assign m_axi_arlen[1] = \<const0> ;
  assign m_axi_arlen[0] = \<const0> ;
  assign m_axi_arlock[1] = \<const0> ;
  assign m_axi_arlock[0] = \<const0> ;
  assign m_axi_arprot[2] = \<const0> ;
  assign m_axi_arprot[1] = \<const0> ;
  assign m_axi_arprot[0] = \<const0> ;
  assign m_axi_arqos[3] = \<const0> ;
  assign m_axi_arqos[2] = \<const0> ;
  assign m_axi_arqos[1] = \<const0> ;
  assign m_axi_arqos[0] = \<const0> ;
  assign m_axi_arregion[3] = \<const0> ;
  assign m_axi_arregion[2] = \<const0> ;
  assign m_axi_arregion[1] = \<const0> ;
  assign m_axi_arregion[0] = \<const0> ;
  assign m_axi_arsize[2] = \<const0> ;
  assign m_axi_arsize[1] = \<const0> ;
  assign m_axi_arsize[0] = \<const0> ;
  assign m_axi_aruser[0] = \<const0> ;
  assign m_axi_arvalid = \<const0> ;
  assign m_axi_awid[0] = \<const0> ;
  assign m_axi_awlock[1] = \<const0> ;
  assign m_axi_awlock[0] = \^m_axi_awlock [0];
  assign m_axi_awregion[3] = \<const0> ;
  assign m_axi_awregion[2] = \<const0> ;
  assign m_axi_awregion[1] = \<const0> ;
  assign m_axi_awregion[0] = \<const0> ;
  assign m_axi_awuser[0] = \<const0> ;
  assign m_axi_bready = s_axi_bready;
  assign m_axi_rready = \<const0> ;
  assign m_axi_wdata[31:0] = s_axi_wdata;
  assign m_axi_wid[0] = \<const0> ;
  assign m_axi_wstrb[3:0] = s_axi_wstrb;
  assign m_axi_wuser[0] = \<const0> ;
  assign s_axi_arready = \<const0> ;
  assign s_axi_bid[0] = \<const0> ;
  assign s_axi_bresp[1:0] = m_axi_bresp;
  assign s_axi_buser[0] = \<const0> ;
  assign s_axi_bvalid = m_axi_bvalid;
  assign s_axi_rdata[31] = \<const0> ;
  assign s_axi_rdata[30] = \<const0> ;
  assign s_axi_rdata[29] = \<const0> ;
  assign s_axi_rdata[28] = \<const0> ;
  assign s_axi_rdata[27] = \<const0> ;
  assign s_axi_rdata[26] = \<const0> ;
  assign s_axi_rdata[25] = \<const0> ;
  assign s_axi_rdata[24] = \<const0> ;
  assign s_axi_rdata[23] = \<const0> ;
  assign s_axi_rdata[22] = \<const0> ;
  assign s_axi_rdata[21] = \<const0> ;
  assign s_axi_rdata[20] = \<const0> ;
  assign s_axi_rdata[19] = \<const0> ;
  assign s_axi_rdata[18] = \<const0> ;
  assign s_axi_rdata[17] = \<const0> ;
  assign s_axi_rdata[16] = \<const0> ;
  assign s_axi_rdata[15] = \<const0> ;
  assign s_axi_rdata[14] = \<const0> ;
  assign s_axi_rdata[13] = \<const0> ;
  assign s_axi_rdata[12] = \<const0> ;
  assign s_axi_rdata[11] = \<const0> ;
  assign s_axi_rdata[10] = \<const0> ;
  assign s_axi_rdata[9] = \<const0> ;
  assign s_axi_rdata[8] = \<const0> ;
  assign s_axi_rdata[7] = \<const0> ;
  assign s_axi_rdata[6] = \<const0> ;
  assign s_axi_rdata[5] = \<const0> ;
  assign s_axi_rdata[4] = \<const0> ;
  assign s_axi_rdata[3] = \<const0> ;
  assign s_axi_rdata[2] = \<const0> ;
  assign s_axi_rdata[1] = \<const0> ;
  assign s_axi_rdata[0] = \<const0> ;
  assign s_axi_rid[0] = \<const0> ;
  assign s_axi_rlast = \<const0> ;
  assign s_axi_rresp[1] = \<const0> ;
  assign s_axi_rresp[0] = \<const0> ;
  assign s_axi_ruser[0] = \<const0> ;
  assign s_axi_rvalid = \<const0> ;
  GND GND
       (.G(\<const0> ));
  design_1_auto_pc_1_axi_protocol_converter_v2_1_29_axi3_conv \gen_axi4_axi3.axi3_conv_inst 
       (.E(s_axi_awready),
        .aclk(aclk),
        .aresetn(aresetn),
        .empty_fwft_i_reg(s_axi_wready),
        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awburst(m_axi_awburst),
        .m_axi_awcache(m_axi_awcache),
        .m_axi_awlen(m_axi_awlen),
        .m_axi_awlock(\^m_axi_awlock ),
        .m_axi_awprot(m_axi_awprot),
        .m_axi_awqos(m_axi_awqos),
        .m_axi_awready(m_axi_awready),
        .m_axi_awsize(m_axi_awsize),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_wlast(m_axi_wlast),
        .m_axi_wready(m_axi_wready),
        .m_axi_wvalid(m_axi_wvalid),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_awcache(s_axi_awcache),
        .s_axi_awlen(s_axi_awlen[3:0]),
        .s_axi_awlock(s_axi_awlock),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awqos(s_axi_awqos),
        .s_axi_awsize(s_axi_awsize),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_wvalid(s_axi_wvalid));
endmodule

module design_1_auto_pc_1_axi_protocol_converter_v2_1_29_w_axi3_conv
   (\length_counter_1_reg[1]_0 ,
    first_mi_word,
    rd_en,
    m_axi_wlast,
    SR,
    aclk,
    \length_counter_1_reg[1]_1 ,
    \length_counter_1_reg[2]_0 ,
    m_axi_wready,
    s_axi_wvalid,
    empty,
    dout);
  output [1:0]\length_counter_1_reg[1]_0 ;
  output first_mi_word;
  output rd_en;
  output m_axi_wlast;
  input [0:0]SR;
  input aclk;
  input \length_counter_1_reg[1]_1 ;
  input \length_counter_1_reg[2]_0 ;
  input m_axi_wready;
  input s_axi_wvalid;
  input empty;
  input [3:0]dout;

  wire [0:0]SR;
  wire aclk;
  wire [3:0]dout;
  wire empty;
  wire first_mi_word;
  wire first_mi_word_i_1_n_0;
  wire \length_counter_1[0]_i_1_n_0 ;
  wire \length_counter_1[2]_i_1_n_0 ;
  wire \length_counter_1[3]_i_1_n_0 ;
  wire \length_counter_1[4]_i_1_n_0 ;
  wire \length_counter_1[4]_i_2_n_0 ;
  wire \length_counter_1[5]_i_1_n_0 ;
  wire \length_counter_1[6]_i_1_n_0 ;
  wire \length_counter_1[7]_i_1_n_0 ;
  wire [7:2]length_counter_1_reg;
  wire [1:0]\length_counter_1_reg[1]_0 ;
  wire \length_counter_1_reg[1]_1 ;
  wire \length_counter_1_reg[2]_0 ;
  wire m_axi_wlast;
  wire m_axi_wlast_INST_0_i_1_n_0;
  wire m_axi_wlast_INST_0_i_2_n_0;
  wire m_axi_wlast_INST_0_i_3_n_0;
  wire m_axi_wready;
  wire rd_en;
  wire s_axi_wvalid;

  LUT6 #(
    .INIT(64'h0000CC000000CC04)) 
    fifo_gen_inst_i_2
       (.I0(length_counter_1_reg[7]),
        .I1(\length_counter_1_reg[2]_0 ),
        .I2(length_counter_1_reg[5]),
        .I3(first_mi_word),
        .I4(m_axi_wlast_INST_0_i_1_n_0),
        .I5(length_counter_1_reg[6]),
        .O(rd_en));
  LUT6 #(
    .INIT(64'h0F0FFFFF00010000)) 
    first_mi_word_i_1
       (.I0(length_counter_1_reg[7]),
        .I1(length_counter_1_reg[5]),
        .I2(m_axi_wlast_INST_0_i_1_n_0),
        .I3(length_counter_1_reg[6]),
        .I4(\length_counter_1_reg[2]_0 ),
        .I5(first_mi_word),
        .O(first_mi_word_i_1_n_0));
  FDSE #(
    .INIT(1'b0)) 
    first_mi_word_reg
       (.C(aclk),
        .CE(1'b1),
        .D(first_mi_word_i_1_n_0),
        .Q(first_mi_word),
        .S(SR));
  LUT6 #(
    .INIT(64'hF2FFFFFF07000000)) 
    \length_counter_1[0]_i_1 
       (.I0(first_mi_word),
        .I1(dout[0]),
        .I2(empty),
        .I3(s_axi_wvalid),
        .I4(m_axi_wready),
        .I5(\length_counter_1_reg[1]_0 [0]),
        .O(\length_counter_1[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT5 #(
    .INIT(32'hD8D272D2)) 
    \length_counter_1[2]_i_1 
       (.I0(\length_counter_1_reg[2]_0 ),
        .I1(m_axi_wlast_INST_0_i_3_n_0),
        .I2(length_counter_1_reg[2]),
        .I3(first_mi_word),
        .I4(dout[2]),
        .O(\length_counter_1[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT5 #(
    .INIT(32'hB8B474B4)) 
    \length_counter_1[3]_i_1 
       (.I0(\length_counter_1[4]_i_2_n_0 ),
        .I1(\length_counter_1_reg[2]_0 ),
        .I2(length_counter_1_reg[3]),
        .I3(first_mi_word),
        .I4(dout[3]),
        .O(\length_counter_1[3]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0A0A3A35AAAAAAAA)) 
    \length_counter_1[4]_i_1 
       (.I0(length_counter_1_reg[4]),
        .I1(dout[3]),
        .I2(first_mi_word),
        .I3(length_counter_1_reg[3]),
        .I4(\length_counter_1[4]_i_2_n_0 ),
        .I5(\length_counter_1_reg[2]_0 ),
        .O(\length_counter_1[4]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT4 #(
    .INIT(16'hFEAE)) 
    \length_counter_1[4]_i_2 
       (.I0(m_axi_wlast_INST_0_i_3_n_0),
        .I1(length_counter_1_reg[2]),
        .I2(first_mi_word),
        .I3(dout[2]),
        .O(\length_counter_1[4]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hF7FF0000FFF70808)) 
    \length_counter_1[5]_i_1 
       (.I0(m_axi_wready),
        .I1(s_axi_wvalid),
        .I2(empty),
        .I3(first_mi_word),
        .I4(length_counter_1_reg[5]),
        .I5(m_axi_wlast_INST_0_i_1_n_0),
        .O(\length_counter_1[5]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h3EFF0D00)) 
    \length_counter_1[6]_i_1 
       (.I0(length_counter_1_reg[5]),
        .I1(first_mi_word),
        .I2(m_axi_wlast_INST_0_i_1_n_0),
        .I3(\length_counter_1_reg[2]_0 ),
        .I4(length_counter_1_reg[6]),
        .O(\length_counter_1[6]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h3F3EFFFF30310000)) 
    \length_counter_1[7]_i_1 
       (.I0(length_counter_1_reg[6]),
        .I1(m_axi_wlast_INST_0_i_1_n_0),
        .I2(first_mi_word),
        .I3(length_counter_1_reg[5]),
        .I4(\length_counter_1_reg[2]_0 ),
        .I5(length_counter_1_reg[7]),
        .O(\length_counter_1[7]_i_1_n_0 ));
  FDRE \length_counter_1_reg[0] 
       (.C(aclk),
        .CE(1'b1),
        .D(\length_counter_1[0]_i_1_n_0 ),
        .Q(\length_counter_1_reg[1]_0 [0]),
        .R(SR));
  FDRE \length_counter_1_reg[1] 
       (.C(aclk),
        .CE(1'b1),
        .D(\length_counter_1_reg[1]_1 ),
        .Q(\length_counter_1_reg[1]_0 [1]),
        .R(SR));
  FDRE \length_counter_1_reg[2] 
       (.C(aclk),
        .CE(1'b1),
        .D(\length_counter_1[2]_i_1_n_0 ),
        .Q(length_counter_1_reg[2]),
        .R(SR));
  FDRE \length_counter_1_reg[3] 
       (.C(aclk),
        .CE(1'b1),
        .D(\length_counter_1[3]_i_1_n_0 ),
        .Q(length_counter_1_reg[3]),
        .R(SR));
  FDRE \length_counter_1_reg[4] 
       (.C(aclk),
        .CE(1'b1),
        .D(\length_counter_1[4]_i_1_n_0 ),
        .Q(length_counter_1_reg[4]),
        .R(SR));
  FDRE \length_counter_1_reg[5] 
       (.C(aclk),
        .CE(1'b1),
        .D(\length_counter_1[5]_i_1_n_0 ),
        .Q(length_counter_1_reg[5]),
        .R(SR));
  FDRE \length_counter_1_reg[6] 
       (.C(aclk),
        .CE(1'b1),
        .D(\length_counter_1[6]_i_1_n_0 ),
        .Q(length_counter_1_reg[6]),
        .R(SR));
  FDRE \length_counter_1_reg[7] 
       (.C(aclk),
        .CE(1'b1),
        .D(\length_counter_1[7]_i_1_n_0 ),
        .Q(length_counter_1_reg[7]),
        .R(SR));
  LUT5 #(
    .INIT(32'h00F000F1)) 
    m_axi_wlast_INST_0
       (.I0(length_counter_1_reg[7]),
        .I1(length_counter_1_reg[5]),
        .I2(first_mi_word),
        .I3(m_axi_wlast_INST_0_i_1_n_0),
        .I4(length_counter_1_reg[6]),
        .O(m_axi_wlast));
  LUT6 #(
    .INIT(64'hFFFFFFFEFCFCFFFE)) 
    m_axi_wlast_INST_0_i_1
       (.I0(length_counter_1_reg[4]),
        .I1(m_axi_wlast_INST_0_i_2_n_0),
        .I2(m_axi_wlast_INST_0_i_3_n_0),
        .I3(length_counter_1_reg[2]),
        .I4(first_mi_word),
        .I5(dout[2]),
        .O(m_axi_wlast_INST_0_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    m_axi_wlast_INST_0_i_2
       (.I0(dout[3]),
        .I1(first_mi_word),
        .I2(length_counter_1_reg[3]),
        .O(m_axi_wlast_INST_0_i_2_n_0));
  LUT5 #(
    .INIT(32'hFFFACCFA)) 
    m_axi_wlast_INST_0_i_3
       (.I0(\length_counter_1_reg[1]_0 [1]),
        .I1(dout[1]),
        .I2(\length_counter_1_reg[1]_0 [0]),
        .I3(first_mi_word),
        .I4(dout[0]),
        .O(m_axi_wlast_INST_0_i_3_n_0));
endmodule

(* CHECK_LICENSE_TYPE = "design_1_auto_pc_1,axi_protocol_converter_v2_1_29_axi_protocol_converter,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* X_CORE_INFO = "axi_protocol_converter_v2_1_29_axi_protocol_converter,Vivado 2023.2" *) 
(* NotValidForBitStream *)
module design_1_auto_pc_1
   (aclk,
    aresetn,
    s_axi_awaddr,
    s_axi_awlen,
    s_axi_awsize,
    s_axi_awburst,
    s_axi_awlock,
    s_axi_awcache,
    s_axi_awprot,
    s_axi_awregion,
    s_axi_awqos,
    s_axi_awvalid,
    s_axi_awready,
    s_axi_wdata,
    s_axi_wstrb,
    s_axi_wlast,
    s_axi_wvalid,
    s_axi_wready,
    s_axi_bresp,
    s_axi_bvalid,
    s_axi_bready,
    m_axi_awaddr,
    m_axi_awlen,
    m_axi_awsize,
    m_axi_awburst,
    m_axi_awlock,
    m_axi_awcache,
    m_axi_awprot,
    m_axi_awqos,
    m_axi_awvalid,
    m_axi_awready,
    m_axi_wdata,
    m_axi_wstrb,
    m_axi_wlast,
    m_axi_wvalid,
    m_axi_wready,
    m_axi_bresp,
    m_axi_bvalid,
    m_axi_bready);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, ASSOCIATED_BUSIF S_AXI:M_AXI, ASSOCIATED_RESET ARESETN, INSERT_VIP 0" *) input aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST, POLARITY ACTIVE_LOW, INSERT_VIP 0, TYPE INTERCONNECT" *) input aresetn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWADDR" *) input [31:0]s_axi_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWLEN" *) input [7:0]s_axi_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWSIZE" *) input [2:0]s_axi_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWBURST" *) input [1:0]s_axi_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWLOCK" *) input [0:0]s_axi_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWCACHE" *) input [3:0]s_axi_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWPROT" *) input [2:0]s_axi_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWREGION" *) input [3:0]s_axi_awregion;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWQOS" *) input [3:0]s_axi_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWVALID" *) input s_axi_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWREADY" *) output s_axi_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WDATA" *) input [31:0]s_axi_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WSTRB" *) input [3:0]s_axi_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WLAST" *) input s_axi_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WVALID" *) input s_axi_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WREADY" *) output s_axi_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BRESP" *) output [1:0]s_axi_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BVALID" *) output s_axi_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BREADY" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI, DATA_WIDTH 32, PROTOCOL AXI4, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE WRITE_ONLY, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 1, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 0, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 8, NUM_WRITE_OUTSTANDING 8, MAX_BURST_LENGTH 32, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) input s_axi_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWADDR" *) output [31:0]m_axi_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWLEN" *) output [3:0]m_axi_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWSIZE" *) output [2:0]m_axi_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWBURST" *) output [1:0]m_axi_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWLOCK" *) output [1:0]m_axi_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWCACHE" *) output [3:0]m_axi_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWPROT" *) output [2:0]m_axi_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWQOS" *) output [3:0]m_axi_awqos;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWVALID" *) output m_axi_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI AWREADY" *) input m_axi_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WDATA" *) output [31:0]m_axi_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WSTRB" *) output [3:0]m_axi_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WLAST" *) output m_axi_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WVALID" *) output m_axi_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI WREADY" *) input m_axi_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BRESP" *) input [1:0]m_axi_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BVALID" *) input m_axi_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 M_AXI BREADY" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXI, DATA_WIDTH 32, PROTOCOL AXI3, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE WRITE_ONLY, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 0, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 8, NUM_WRITE_OUTSTANDING 8, MAX_BURST_LENGTH 16, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) output m_axi_bready;

  wire \<const0> ;
  wire aclk;
  wire aresetn;
  wire [31:0]m_axi_awaddr;
  wire [1:0]m_axi_awburst;
  wire [3:0]m_axi_awcache;
  wire [3:0]m_axi_awlen;
  wire [0:0]\^m_axi_awlock ;
  wire [2:0]m_axi_awprot;
  wire [3:0]m_axi_awqos;
  wire m_axi_awready;
  wire [2:0]m_axi_awsize;
  wire m_axi_awvalid;
  wire m_axi_bready;
  wire [1:0]m_axi_bresp;
  wire m_axi_bvalid;
  wire [31:0]m_axi_wdata;
  wire m_axi_wlast;
  wire m_axi_wready;
  wire [3:0]m_axi_wstrb;
  wire m_axi_wvalid;
  wire [31:0]s_axi_awaddr;
  wire [1:0]s_axi_awburst;
  wire [3:0]s_axi_awcache;
  wire [7:0]s_axi_awlen;
  wire [0:0]s_axi_awlock;
  wire [2:0]s_axi_awprot;
  wire [3:0]s_axi_awqos;
  wire s_axi_awready;
  wire [2:0]s_axi_awsize;
  wire s_axi_awvalid;
  wire s_axi_bready;
  wire [1:0]s_axi_bresp;
  wire s_axi_bvalid;
  wire [31:0]s_axi_wdata;
  wire s_axi_wready;
  wire [3:0]s_axi_wstrb;
  wire s_axi_wvalid;
  wire NLW_inst_m_axi_arvalid_UNCONNECTED;
  wire NLW_inst_m_axi_rready_UNCONNECTED;
  wire NLW_inst_s_axi_arready_UNCONNECTED;
  wire NLW_inst_s_axi_rlast_UNCONNECTED;
  wire NLW_inst_s_axi_rvalid_UNCONNECTED;
  wire [31:0]NLW_inst_m_axi_araddr_UNCONNECTED;
  wire [1:0]NLW_inst_m_axi_arburst_UNCONNECTED;
  wire [3:0]NLW_inst_m_axi_arcache_UNCONNECTED;
  wire [0:0]NLW_inst_m_axi_arid_UNCONNECTED;
  wire [3:0]NLW_inst_m_axi_arlen_UNCONNECTED;
  wire [1:0]NLW_inst_m_axi_arlock_UNCONNECTED;
  wire [2:0]NLW_inst_m_axi_arprot_UNCONNECTED;
  wire [3:0]NLW_inst_m_axi_arqos_UNCONNECTED;
  wire [3:0]NLW_inst_m_axi_arregion_UNCONNECTED;
  wire [2:0]NLW_inst_m_axi_arsize_UNCONNECTED;
  wire [0:0]NLW_inst_m_axi_aruser_UNCONNECTED;
  wire [0:0]NLW_inst_m_axi_awid_UNCONNECTED;
  wire [1:1]NLW_inst_m_axi_awlock_UNCONNECTED;
  wire [3:0]NLW_inst_m_axi_awregion_UNCONNECTED;
  wire [0:0]NLW_inst_m_axi_awuser_UNCONNECTED;
  wire [0:0]NLW_inst_m_axi_wid_UNCONNECTED;
  wire [0:0]NLW_inst_m_axi_wuser_UNCONNECTED;
  wire [0:0]NLW_inst_s_axi_bid_UNCONNECTED;
  wire [0:0]NLW_inst_s_axi_buser_UNCONNECTED;
  wire [31:0]NLW_inst_s_axi_rdata_UNCONNECTED;
  wire [0:0]NLW_inst_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_inst_s_axi_rresp_UNCONNECTED;
  wire [0:0]NLW_inst_s_axi_ruser_UNCONNECTED;

  assign m_axi_awlock[1] = \<const0> ;
  assign m_axi_awlock[0] = \^m_axi_awlock [0];
  GND GND
       (.G(\<const0> ));
  (* C_AXI_ADDR_WIDTH = "32" *) 
  (* C_AXI_ARUSER_WIDTH = "1" *) 
  (* C_AXI_AWUSER_WIDTH = "1" *) 
  (* C_AXI_BUSER_WIDTH = "1" *) 
  (* C_AXI_DATA_WIDTH = "32" *) 
  (* C_AXI_ID_WIDTH = "1" *) 
  (* C_AXI_RUSER_WIDTH = "1" *) 
  (* C_AXI_SUPPORTS_READ = "0" *) 
  (* C_AXI_SUPPORTS_USER_SIGNALS = "0" *) 
  (* C_AXI_SUPPORTS_WRITE = "1" *) 
  (* C_AXI_WUSER_WIDTH = "1" *) 
  (* C_FAMILY = "zynq" *) 
  (* C_IGNORE_ID = "1" *) 
  (* C_M_AXI_PROTOCOL = "1" *) 
  (* C_S_AXI_PROTOCOL = "0" *) 
  (* C_TRANSLATION_MODE = "0" *) 
  (* P_AXI3 = "1" *) 
  (* P_AXI4 = "0" *) 
  (* P_AXILITE = "2" *) 
  (* P_AXILITE_SIZE = "3'b010" *) 
  (* P_CONVERSION = "2" *) 
  (* P_DECERR = "2'b11" *) 
  (* P_INCR = "2'b01" *) 
  (* P_PROTECTION = "1" *) 
  (* P_SLVERR = "2'b10" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  design_1_auto_pc_1_axi_protocol_converter_v2_1_29_axi_protocol_converter inst
       (.aclk(aclk),
        .aresetn(aresetn),
        .m_axi_araddr(NLW_inst_m_axi_araddr_UNCONNECTED[31:0]),
        .m_axi_arburst(NLW_inst_m_axi_arburst_UNCONNECTED[1:0]),
        .m_axi_arcache(NLW_inst_m_axi_arcache_UNCONNECTED[3:0]),
        .m_axi_arid(NLW_inst_m_axi_arid_UNCONNECTED[0]),
        .m_axi_arlen(NLW_inst_m_axi_arlen_UNCONNECTED[3:0]),
        .m_axi_arlock(NLW_inst_m_axi_arlock_UNCONNECTED[1:0]),
        .m_axi_arprot(NLW_inst_m_axi_arprot_UNCONNECTED[2:0]),
        .m_axi_arqos(NLW_inst_m_axi_arqos_UNCONNECTED[3:0]),
        .m_axi_arready(1'b0),
        .m_axi_arregion(NLW_inst_m_axi_arregion_UNCONNECTED[3:0]),
        .m_axi_arsize(NLW_inst_m_axi_arsize_UNCONNECTED[2:0]),
        .m_axi_aruser(NLW_inst_m_axi_aruser_UNCONNECTED[0]),
        .m_axi_arvalid(NLW_inst_m_axi_arvalid_UNCONNECTED),
        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awburst(m_axi_awburst),
        .m_axi_awcache(m_axi_awcache),
        .m_axi_awid(NLW_inst_m_axi_awid_UNCONNECTED[0]),
        .m_axi_awlen(m_axi_awlen),
        .m_axi_awlock({NLW_inst_m_axi_awlock_UNCONNECTED[1],\^m_axi_awlock }),
        .m_axi_awprot(m_axi_awprot),
        .m_axi_awqos(m_axi_awqos),
        .m_axi_awready(m_axi_awready),
        .m_axi_awregion(NLW_inst_m_axi_awregion_UNCONNECTED[3:0]),
        .m_axi_awsize(m_axi_awsize),
        .m_axi_awuser(NLW_inst_m_axi_awuser_UNCONNECTED[0]),
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_bid(1'b0),
        .m_axi_bready(m_axi_bready),
        .m_axi_bresp(m_axi_bresp),
        .m_axi_buser(1'b0),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_axi_rid(1'b0),
        .m_axi_rlast(1'b1),
        .m_axi_rready(NLW_inst_m_axi_rready_UNCONNECTED),
        .m_axi_rresp({1'b0,1'b0}),
        .m_axi_ruser(1'b0),
        .m_axi_rvalid(1'b0),
        .m_axi_wdata(m_axi_wdata),
        .m_axi_wid(NLW_inst_m_axi_wid_UNCONNECTED[0]),
        .m_axi_wlast(m_axi_wlast),
        .m_axi_wready(m_axi_wready),
        .m_axi_wstrb(m_axi_wstrb),
        .m_axi_wuser(NLW_inst_m_axi_wuser_UNCONNECTED[0]),
        .m_axi_wvalid(m_axi_wvalid),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b1}),
        .s_axi_arcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arid(1'b0),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlock(1'b0),
        .s_axi_arprot({1'b0,1'b0,1'b0}),
        .s_axi_arqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_inst_s_axi_arready_UNCONNECTED),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_aruser(1'b0),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awburst(s_axi_awburst),
        .s_axi_awcache(s_axi_awcache),
        .s_axi_awid(1'b0),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,s_axi_awlen[3:0]}),
        .s_axi_awlock(s_axi_awlock),
        .s_axi_awprot(s_axi_awprot),
        .s_axi_awqos(s_axi_awqos),
        .s_axi_awready(s_axi_awready),
        .s_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awsize(s_axi_awsize),
        .s_axi_awuser(1'b0),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_bid(NLW_inst_s_axi_bid_UNCONNECTED[0]),
        .s_axi_bready(s_axi_bready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_buser(NLW_inst_s_axi_buser_UNCONNECTED[0]),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_rdata(NLW_inst_s_axi_rdata_UNCONNECTED[31:0]),
        .s_axi_rid(NLW_inst_s_axi_rid_UNCONNECTED[0]),
        .s_axi_rlast(NLW_inst_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_inst_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_ruser(NLW_inst_s_axi_ruser_UNCONNECTED[0]),
        .s_axi_rvalid(NLW_inst_s_axi_rvalid_UNCONNECTED),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wid(1'b0),
        .s_axi_wlast(1'b0),
        .s_axi_wready(s_axi_wready),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wuser(1'b0),
        .s_axi_wvalid(s_axi_wvalid));
endmodule

(* DEF_VAL = "1'b0" *) (* DEST_SYNC_FF = "2" *) (* INIT_SYNC_FF = "0" *) 
(* INV_DEF_VAL = "1'b1" *) (* RST_ACTIVE_HIGH = "1" *) (* VERSION = "0" *) 
(* XPM_MODULE = "TRUE" *) (* is_du_within_envelope = "true" *) (* keep_hierarchy = "true" *) 
(* xpm_cdc = "ASYNC_RST" *) 
module design_1_auto_pc_1_xpm_cdc_async_rst
   (src_arst,
    dest_clk,
    dest_arst);
  input src_arst;
  input dest_clk;
  output dest_arst;

  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "ASYNC_RST" *) wire [1:0]arststages_ff;
  wire dest_clk;
  wire src_arst;

  assign dest_arst = arststages_ff[1];
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "ASYNC_RST" *) 
  FDPE #(
    .INIT(1'b0)) 
    \arststages_ff_reg[0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(1'b0),
        .PRE(src_arst),
        .Q(arststages_ff[0]));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "ASYNC_RST" *) 
  FDPE #(
    .INIT(1'b0)) 
    \arststages_ff_reg[1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(arststages_ff[0]),
        .PRE(src_arst),
        .Q(arststages_ff[1]));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2023.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
gcDjvJ18gZEH8C+LHMq/N7AaYWSyHgvjIQn585rdUOTVX2orO9n8j6LNiga3BYkS91+lbHAjAieW
oD/8serz9uvKt9uVuyMIE6oOFFScZR6q2wQk1d1Qzq717+8yPCwgBT9HIhfJIHLujHt+cA2l2L5t
tux9aNBdVKkk1MHv7yY=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
exhH3ieiewq538XhQByQWj7PMh1Y+pzdDw+4bALHgOXUMTZleYL0Pvhip/E5VwYBOb3/5i/ElWf3
Vm6OeE9b1Jj8xb7x10akeyRaNdCJYAtTqgb7gFS/crjXeoaYKJgLqCiyaB7LdWR9BiZOWqxEPSxe
/lr/8F8psti0kra2jACCbz94iU3qDIdZWH5kqd21Pp2/YczWpJBQzh+bBz9V+EuMAeZIzY3x2GZy
jOMZPemqiqFhSEcDf09mKK3xKEUxE+TPz82hd9ZrF5OjFst6mWMVye10lkzmY5Hmmx5Y/PVgPx3R
fN0tTAZfIDGH/YUu758U8UWOIcMzBHF6rytqmg==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
Umfm0FNxPKfdryB9QccnkcrzqkPtalTpE+R0M3D9kxaXOa1YOGT+9jGc1TRZMLcN5NyGN3UIZcH4
LWFVfGg80k9RmFHBDZaHzOXaomQhoPSO++ArXvmvO5zgttfCHEl7jypYkuPgwfQMfjK7YII9Deex
KOC8JtqORVWmhq47cpQ=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
cm7WeJnXtFlUdJuJH7wHYfinJTaBhpglyFWD2YwmOuS4fmVA4nXbX0IMaU1F1WGO1VK25KlFf8Nm
w8L6BJ6ZpH12xPIl3J17rMT4/3KHv9tpBWqeC080GeV5nISo8JrhOpIKa4+HBHZ6lYLce8LBAu/Z
EiBmDqw22aLsAuPAzAMh9yuHT5rpX9ykD9u0uZ5UplK05S0TsvYMUqcHNQ2hijt/lbxvUxXHTa+W
GJ5RRQAdw98wG1mc65u16hfZPsLimnw4BHwpyNGOPadShqb78rQihc+YiBTn4lgN1HhquWRGqCYZ
ZEjBmtWOJm8WJSTWtcpFEkmPlOTDmNX82e9mnw==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
a1mMNsEVIHwFCxw3sHygQ6eU3z5whgDQI+YHUmPAwU6q4vqfu2NVxu0z42QL1rV1rCsm39SqZ078
EGEqt7XUt6bdvI3yu4dU8gF+jou5njJ2UU34VmbOw/MQt48Hmi+hxtH1/zSlbNe2iOksDFEFTHmW
WGHgPS2bACG/KtAZMYK3gBtbnb9dtu+p5hxiQtwMOFnv9kQGBxcMaciN0yqy2TE5fygwKcNEua29
jiGUF0qgPS1k6qN+zLrYWkaVT0amR1MFXpv0WcwL+xVkxj6bBQhe5D7t5xCIsfLR4xqa5WVpa0dN
FkxGlIoufL17G/cGRr4nV4QP0sqcDCCHYpRoIA==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2022_10", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
rPFWI49JcHqYFxRrTG2uFixmE4jeIWIero9KijBFo7+FOCC7hJeSlCuNlwb8mBsI0Up57fm7C8t9
tb1l2QCfvy82JqTvEuH49UmS+8/GEnbK1QbVHsDIiv3/8cFn+0zw/VSuVeaN8L0yzeNIo8m59iAq
AQ9wOyqKFEhKKkbn+nVg+hQW3L/P25hisjV06sqmfsA0Rx4bYhFoxEvIw3A4x9LsBIIfDpgDsPzS
NICAEhfA7fWXKK6UsOmuq1NZLTDmFe2zEHijVMovzm/qqvHfu7fCt5POlGtLOPZhXGCDZi0v1yiq
VyT7JTUW5P/rcLgzkfyKToozq36lEkXd6VSaLg==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
T4EV2kKcg5a7rlvEGr4AG3uvv0JzSoc0NQb9aIeE2gsKGq0oLel4q0oZ7eO6He8noW5KEowgkY0O
xDnerk/R4qxdSePYeRRmUg3KZ7hAHVEQrHpQ2RbYwK5mUIpQLjxCWRWzBjeWOce2bh0dAMR/4OH6
t95V8b9VWpgepcUXynGvLDv31tVgr+8LtXlgWTNBiJj2mTZ3gEVxpgGRwMGsampw9yKqBKoR+/hg
++FP8JJkrOSdB2bhnNaD4fZotMLkhYDrWvQm9z6rW7fwxA2oEI+oUqi+K+82oiLzeVWy7FhVyzgS
Y273uSE53DWk35UE9A6ebcI/xUl1iGqwdeZihA==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
gZRrJLrBkbil4BLf1tia07NzGL28f+Pk9zyPElbTDf8NEXCsuwTum6RjR5lvY/odzAYHlcKxpG+6
gwjafT2OV5gHqqtPXrRHcVU4p5LEzOOl5p3puqvK+1z2+YpHqxOZIIZPIH9kjtzNgcBmcU7S2sFN
zTxyAYuLL9sAN+AIQ9UrW4MXDWxUtdkwPaSyFIvuKoxOKUD5IXEY9NtBpz1zsABMKNHneOO8pAix
qg8S/uQ/XJ8Qggr+vE7HDUUMCsijNXvqbkLM3xf6dXFpOqanKxd6/GfTcob4sezm/hMOZ2xiXcfS
hsYUMRdO9H6fmhECfszoK2XMsMt6xM+vlLywWJ0I6u468qVFxROkf9vL+ZDq/tMiJOm7E1p+HDif
98f5v1OybtzlZJP9bDMwWYcsCqcDejCMQyYOgPCgg+2jTR1JezxuK7PpjyliT0rnu7FfI/0tRzbL
d5YqO79RN0byWVTTdIlTWzL/qBD8BLVqXzWs3M+up46dGPxbkzv44od4

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
A79lFm/8JnoMxv1MOWkY+AtU24uc6/CeGf6bjoYWLJXkzzHQooKleg9l+jH7oajoC3oVQh/sMXdi
3QmwZ5SKMt6sb03SC5BW7xPky8zyP6w8FRMCI2Tz1/GhozqjIbgSstUfCaemxIgj3rG7GkRYZ/2k
ualG2mpYDNyaxz1lMYaHfm7stH/IQlkCh6HHMbi7ImYJ6pILa828Ls3VREjo7dtXPS2ZDFxreSIH
2SZ3NpLJO0/umchZaUkt1xN0bsxgtGdOzSqGDpTJrU/ltmclBX199pmrXQa5p/q0FSLj2WkB043l
l3x1Rdipn49DvChkvbVzJP9aej4kwSPhvxHnHQ==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
GFpXmWYmUY46GvuVucUW1VOu3+gGtLxYW4Ho/p4wggZ+jWrpUVhz2RSAxu+ufiLHtM9oYgKPaSYT
DOeuIJGTnxGr20Vh6Nn3cc41TyKAf0vxN2fGISEQQWrjh9OOgNcBmJfaHsSq7+5dhCaIWlGrInVr
GD5TqclLzw6cHAuPGxMi2wD4rq16RkDJnQbPf8ptaskWz81NxZfyWAL4T2E24soybpln8+vuF+72
IQYfLQh/dDDsNHKNKwTKAtGjpFS8eVSbYnS+k3Am4loN8JRflh0+c4yGUo4EkuRzUFiIBrJOKylp
qicgwQw7vdbe+yPl6moUlvA1U2CjJ87bsXk5CA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Hzklq501x4qEym07A6+Vh+O6T5Q1srpTjckVi/KQ8/P6I6xpFqHBBikoKASz9mkWuvFaf6aly934
etGfnzZuPuKCoMPixevIcq9cgFblu43p0H0FR4BSbqN+A/K2utwAblPur01qwtH9nc1azxOtPedI
3KLsEBUN2ObidzkZIUbiQlQ72wru0lGZ5uN6iiNcLRnEhqjdjWiOHf5qGo+df2QyP6S5zRR7hGOd
N5h9/9towH2UQ++6hnOd4pjtl7PKHWlU92421M+LhruDkz4Bw6c7d7EVdbIcZ3ub+l/OnCyNwQsr
WUo2E+j4vd3zIVA0gzTA1oLX73BJ1oxwQdO3JA==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 71152)
`pragma protect data_block
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
tudGn83Gu12ZOczsTuBsEg==
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
