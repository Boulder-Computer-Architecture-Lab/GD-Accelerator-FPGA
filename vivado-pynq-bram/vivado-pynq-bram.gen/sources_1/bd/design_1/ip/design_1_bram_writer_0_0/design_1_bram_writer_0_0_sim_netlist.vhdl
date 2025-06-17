-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2023.2 (win64) Build 4029153 Fri Oct 13 20:14:34 MDT 2023
-- Date        : Sat Jun 14 20:22:40 2025
-- Host        : drews_laptop running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim
--               c:/Users/mrflu/Projects/vivado-pynq-bram/vivado-pynq-bram.gen/sources_1/bd/design_1/ip/design_1_bram_writer_0_0/design_1_bram_writer_0_0_sim_netlist.vhdl
-- Design      : design_1_bram_writer_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_bram_writer_0_0_bram_writer is
  port (
    addr : out STD_LOGIC_VECTOR ( 9 downto 0 );
    \addr_reg[10]_0\ : out STD_LOGIC;
    din : out STD_LOGIC_VECTOR ( 31 downto 0 );
    we : out STD_LOGIC;
    rst : in STD_LOGIC;
    clk : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of design_1_bram_writer_0_0_bram_writer : entity is "bram_writer";
end design_1_bram_writer_0_0_bram_writer;

architecture STRUCTURE of design_1_bram_writer_0_0_bram_writer is
  signal \^addr\ : STD_LOGIC_VECTOR ( 9 downto 0 );
  signal \addr[10]_i_1_n_0\ : STD_LOGIC;
  signal \addr[9]_i_3_n_0\ : STD_LOGIC;
  signal \^addr_reg[10]_0\ : STD_LOGIC;
  signal \^din\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal \din[3]_i_2_n_0\ : STD_LOGIC;
  signal \din_reg[11]_i_1_n_0\ : STD_LOGIC;
  signal \din_reg[11]_i_1_n_1\ : STD_LOGIC;
  signal \din_reg[11]_i_1_n_2\ : STD_LOGIC;
  signal \din_reg[11]_i_1_n_3\ : STD_LOGIC;
  signal \din_reg[11]_i_1_n_4\ : STD_LOGIC;
  signal \din_reg[11]_i_1_n_5\ : STD_LOGIC;
  signal \din_reg[11]_i_1_n_6\ : STD_LOGIC;
  signal \din_reg[11]_i_1_n_7\ : STD_LOGIC;
  signal \din_reg[15]_i_1_n_0\ : STD_LOGIC;
  signal \din_reg[15]_i_1_n_1\ : STD_LOGIC;
  signal \din_reg[15]_i_1_n_2\ : STD_LOGIC;
  signal \din_reg[15]_i_1_n_3\ : STD_LOGIC;
  signal \din_reg[15]_i_1_n_4\ : STD_LOGIC;
  signal \din_reg[15]_i_1_n_5\ : STD_LOGIC;
  signal \din_reg[15]_i_1_n_6\ : STD_LOGIC;
  signal \din_reg[15]_i_1_n_7\ : STD_LOGIC;
  signal \din_reg[19]_i_1_n_0\ : STD_LOGIC;
  signal \din_reg[19]_i_1_n_1\ : STD_LOGIC;
  signal \din_reg[19]_i_1_n_2\ : STD_LOGIC;
  signal \din_reg[19]_i_1_n_3\ : STD_LOGIC;
  signal \din_reg[19]_i_1_n_4\ : STD_LOGIC;
  signal \din_reg[19]_i_1_n_5\ : STD_LOGIC;
  signal \din_reg[19]_i_1_n_6\ : STD_LOGIC;
  signal \din_reg[19]_i_1_n_7\ : STD_LOGIC;
  signal \din_reg[23]_i_1_n_0\ : STD_LOGIC;
  signal \din_reg[23]_i_1_n_1\ : STD_LOGIC;
  signal \din_reg[23]_i_1_n_2\ : STD_LOGIC;
  signal \din_reg[23]_i_1_n_3\ : STD_LOGIC;
  signal \din_reg[23]_i_1_n_4\ : STD_LOGIC;
  signal \din_reg[23]_i_1_n_5\ : STD_LOGIC;
  signal \din_reg[23]_i_1_n_6\ : STD_LOGIC;
  signal \din_reg[23]_i_1_n_7\ : STD_LOGIC;
  signal \din_reg[27]_i_1_n_0\ : STD_LOGIC;
  signal \din_reg[27]_i_1_n_1\ : STD_LOGIC;
  signal \din_reg[27]_i_1_n_2\ : STD_LOGIC;
  signal \din_reg[27]_i_1_n_3\ : STD_LOGIC;
  signal \din_reg[27]_i_1_n_4\ : STD_LOGIC;
  signal \din_reg[27]_i_1_n_5\ : STD_LOGIC;
  signal \din_reg[27]_i_1_n_6\ : STD_LOGIC;
  signal \din_reg[27]_i_1_n_7\ : STD_LOGIC;
  signal \din_reg[31]_i_1_n_1\ : STD_LOGIC;
  signal \din_reg[31]_i_1_n_2\ : STD_LOGIC;
  signal \din_reg[31]_i_1_n_3\ : STD_LOGIC;
  signal \din_reg[31]_i_1_n_4\ : STD_LOGIC;
  signal \din_reg[31]_i_1_n_5\ : STD_LOGIC;
  signal \din_reg[31]_i_1_n_6\ : STD_LOGIC;
  signal \din_reg[31]_i_1_n_7\ : STD_LOGIC;
  signal \din_reg[3]_i_1_n_0\ : STD_LOGIC;
  signal \din_reg[3]_i_1_n_1\ : STD_LOGIC;
  signal \din_reg[3]_i_1_n_2\ : STD_LOGIC;
  signal \din_reg[3]_i_1_n_3\ : STD_LOGIC;
  signal \din_reg[3]_i_1_n_4\ : STD_LOGIC;
  signal \din_reg[3]_i_1_n_5\ : STD_LOGIC;
  signal \din_reg[3]_i_1_n_6\ : STD_LOGIC;
  signal \din_reg[3]_i_1_n_7\ : STD_LOGIC;
  signal \din_reg[7]_i_1_n_0\ : STD_LOGIC;
  signal \din_reg[7]_i_1_n_1\ : STD_LOGIC;
  signal \din_reg[7]_i_1_n_2\ : STD_LOGIC;
  signal \din_reg[7]_i_1_n_3\ : STD_LOGIC;
  signal \din_reg[7]_i_1_n_4\ : STD_LOGIC;
  signal \din_reg[7]_i_1_n_5\ : STD_LOGIC;
  signal \din_reg[7]_i_1_n_6\ : STD_LOGIC;
  signal \din_reg[7]_i_1_n_7\ : STD_LOGIC;
  signal p_0_in : STD_LOGIC_VECTOR ( 10 downto 0 );
  signal sel : STD_LOGIC;
  signal we_i_1_n_0 : STD_LOGIC;
  signal \NLW_din_reg[31]_i_1_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 to 3 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \addr[1]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \addr[2]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \addr[3]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \addr[4]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \addr[6]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \addr[7]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \addr[8]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \addr[9]_i_2\ : label is "soft_lutpair1";
  attribute ADDER_THRESHOLD : integer;
  attribute ADDER_THRESHOLD of \din_reg[11]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \din_reg[15]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \din_reg[19]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \din_reg[23]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \din_reg[27]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \din_reg[31]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \din_reg[3]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \din_reg[7]_i_1\ : label is 11;
begin
  addr(9 downto 0) <= \^addr\(9 downto 0);
  \addr_reg[10]_0\ <= \^addr_reg[10]_0\;
  din(31 downto 0) <= \^din\(31 downto 0);
\addr[0]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^addr\(0),
      O => p_0_in(0)
    );
