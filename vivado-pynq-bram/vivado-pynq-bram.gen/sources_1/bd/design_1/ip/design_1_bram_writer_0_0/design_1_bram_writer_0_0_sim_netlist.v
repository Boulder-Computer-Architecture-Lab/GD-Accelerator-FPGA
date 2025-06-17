// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Sat Jun 14 20:22:40 2025
// Host        : drews_laptop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/mrflu/Projects/vivado-pynq-bram/vivado-pynq-bram.gen/sources_1/bd/design_1/ip/design_1_bram_writer_0_0/design_1_bram_writer_0_0_sim_netlist.v
// Design      : design_1_bram_writer_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "design_1_bram_writer_0_0,bram_writer,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "package_project" *) 
(* X_CORE_INFO = "bram_writer,Vivado 2023.2" *) 
(* NotValidForBitStream *)
module design_1_bram_writer_0_0
   (clk,
    rst,
    addr,
    din,
    we,
    enb);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, ASSOCIATED_RESET rst, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input clk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 rst RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME rst, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input rst;
  output [10:0]addr;
  output [31:0]din;
  output we;
  output enb;

  wire \<const1> ;
  wire [10:0]addr;
  wire clk;
  wire [31:0]din;
  wire rst;
  wire we;

  assign enb = \<const1> ;
  VCC VCC
       (.P(\<const1> ));
  design_1_bram_writer_0_0_bram_writer inst
       (.addr(addr[9:0]),
        .\addr_reg[10]_0 (addr[10]),
        .clk(clk),
        .din(din),
        .rst(rst),
        .we(we));
endmodule

