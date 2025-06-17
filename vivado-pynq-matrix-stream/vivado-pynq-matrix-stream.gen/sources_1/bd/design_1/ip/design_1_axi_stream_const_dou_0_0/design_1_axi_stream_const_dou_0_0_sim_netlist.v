// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
// Date        : Mon Jun 16 14:32:42 2025
// Host        : drews_laptop running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/mrflu/Projects/vivado-pynq-matrix-stream/vivado-pynq-matrix-stream.gen/sources_1/bd/design_1/ip/design_1_axi_stream_const_dou_0_0/design_1_axi_stream_const_dou_0_0_sim_netlist.v
// Design      : design_1_axi_stream_const_dou_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "design_1_axi_stream_const_dou_0_0,axi_stream_const_double_zero,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "axi_stream_const_double_zero,Vivado 2023.2" *) 
(* NotValidForBitStream *)
module design_1_axi_stream_const_dou_0_0
   (aclk,
    aresetn,
    tdata,
    tvalid,
    tready,
    tlast);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 aclk CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME aclk, ASSOCIATED_BUSIF interface_axis, ASSOCIATED_RESET aresetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0" *) input aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 aresetn RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input aresetn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 interface_axis TDATA" *) output [63:0]tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 interface_axis TVALID" *) output tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 interface_axis TREADY" *) input tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 interface_axis TLAST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME interface_axis, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0" *) output tlast;

  wire \<const0> ;
  wire \<const1> ;

  assign tdata[63] = \<const0> ;
  assign tdata[62] = \<const0> ;
  assign tdata[61] = \<const0> ;
  assign tdata[60] = \<const0> ;
  assign tdata[59] = \<const0> ;
  assign tdata[58] = \<const0> ;
  assign tdata[57] = \<const0> ;
  assign tdata[56] = \<const0> ;
  assign tdata[55] = \<const0> ;
  assign tdata[54] = \<const0> ;
  assign tdata[53] = \<const0> ;
  assign tdata[52] = \<const0> ;
  assign tdata[51] = \<const0> ;
  assign tdata[50] = \<const0> ;
  assign tdata[49] = \<const0> ;
  assign tdata[48] = \<const0> ;
  assign tdata[47] = \<const0> ;
  assign tdata[46] = \<const0> ;
  assign tdata[45] = \<const0> ;
  assign tdata[44] = \<const0> ;
  assign tdata[43] = \<const0> ;
  assign tdata[42] = \<const0> ;
  assign tdata[41] = \<const0> ;
  assign tdata[40] = \<const0> ;
  assign tdata[39] = \<const0> ;
  assign tdata[38] = \<const0> ;
  assign tdata[37] = \<const0> ;
  assign tdata[36] = \<const0> ;
  assign tdata[35] = \<const0> ;
  assign tdata[34] = \<const0> ;
  assign tdata[33] = \<const0> ;
  assign tdata[32] = \<const0> ;
  assign tdata[31] = \<const0> ;
  assign tdata[30] = \<const0> ;
  assign tdata[29] = \<const0> ;
  assign tdata[28] = \<const0> ;
  assign tdata[27] = \<const0> ;
  assign tdata[26] = \<const0> ;
  assign tdata[25] = \<const0> ;
  assign tdata[24] = \<const0> ;
  assign tdata[23] = \<const0> ;
  assign tdata[22] = \<const0> ;
  assign tdata[21] = \<const0> ;
  assign tdata[20] = \<const0> ;
  assign tdata[19] = \<const0> ;
  assign tdata[18] = \<const0> ;
  assign tdata[17] = \<const0> ;
  assign tdata[16] = \<const0> ;
  assign tdata[15] = \<const0> ;
  assign tdata[14] = \<const0> ;
  assign tdata[13] = \<const0> ;
  assign tdata[12] = \<const0> ;
  assign tdata[11] = \<const0> ;
  assign tdata[10] = \<const0> ;
  assign tdata[9] = \<const0> ;
  assign tdata[8] = \<const0> ;
  assign tdata[7] = \<const0> ;
  assign tdata[6] = \<const0> ;
  assign tdata[5] = \<const0> ;
  assign tdata[4] = \<const0> ;
  assign tdata[3] = \<const0> ;
  assign tdata[2] = \<const0> ;
  assign tdata[1] = \<const0> ;
  assign tdata[0] = \<const0> ;
  assign tlast = \<const1> ;
  assign tvalid = \<const1> ;
  GND GND
       (.G(\<const0> ));
  VCC VCC
       (.P(\<const1> ));
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