\addr[10]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"CA"
    )
        port map (
      I0 => \^addr_reg[10]_0\,
      I1 => p_0_in(10),
      I2 => sel,
      O => \addr[10]_i_1_n_0\
    );
\addr[10]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"F7FFFFFF08000000"
    )
        port map (
      I0 => \^addr\(9),
      I1 => \^addr\(7),
      I2 => \addr[9]_i_3_n_0\,
      I3 => \^addr\(6),
      I4 => \^addr\(8),
      I5 => \^addr_reg[10]_0\,
      O => p_0_in(10)
    );
\addr[1]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => \^addr\(0),
      I1 => \^addr\(1),
      O => p_0_in(1)
    );
\addr[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"78"
    )
        port map (
      I0 => \^addr\(1),
      I1 => \^addr\(0),
      I2 => \^addr\(2),
      O => p_0_in(2)
    );
\addr[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7F80"
    )
        port map (
      I0 => \^addr\(2),
      I1 => \^addr\(0),
      I2 => \^addr\(1),
      I3 => \^addr\(3),
      O => p_0_in(3)
    );
\addr[4]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"7FFF8000"
    )
        port map (
      I0 => \^addr\(3),
      I1 => \^addr\(1),
      I2 => \^addr\(0),
      I3 => \^addr\(2),
      I4 => \^addr\(4),
      O => p_0_in(4)
    );