(* ORIG_REF_NAME = "bram_writer" *) 
module design_1_bram_writer_0_0_bram_writer
   (addr,
    \addr_reg[10]_0 ,
    din,
    we,
    rst,
    clk);
  output [9:0]addr;
  output \addr_reg[10]_0 ;
  output [31:0]din;
  output we;
  input rst;
  input clk;

  wire [9:0]addr;
  wire \addr[10]_i_1_n_0 ;
  wire \addr[9]_i_3_n_0 ;
  wire \addr_reg[10]_0 ;
  wire clk;
  wire [31:0]din;
  wire \din[3]_i_2_n_0 ;
  wire \din_reg[11]_i_1_n_0 ;
  wire \din_reg[11]_i_1_n_1 ;
  wire \din_reg[11]_i_1_n_2 ;
  wire \din_reg[11]_i_1_n_3 ;
  wire \din_reg[11]_i_1_n_4 ;
  wire \din_reg[11]_i_1_n_5 ;
  wire \din_reg[11]_i_1_n_6 ;
  wire \din_reg[11]_i_1_n_7 ;
  wire \din_reg[15]_i_1_n_0 ;
  wire \din_reg[15]_i_1_n_1 ;
  wire \din_reg[15]_i_1_n_2 ;
  wire \din_reg[15]_i_1_n_3 ;
  wire \din_reg[15]_i_1_n_4 ;
  wire \din_reg[15]_i_1_n_5 ;
  wire \din_reg[15]_i_1_n_6 ;
  wire \din_reg[15]_i_1_n_7 ;
  wire \din_reg[19]_i_1_n_0 ;
  wire \din_reg[19]_i_1_n_1 ;
  wire \din_reg[19]_i_1_n_2 ;
  wire \din_reg[19]_i_1_n_3 ;
  wire \din_reg[19]_i_1_n_4 ;
  wire \din_reg[19]_i_1_n_5 ;
  wire \din_reg[19]_i_1_n_6 ;
  wire \din_reg[19]_i_1_n_7 ;
  wire \din_reg[23]_i_1_n_0 ;
  wire \din_reg[23]_i_1_n_1 ;
  wire \din_reg[23]_i_1_n_2 ;
  wire \din_reg[23]_i_1_n_3 ;
  wire \din_reg[23]_i_1_n_4 ;
  wire \din_reg[23]_i_1_n_5 ;
  wire \din_reg[23]_i_1_n_6 ;
  wire \din_reg[23]_i_1_n_7 ;
  wire \din_reg[27]_i_1_n_0 ;
  wire \din_reg[27]_i_1_n_1 ;
  wire \din_reg[27]_i_1_n_2 ;
  wire \din_reg[27]_i_1_n_3 ;
  wire \din_reg[27]_i_1_n_4 ;
  wire \din_reg[27]_i_1_n_5 ;
  wire \din_reg[27]_i_1_n_6 ;
  wire \din_reg[27]_i_1_n_7 ;
  wire \din_reg[31]_i_1_n_1 ;
  wire \din_reg[31]_i_1_n_2 ;
  wire \din_reg[31]_i_1_n_3 ;
  wire \din_reg[31]_i_1_n_4 ;
  wire \din_reg[31]_i_1_n_5 ;
  wire \din_reg[31]_i_1_n_6 ;
  wire \din_reg[31]_i_1_n_7 ;
  wire \din_reg[3]_i_1_n_0 ;
  wire \din_reg[3]_i_1_n_1 ;
  wire \din_reg[3]_i_1_n_2 ;
  wire \din_reg[3]_i_1_n_3 ;
  wire \din_reg[3]_i_1_n_4 ;
  wire \din_reg[3]_i_1_n_5 ;
  wire \din_reg[3]_i_1_n_6 ;
  wire \din_reg[3]_i_1_n_7 ;
  wire \din_reg[7]_i_1_n_0 ;
  wire \din_reg[7]_i_1_n_1 ;
  wire \din_reg[7]_i_1_n_2 ;
  wire \din_reg[7]_i_1_n_3 ;
  wire \din_reg[7]_i_1_n_4 ;
  wire \din_reg[7]_i_1_n_5 ;
  wire \din_reg[7]_i_1_n_6 ;
  wire \din_reg[7]_i_1_n_7 ;
  wire [10:0]p_0_in;
  wire rst;
  wire sel;
  wire we;
  wire we_i_1_n_0;
  wire [3:3]\NLW_din_reg[31]_i_1_CO_UNCONNECTED ;

  LUT1 #(
    .INIT(2'h1)) 
    \addr[0]_i_1 
       (.I0(addr[0]),
        .O(p_0_in[0]));
  LUT3 #(
    .INIT(8'hCA)) 
    \addr[10]_i_1 
       (.I0(\addr_reg[10]_0 ),
        .I1(p_0_in[10]),
        .I2(sel),
        .O(\addr[10]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hF7FFFFFF08000000)) 
    \addr[10]_i_2 
       (.I0(addr[9]),
        .I1(addr[7]),
        .I2(\addr[9]_i_3_n_0 ),
        .I3(addr[6]),
        .I4(addr[8]),
        .I5(\addr_reg[10]_0 ),
        .O(p_0_in[10]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \addr[1]_i_1 
       (.I0(addr[0]),
        .I1(addr[1]),
        .O(p_0_in[1]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \addr[2]_i_1 
       (.I0(addr[1]),
        .I1(addr[0]),
        .I2(addr[2]),
        .O(p_0_in[2]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h7F80)) 
    \addr[3]_i_1 
       (.I0(addr[2]),
        .I1(addr[0]),
        .I2(addr[1]),
        .I3(addr[3]),
        .O(p_0_in[3]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h7FFF8000)) 
    \addr[4]_i_1 
       (.I0(addr[3]),
        .I1(addr[1]),
        .I2(addr[0]),
        .I3(addr[2]),
        .I4(addr[4]),
        .O(p_0_in[4]));
  LUT6 #(
    .INIT(64'h7FFFFFFF80000000)) 
    \addr[5]_i_1 
       (.I0(addr[4]),
        .I1(addr[2]),
        .I2(addr[0]),
        .I3(addr[1]),
        .I4(addr[3]),
        .I5(addr[5]),
        .O(p_0_in[5]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT2 #(
    .INIT(4'h9)) 
    \addr[6]_i_1 
       (.I0(\addr[9]_i_3_n_0 ),
        .I1(addr[6]),
        .O(p_0_in[6]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT3 #(
    .INIT(8'hD2)) 
    \addr[7]_i_1 
       (.I0(addr[6]),
        .I1(\addr[9]_i_3_n_0 ),
        .I2(addr[7]),
        .O(p_0_in[7]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'hDF20)) 
    \addr[8]_i_1 
       (.I0(addr[7]),
        .I1(\addr[9]_i_3_n_0 ),
        .I2(addr[6]),
        .I3(addr[8]),
        .O(p_0_in[8]));
  LUT6 #(
    .INIT(64'hF7FFFFFFFFFFFFFF)) 
    \addr[9]_i_1 
       (.I0(addr[9]),
        .I1(addr[7]),
        .I2(\addr[9]_i_3_n_0 ),
        .I3(addr[6]),
        .I4(addr[8]),
        .I5(\addr_reg[10]_0 ),
        .O(sel));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'hF7FF0800)) 
    \addr[9]_i_2 
       (.I0(addr[8]),
        .I1(addr[6]),
        .I2(\addr[9]_i_3_n_0 ),
        .I3(addr[7]),
        .I4(addr[9]),
        .O(p_0_in[9]));
  LUT6 #(
    .INIT(64'h7FFFFFFFFFFFFFFF)) 
    \addr[9]_i_3 
       (.I0(addr[4]),
        .I1(addr[2]),
        .I2(addr[0]),
        .I3(addr[1]),
        .I4(addr[3]),
        .I5(addr[5]),
        .O(\addr[9]_i_3_n_0 ));
  FDRE \addr_reg[0] 
       (.C(clk),
        .CE(sel),
        .D(p_0_in[0]),
        .Q(addr[0]),
        .R(rst));
  FDRE \addr_reg[10] 
       (.C(clk),
        .CE(1'b1),
        .D(\addr[10]_i_1_n_0 ),
        .Q(\addr_reg[10]_0 ),
        .R(rst));
  FDRE \addr_reg[1] 
       (.C(clk),
        .CE(sel),
        .D(p_0_in[1]),
        .Q(addr[1]),
        .R(rst));
  FDRE \addr_reg[2] 
       (.C(clk),
        .CE(sel),
        .D(p_0_in[2]),
        .Q(addr[2]),
        .R(rst));
  FDRE \addr_reg[3] 
       (.C(clk),
        .CE(sel),
        .D(p_0_in[3]),
        .Q(addr[3]),
        .R(rst));
  FDRE \addr_reg[4] 
       (.C(clk),
        .CE(sel),
        .D(p_0_in[4]),
        .Q(addr[4]),
        .R(rst));
  FDRE \addr_reg[5] 
       (.C(clk),
        .CE(sel),
        .D(p_0_in[5]),
        .Q(addr[5]),
        .R(rst));
  FDRE \addr_reg[6] 
       (.C(clk),
        .CE(sel),
        .D(p_0_in[6]),
        .Q(addr[6]),
        .R(rst));
  FDRE \addr_reg[7] 
       (.C(clk),
        .CE(sel),
        .D(p_0_in[7]),
        .Q(addr[7]),
        .R(rst));
  FDRE \addr_reg[8] 
       (.C(clk),
        .CE(sel),
        .D(p_0_in[8]),
        .Q(addr[8]),
        .R(rst));
  FDRE \addr_reg[9] 
       (.C(clk),
        .CE(sel),
        .D(p_0_in[9]),
        .Q(addr[9]),
        .R(rst));
  LUT1 #(
    .INIT(2'h1)) 
    \din[3]_i_2 
       (.I0(din[0]),
        .O(\din[3]_i_2_n_0 ));
  FDRE \din_reg[0] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[3]_i_1_n_7 ),
        .Q(din[0]),
        .R(rst));
  FDRE \din_reg[10] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[11]_i_1_n_5 ),
        .Q(din[10]),
        .R(rst));
  FDRE \din_reg[11] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[11]_i_1_n_4 ),
        .Q(din[11]),
        .R(rst));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \din_reg[11]_i_1 
       (.CI(\din_reg[7]_i_1_n_0 ),
        .CO({\din_reg[11]_i_1_n_0 ,\din_reg[11]_i_1_n_1 ,\din_reg[11]_i_1_n_2 ,\din_reg[11]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\din_reg[11]_i_1_n_4 ,\din_reg[11]_i_1_n_5 ,\din_reg[11]_i_1_n_6 ,\din_reg[11]_i_1_n_7 }),
        .S(din[11:8]));
  FDRE \din_reg[12] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[15]_i_1_n_7 ),
        .Q(din[12]),
        .R(rst));
  FDRE \din_reg[13] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[15]_i_1_n_6 ),
        .Q(din[13]),
        .R(rst));
  FDRE \din_reg[14] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[15]_i_1_n_5 ),
        .Q(din[14]),
        .R(rst));
  FDRE \din_reg[15] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[15]_i_1_n_4 ),
        .Q(din[15]),
        .R(rst));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \din_reg[15]_i_1 
       (.CI(\din_reg[11]_i_1_n_0 ),
        .CO({\din_reg[15]_i_1_n_0 ,\din_reg[15]_i_1_n_1 ,\din_reg[15]_i_1_n_2 ,\din_reg[15]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\din_reg[15]_i_1_n_4 ,\din_reg[15]_i_1_n_5 ,\din_reg[15]_i_1_n_6 ,\din_reg[15]_i_1_n_7 }),
        .S(din[15:12]));
  FDRE \din_reg[16] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[19]_i_1_n_7 ),
        .Q(din[16]),
        .R(rst));
  FDRE \din_reg[17] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[19]_i_1_n_6 ),
        .Q(din[17]),
        .R(rst));
  FDRE \din_reg[18] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[19]_i_1_n_5 ),
        .Q(din[18]),
        .R(rst));
  FDRE \din_reg[19] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[19]_i_1_n_4 ),
        .Q(din[19]),
        .R(rst));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \din_reg[19]_i_1 
       (.CI(\din_reg[15]_i_1_n_0 ),
        .CO({\din_reg[19]_i_1_n_0 ,\din_reg[19]_i_1_n_1 ,\din_reg[19]_i_1_n_2 ,\din_reg[19]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\din_reg[19]_i_1_n_4 ,\din_reg[19]_i_1_n_5 ,\din_reg[19]_i_1_n_6 ,\din_reg[19]_i_1_n_7 }),
        .S(din[19:16]));
  FDRE \din_reg[1] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[3]_i_1_n_6 ),
        .Q(din[1]),
        .R(rst));
  FDRE \din_reg[20] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[23]_i_1_n_7 ),
        .Q(din[20]),
        .R(rst));
  FDRE \din_reg[21] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[23]_i_1_n_6 ),
        .Q(din[21]),
        .R(rst));
  FDRE \din_reg[22] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[23]_i_1_n_5 ),
        .Q(din[22]),
        .R(rst));
  FDRE \din_reg[23] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[23]_i_1_n_4 ),
        .Q(din[23]),
        .R(rst));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \din_reg[23]_i_1 
       (.CI(\din_reg[19]_i_1_n_0 ),
        .CO({\din_reg[23]_i_1_n_0 ,\din_reg[23]_i_1_n_1 ,\din_reg[23]_i_1_n_2 ,\din_reg[23]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\din_reg[23]_i_1_n_4 ,\din_reg[23]_i_1_n_5 ,\din_reg[23]_i_1_n_6 ,\din_reg[23]_i_1_n_7 }),
        .S(din[23:20]));
  FDRE \din_reg[24] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[27]_i_1_n_7 ),
        .Q(din[24]),
        .R(rst));
  FDRE \din_reg[25] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[27]_i_1_n_6 ),
        .Q(din[25]),
        .R(rst));
  FDRE \din_reg[26] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[27]_i_1_n_5 ),
        .Q(din[26]),
        .R(rst));
  FDRE \din_reg[27] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[27]_i_1_n_4 ),
        .Q(din[27]),
        .R(rst));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \din_reg[27]_i_1 
       (.CI(\din_reg[23]_i_1_n_0 ),
        .CO({\din_reg[27]_i_1_n_0 ,\din_reg[27]_i_1_n_1 ,\din_reg[27]_i_1_n_2 ,\din_reg[27]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\din_reg[27]_i_1_n_4 ,\din_reg[27]_i_1_n_5 ,\din_reg[27]_i_1_n_6 ,\din_reg[27]_i_1_n_7 }),
        .S(din[27:24]));
  FDRE \din_reg[28] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[31]_i_1_n_7 ),
        .Q(din[28]),
        .R(rst));
  FDRE \din_reg[29] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[31]_i_1_n_6 ),
        .Q(din[29]),
        .R(rst));
  FDRE \din_reg[2] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[3]_i_1_n_5 ),
        .Q(din[2]),
        .R(rst));
  FDRE \din_reg[30] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[31]_i_1_n_5 ),
        .Q(din[30]),
        .R(rst));
  FDRE \din_reg[31] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[31]_i_1_n_4 ),
        .Q(din[31]),
        .R(rst));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \din_reg[31]_i_1 
       (.CI(\din_reg[27]_i_1_n_0 ),
        .CO({\NLW_din_reg[31]_i_1_CO_UNCONNECTED [3],\din_reg[31]_i_1_n_1 ,\din_reg[31]_i_1_n_2 ,\din_reg[31]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\din_reg[31]_i_1_n_4 ,\din_reg[31]_i_1_n_5 ,\din_reg[31]_i_1_n_6 ,\din_reg[31]_i_1_n_7 }),
        .S(din[31:28]));
  FDRE \din_reg[3] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[3]_i_1_n_4 ),
        .Q(din[3]),
        .R(rst));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \din_reg[3]_i_1 
       (.CI(1'b0),
        .CO({\din_reg[3]_i_1_n_0 ,\din_reg[3]_i_1_n_1 ,\din_reg[3]_i_1_n_2 ,\din_reg[3]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b1}),
        .O({\din_reg[3]_i_1_n_4 ,\din_reg[3]_i_1_n_5 ,\din_reg[3]_i_1_n_6 ,\din_reg[3]_i_1_n_7 }),
        .S({din[3:1],\din[3]_i_2_n_0 }));
  FDRE \din_reg[4] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[7]_i_1_n_7 ),
        .Q(din[4]),
        .R(rst));
  FDRE \din_reg[5] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[7]_i_1_n_6 ),
        .Q(din[5]),
        .R(rst));
  FDRE \din_reg[6] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[7]_i_1_n_5 ),
        .Q(din[6]),
        .R(rst));
  FDRE \din_reg[7] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[7]_i_1_n_4 ),
        .Q(din[7]),
        .R(rst));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \din_reg[7]_i_1 
       (.CI(\din_reg[3]_i_1_n_0 ),
        .CO({\din_reg[7]_i_1_n_0 ,\din_reg[7]_i_1_n_1 ,\din_reg[7]_i_1_n_2 ,\din_reg[7]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\din_reg[7]_i_1_n_4 ,\din_reg[7]_i_1_n_5 ,\din_reg[7]_i_1_n_6 ,\din_reg[7]_i_1_n_7 }),
        .S(din[7:4]));
  FDRE \din_reg[8] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[11]_i_1_n_7 ),
        .Q(din[8]),
        .R(rst));
  FDRE \din_reg[9] 
       (.C(clk),
        .CE(sel),
        .D(\din_reg[11]_i_1_n_6 ),
        .Q(din[9]),
        .R(rst));
  LUT2 #(
    .INIT(4'h2)) 
    we_i_1
       (.I0(sel),
        .I1(rst),
        .O(we_i_1_n_0));
  FDRE we_reg
       (.C(clk),
        .CE(1'b1),
        .D(we_i_1_n_0),
        .Q(we),
        .R(1'b0));
endmodule
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
