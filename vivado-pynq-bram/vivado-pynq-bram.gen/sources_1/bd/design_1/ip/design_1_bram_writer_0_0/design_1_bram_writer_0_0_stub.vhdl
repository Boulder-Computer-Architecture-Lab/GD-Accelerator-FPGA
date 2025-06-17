-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
-- Date        : Sat Jun 14 20:22:40 2025
-- Host        : drews_laptop running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/mrflu/Projects/vivado-pynq-bram/vivado-pynq-bram.gen/sources_1/bd/design_1/ip/design_1_bram_writer_0_0/design_1_bram_writer_0_0_stub.vhdl
-- Design      : design_1_bram_writer_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_1_bram_writer_0_0 is
  Port ( 
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    addr : out STD_LOGIC_VECTOR ( 10 downto 0 );
    din : out STD_LOGIC_VECTOR ( 31 downto 0 );
    we : out STD_LOGIC;
    enb : out STD_LOGIC
  );

end design_1_bram_writer_0_0;

architecture stub of design_1_bram_writer_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,rst,addr[10:0],din[31:0],we,enb";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "bram_writer,Vivado 2023.2";
begin
end;