\addr[5]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7FFFFFFF80000000"
    )
        port map (
      I0 => \^addr\(4),
      I1 => \^addr\(2),
      I2 => \^addr\(0),
      I3 => \^addr\(1),
      I4 => \^addr\(3),
      I5 => \^addr\(5),
      O => p_0_in(5)
    );
\addr[6]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => \addr[9]_i_3_n_0\,
      I1 => \^addr\(6),
      O => p_0_in(6)
    );
\addr[7]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D2"
    )
        port map (
      I0 => \^addr\(6),
      I1 => \addr[9]_i_3_n_0\,
      I2 => \^addr\(7),
      O => p_0_in(7)
    );
\addr[8]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"DF20"
    )
        port map (
      I0 => \^addr\(7),
      I1 => \addr[9]_i_3_n_0\,
      I2 => \^addr\(6),
      I3 => \^addr\(8),
      O => p_0_in(8)
    );
\addr[9]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"F7FFFFFFFFFFFFFF"
    )
        port map (
      I0 => \^addr\(9),
      I1 => \^addr\(7),
      I2 => \addr[9]_i_3_n_0\,
      I3 => \^addr\(6),
      I4 => \^addr\(8),
      I5 => \^addr_reg[10]_0\,
      O => sel
    );
\addr[9]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"F7FF0800"
    )
        port map (
      I0 => \^addr\(8),
      I1 => \^addr\(6),
      I2 => \addr[9]_i_3_n_0\,
      I3 => \^addr\(7),
      I4 => \^addr\(9),
      O => p_0_in(9)
    );
\addr[9]_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"7FFFFFFFFFFFFFFF"
    )
        port map (
      I0 => \^addr\(4),
      I1 => \^addr\(2),
      I2 => \^addr\(0),
      I3 => \^addr\(1),
      I4 => \^addr\(3),
      I5 => \^addr\(5),
      O => \addr[9]_i_3_n_0\
    );
\addr_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => p_0_in(0),
      Q => \^addr\(0),
      R => rst
    );
\addr_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => \addr[10]_i_1_n_0\,
      Q => \^addr_reg[10]_0\,
      R => rst
    );
\addr_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => p_0_in(1),
      Q => \^addr\(1),
      R => rst
    );
\addr_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => p_0_in(2),
      Q => \^addr\(2),
      R => rst
    );
\addr_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => p_0_in(3),
      Q => \^addr\(3),
      R => rst
    );
\addr_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => p_0_in(4),
      Q => \^addr\(4),
      R => rst
    );
\addr_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => p_0_in(5),
      Q => \^addr\(5),
      R => rst
    );
\addr_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => p_0_in(6),
      Q => \^addr\(6),
      R => rst
    );
\addr_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => p_0_in(7),
      Q => \^addr\(7),
      R => rst
    );
\addr_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => p_0_in(8),
      Q => \^addr\(8),
      R => rst
    );
\addr_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => p_0_in(9),
      Q => \^addr\(9),
      R => rst
    );
\din[3]_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \^din\(0),
      O => \din[3]_i_2_n_0\
    );
\din_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[3]_i_1_n_7\,
      Q => \^din\(0),
      R => rst
    );
\din_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[11]_i_1_n_5\,
      Q => \^din\(10),
      R => rst
    );
\din_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[11]_i_1_n_4\,
      Q => \^din\(11),
      R => rst
    );
\din_reg[11]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \din_reg[7]_i_1_n_0\,
      CO(3) => \din_reg[11]_i_1_n_0\,
      CO(2) => \din_reg[11]_i_1_n_1\,
      CO(1) => \din_reg[11]_i_1_n_2\,
      CO(0) => \din_reg[11]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \din_reg[11]_i_1_n_4\,
      O(2) => \din_reg[11]_i_1_n_5\,
      O(1) => \din_reg[11]_i_1_n_6\,
      O(0) => \din_reg[11]_i_1_n_7\,
      S(3 downto 0) => \^din\(11 downto 8)
    );
\din_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[15]_i_1_n_7\,
      Q => \^din\(12),
      R => rst
    );
\din_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[15]_i_1_n_6\,
      Q => \^din\(13),
      R => rst
    );
