-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
-- Date        : Mon Jun 16 14:32:42 2025
-- Host        : drews_laptop running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim
--               c:/Users/mrflu/Projects/vivado-pynq-matrix-stream/vivado-pynq-matrix-stream.gen/sources_1/bd/design_1/ip/design_1_axi_stream_const_dou_0_0/design_1_axi_stream_const_dou_0_0_sim_netlist.vhdl
-- Design      : design_1_axi_stream_const_dou_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_axi_stream_const_dou_0_0 is
  port (
    aclk : in STD_LOGIC;
    aresetn : in STD_LOGIC;
    tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
    tvalid : out STD_LOGIC;
    tready : in STD_LOGIC;
    tlast : out STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of design_1_axi_stream_const_dou_0_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of design_1_axi_stream_const_dou_0_0 : entity is "design_1_axi_stream_const_dou_0_0,axi_stream_const_double_zero,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of design_1_axi_stream_const_dou_0_0 : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of design_1_axi_stream_const_dou_0_0 : entity is "module_ref";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of design_1_axi_stream_const_dou_0_0 : entity is "axi_stream_const_double_zero,Vivado 2023.2";
end design_1_axi_stream_const_dou_0_0;

architecture STRUCTURE of design_1_axi_stream_const_dou_0_0 is
  signal \<const0>\ : STD_LOGIC;
  signal \<const1>\ : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of aclk : signal is "xilinx.com:signal:clock:1.0 aclk CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of aclk : signal is "XIL_INTERFACENAME aclk, ASSOCIATED_BUSIF interface_axis, ASSOCIATED_RESET aresetn, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of aresetn : signal is "xilinx.com:signal:reset:1.0 aresetn RST";
  attribute X_INTERFACE_PARAMETER of aresetn : signal is "XIL_INTERFACENAME aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of tlast : signal is "xilinx.com:interface:axis:1.0 interface_axis TLAST";
  attribute X_INTERFACE_PARAMETER of tlast : signal is "XIL_INTERFACENAME interface_axis, TDATA_NUM_BYTES 8, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of tready : signal is "xilinx.com:interface:axis:1.0 interface_axis TREADY";
  attribute X_INTERFACE_INFO of tvalid : signal is "xilinx.com:interface:axis:1.0 interface_axis TVALID";
  attribute X_INTERFACE_INFO of tdata : signal is "xilinx.com:interface:axis:1.0 interface_axis TDATA";
begin
  tdata(63) <= \<const0>\;
  tdata(62) <= \<const0>\;
  tdata(61) <= \<const0>\;
  tdata(60) <= \<const0>\;
  tdata(59) <= \<const0>\;
  tdata(58) <= \<const0>\;
  tdata(57) <= \<const0>\;
  tdata(56) <= \<const0>\;
  tdata(55) <= \<const0>\;
  tdata(54) <= \<const0>\;
  tdata(53) <= \<const0>\;
  tdata(52) <= \<const0>\;
  tdata(51) <= \<const0>\;
  tdata(50) <= \<const0>\;
  tdata(49) <= \<const0>\;
  tdata(48) <= \<const0>\;
  tdata(47) <= \<const0>\;
  tdata(46) <= \<const0>\;
  tdata(45) <= \<const0>\;
  tdata(44) <= \<const0>\;
  tdata(43) <= \<const0>\;
  tdata(42) <= \<const0>\;
  tdata(41) <= \<const0>\;
  tdata(40) <= \<const0>\;
  tdata(39) <= \<const0>\;
  tdata(38) <= \<const0>\;
  tdata(37) <= \<const0>\;
  tdata(36) <= \<const0>\;
  tdata(35) <= \<const0>\;
  tdata(34) <= \<const0>\;
  tdata(33) <= \<const0>\;
  tdata(32) <= \<const0>\;
  tdata(31) <= \<const0>\;
  tdata(30) <= \<const0>\;
  tdata(29) <= \<const0>\;
  tdata(28) <= \<const0>\;
  tdata(27) <= \<const0>\;
  tdata(26) <= \<const0>\;
  tdata(25) <= \<const0>\;
  tdata(24) <= \<const0>\;
  tdata(23) <= \<const0>\;
  tdata(22) <= \<const0>\;
  tdata(21) <= \<const0>\;
  tdata(20) <= \<const0>\;
  tdata(19) <= \<const0>\;
  tdata(18) <= \<const0>\;
  tdata(17) <= \<const0>\;
  tdata(16) <= \<const0>\;
  tdata(15) <= \<const0>\;
  tdata(14) <= \<const0>\;
  tdata(13) <= \<const0>\;
  tdata(12) <= \<const0>\;
  tdata(11) <= \<const0>\;
  tdata(10) <= \<const0>\;
  tdata(9) <= \<const0>\;
  tdata(8) <= \<const0>\;
  tdata(7) <= \<const0>\;
  tdata(6) <= \<const0>\;
  tdata(5) <= \<const0>\;
  tdata(4) <= \<const0>\;
  tdata(3) <= \<const0>\;
  tdata(2) <= \<const0>\;
  tdata(1) <= \<const0>\;
  tdata(0) <= \<const0>\;
  tlast <= \<const1>\;
  tvalid <= \<const1>\;
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
VCC: unisim.vcomponents.VCC
     port map (
      P => \<const1>\
    );
end STRUCTURE;