\din_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[15]_i_1_n_5\,
      Q => \^din\(14),
      R => rst
    );
\din_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[15]_i_1_n_4\,
      Q => \^din\(15),
      R => rst
    );
\din_reg[15]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \din_reg[11]_i_1_n_0\,
      CO(3) => \din_reg[15]_i_1_n_0\,
      CO(2) => \din_reg[15]_i_1_n_1\,
      CO(1) => \din_reg[15]_i_1_n_2\,
      CO(0) => \din_reg[15]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \din_reg[15]_i_1_n_4\,
      O(2) => \din_reg[15]_i_1_n_5\,
      O(1) => \din_reg[15]_i_1_n_6\,
      O(0) => \din_reg[15]_i_1_n_7\,
      S(3 downto 0) => \^din\(15 downto 12)
    );
\din_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[19]_i_1_n_7\,
      Q => \^din\(16),
      R => rst
    );
\din_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[19]_i_1_n_6\,
      Q => \^din\(17),
      R => rst
    );
\din_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[19]_i_1_n_5\,
      Q => \^din\(18),
      R => rst
    );
\din_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[19]_i_1_n_4\,
      Q => \^din\(19),
      R => rst
    );
\din_reg[19]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \din_reg[15]_i_1_n_0\,
      CO(3) => \din_reg[19]_i_1_n_0\,
      CO(2) => \din_reg[19]_i_1_n_1\,
      CO(1) => \din_reg[19]_i_1_n_2\,
      CO(0) => \din_reg[19]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \din_reg[19]_i_1_n_4\,
      O(2) => \din_reg[19]_i_1_n_5\,
      O(1) => \din_reg[19]_i_1_n_6\,
      O(0) => \din_reg[19]_i_1_n_7\,
      S(3 downto 0) => \^din\(19 downto 16)
    );
\din_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[3]_i_1_n_6\,
      Q => \^din\(1),
      R => rst
    );
\din_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[23]_i_1_n_7\,
      Q => \^din\(20),
      R => rst
    );
\din_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[23]_i_1_n_6\,
      Q => \^din\(21),
      R => rst
    );
\din_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[23]_i_1_n_5\,
      Q => \^din\(22),
      R => rst
    );
\din_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[23]_i_1_n_4\,
      Q => \^din\(23),
      R => rst
    );
\din_reg[23]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \din_reg[19]_i_1_n_0\,
      CO(3) => \din_reg[23]_i_1_n_0\,
      CO(2) => \din_reg[23]_i_1_n_1\,
      CO(1) => \din_reg[23]_i_1_n_2\,
      CO(0) => \din_reg[23]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \din_reg[23]_i_1_n_4\,
      O(2) => \din_reg[23]_i_1_n_5\,
      O(1) => \din_reg[23]_i_1_n_6\,
      O(0) => \din_reg[23]_i_1_n_7\,
      S(3 downto 0) => \^din\(23 downto 20)
    );
\din_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[27]_i_1_n_7\,
      Q => \^din\(24),
      R => rst
    );
\din_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[27]_i_1_n_6\,
      Q => \^din\(25),
      R => rst
    );
\din_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[27]_i_1_n_5\,
      Q => \^din\(26),
      R => rst
    );
\din_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[27]_i_1_n_4\,
      Q => \^din\(27),
      R => rst
    );
\din_reg[27]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \din_reg[23]_i_1_n_0\,
      CO(3) => \din_reg[27]_i_1_n_0\,
      CO(2) => \din_reg[27]_i_1_n_1\,
      CO(1) => \din_reg[27]_i_1_n_2\,
      CO(0) => \din_reg[27]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \din_reg[27]_i_1_n_4\,
      O(2) => \din_reg[27]_i_1_n_5\,
      O(1) => \din_reg[27]_i_1_n_6\,
      O(0) => \din_reg[27]_i_1_n_7\,
      S(3 downto 0) => \^din\(27 downto 24)
    );
\din_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[31]_i_1_n_7\,
      Q => \^din\(28),
      R => rst
    );
\din_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[31]_i_1_n_6\,
      Q => \^din\(29),
      R => rst
    );
\din_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[3]_i_1_n_5\,
      Q => \^din\(2),
      R => rst
    );
\din_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[31]_i_1_n_5\,
      Q => \^din\(30),
      R => rst
    );
\din_reg[31]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[31]_i_1_n_4\,
      Q => \^din\(31),
      R => rst
    );
\din_reg[31]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \din_reg[27]_i_1_n_0\,
      CO(3) => \NLW_din_reg[31]_i_1_CO_UNCONNECTED\(3),
      CO(2) => \din_reg[31]_i_1_n_1\,
      CO(1) => \din_reg[31]_i_1_n_2\,
      CO(0) => \din_reg[31]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \din_reg[31]_i_1_n_4\,
      O(2) => \din_reg[31]_i_1_n_5\,
      O(1) => \din_reg[31]_i_1_n_6\,
      O(0) => \din_reg[31]_i_1_n_7\,
      S(3 downto 0) => \^din\(31 downto 28)
    );
\din_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[3]_i_1_n_4\,
      Q => \^din\(3),
      R => rst
    );
\din_reg[3]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \din_reg[3]_i_1_n_0\,
      CO(2) => \din_reg[3]_i_1_n_1\,
      CO(1) => \din_reg[3]_i_1_n_2\,
      CO(0) => \din_reg[3]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0001",
      O(3) => \din_reg[3]_i_1_n_4\,
      O(2) => \din_reg[3]_i_1_n_5\,
      O(1) => \din_reg[3]_i_1_n_6\,
      O(0) => \din_reg[3]_i_1_n_7\,
      S(3 downto 1) => \^din\(3 downto 1),
      S(0) => \din[3]_i_2_n_0\
    );
\din_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[7]_i_1_n_7\,
      Q => \^din\(4),
      R => rst
    );
\din_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[7]_i_1_n_6\,
      Q => \^din\(5),
      R => rst
    );
\din_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[7]_i_1_n_5\,
      Q => \^din\(6),
      R => rst
    );
\din_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[7]_i_1_n_4\,
      Q => \^din\(7),
      R => rst
    );
\din_reg[7]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \din_reg[3]_i_1_n_0\,
      CO(3) => \din_reg[7]_i_1_n_0\,
      CO(2) => \din_reg[7]_i_1_n_1\,
      CO(1) => \din_reg[7]_i_1_n_2\,
      CO(0) => \din_reg[7]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \din_reg[7]_i_1_n_4\,
      O(2) => \din_reg[7]_i_1_n_5\,
      O(1) => \din_reg[7]_i_1_n_6\,
      O(0) => \din_reg[7]_i_1_n_7\,
      S(3 downto 0) => \^din\(7 downto 4)
    );
\din_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[11]_i_1_n_7\,
      Q => \^din\(8),
      R => rst
    );
\din_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => sel,
      D => \din_reg[11]_i_1_n_6\,
      Q => \^din\(9),
      R => rst
    );
we_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => sel,
      I1 => rst,
      O => we_i_1_n_0
    );
we_reg: unisim.vcomponents.FDRE
     port map (
      C => clk,
      CE => '1',
      D => we_i_1_n_0,
      Q => we,
      R => '0'
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_1_bram_writer_0_0 is
  port (
    clk : in STD_LOGIC;
    rst : in STD_LOGIC;
    addr : out STD_LOGIC_VECTOR ( 10 downto 0 );
    din : out STD_LOGIC_VECTOR ( 31 downto 0 );
    we : out STD_LOGIC;
    enb : out STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of design_1_bram_writer_0_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of design_1_bram_writer_0_0 : entity is "design_1_bram_writer_0_0,bram_writer,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of design_1_bram_writer_0_0 : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of design_1_bram_writer_0_0 : entity is "package_project";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of design_1_bram_writer_0_0 : entity is "bram_writer,Vivado 2023.2";
end design_1_bram_writer_0_0;

architecture STRUCTURE of design_1_bram_writer_0_0 is
  signal \<const1>\ : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of clk : signal is "xilinx.com:signal:clock:1.0 clk CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of clk : signal is "XIL_INTERFACENAME clk, ASSOCIATED_RESET rst, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN design_1_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of rst : signal is "xilinx.com:signal:reset:1.0 rst RST";
  attribute X_INTERFACE_PARAMETER of rst : signal is "XIL_INTERFACENAME rst, POLARITY ACTIVE_LOW, INSERT_VIP 0";
begin
  enb <= \<const1>\;
VCC: unisim.vcomponents.VCC
     port map (
      P => \<const1>\
    );
inst: entity work.design_1_bram_writer_0_0_bram_writer
     port map (
      addr(9 downto 0) => addr(9 downto 0),
      \addr_reg[10]_0\ => addr(10),
      clk => clk,
      din(31 downto 0) => din(31 downto 0),
      rst => rst,
      we => we
    );
end STRUCTURE;
