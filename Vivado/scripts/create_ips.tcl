# AXI_INTERCONNECT_0
set axi_interconnect_0 [create_ip -name axi_interconnect -vendor xilinx.com -library ip -version 1.7 -module_name axi_interconnect_0]
set_property -dict [list \
  CONFIG.AXI_ADDR_WIDTH {32} \
  CONFIG.INTERCONNECT_DATA_WIDTH {64} \
  CONFIG.M00_AXI_DATA_WIDTH {64} \
  CONFIG.M00_AXI_READ_FIFO_DELAY {1} \
  CONFIG.M00_AXI_READ_FIFO_DEPTH {512} \
  CONFIG.M00_AXI_REGISTER {1} \
  CONFIG.NUM_SLAVE_PORTS {8} \
  CONFIG.S00_AXI_DATA_WIDTH {64} \
  CONFIG.S00_AXI_READ_FIFO_DELAY {1} \
  CONFIG.S00_AXI_READ_FIFO_DEPTH {512} \
  CONFIG.S00_AXI_READ_WRITE_SUPPORT {READ-ONLY} \
  CONFIG.S00_AXI_REGISTER {1} \
  CONFIG.S01_AXI_DATA_WIDTH {64} \
  CONFIG.S01_AXI_READ_FIFO_DELAY {1} \
  CONFIG.S01_AXI_READ_FIFO_DEPTH {512} \
  CONFIG.S01_AXI_READ_WRITE_SUPPORT {READ-ONLY} \
  CONFIG.S01_AXI_REGISTER {1} \
  CONFIG.S02_AXI_DATA_WIDTH {64} \
  CONFIG.S02_AXI_READ_FIFO_DELAY {1} \
  CONFIG.S02_AXI_READ_FIFO_DEPTH {512} \
  CONFIG.S02_AXI_READ_WRITE_SUPPORT {READ-ONLY} \
  CONFIG.S02_AXI_REGISTER {1} \
  CONFIG.S03_AXI_DATA_WIDTH {64} \
  CONFIG.S03_AXI_READ_FIFO_DELAY {1} \
  CONFIG.S03_AXI_READ_FIFO_DEPTH {512} \
  CONFIG.S03_AXI_READ_WRITE_SUPPORT {READ-ONLY} \
  CONFIG.S03_AXI_REGISTER {1} \
  CONFIG.S04_AXI_DATA_WIDTH {64} \
  CONFIG.S04_AXI_READ_FIFO_DELAY {1} \
  CONFIG.S04_AXI_READ_FIFO_DEPTH {512} \
  CONFIG.S04_AXI_READ_WRITE_SUPPORT {READ-ONLY} \
  CONFIG.S04_AXI_REGISTER {1} \
  CONFIG.S05_AXI_DATA_WIDTH {64} \
  CONFIG.S05_AXI_READ_FIFO_DELAY {1} \
  CONFIG.S05_AXI_READ_FIFO_DEPTH {512} \
  CONFIG.S05_AXI_READ_WRITE_SUPPORT {READ-ONLY} \
  CONFIG.S05_AXI_REGISTER {1} \
  CONFIG.S06_AXI_DATA_WIDTH {64} \
  CONFIG.S06_AXI_READ_FIFO_DELAY {1} \
  CONFIG.S06_AXI_READ_FIFO_DEPTH {512} \
  CONFIG.S06_AXI_READ_WRITE_SUPPORT {READ-ONLY} \
  CONFIG.S06_AXI_REGISTER {1} \
  CONFIG.S07_AXI_DATA_WIDTH {64} \
  CONFIG.S07_AXI_READ_FIFO_DELAY {1} \
  CONFIG.S07_AXI_READ_FIFO_DEPTH {512} \
  CONFIG.S07_AXI_READ_WRITE_SUPPORT {READ-ONLY} \
  CONFIG.S07_AXI_REGISTER {1} \
  CONFIG.THREAD_ID_WIDTH {4} \
] [get_ips axi_interconnect_0]

# AXIS_DATA_FIFO_BRAM
set axis_data_fifo_bram [create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_bram]
set_property -dict [list \
  CONFIG.FIFO_DEPTH {1024} \
  CONFIG.FIFO_MEMORY_TYPE {block} \
  CONFIG.TDATA_NUM_BYTES {8} \
] [get_ips axis_data_fifo_bram]

# FP64_ACCUM
set fp64_accum [create_ip -name floating_point -vendor xilinx.com -library ip -version 7.1 -module_name fp64_accum]
set_property -dict [list \
  CONFIG.A_Precision_Type {Double} \
  CONFIG.Add_Sub_Value {Add} \
  CONFIG.Axi_Optimize_Goal {Performance} \
  CONFIG.C_A_Exponent_Width {11} \
  CONFIG.C_A_Fraction_Width {53} \
  CONFIG.C_Accum_Input_Msb {4} \
  CONFIG.C_Accum_Lsb {-100} \
  CONFIG.C_Accum_Msb {20} \
  CONFIG.C_Latency {29} \
  CONFIG.C_Mult_Usage {Medium_Usage} \
  CONFIG.C_Rate {1} \
  CONFIG.C_Result_Exponent_Width {11} \
  CONFIG.C_Result_Fraction_Width {53} \
  CONFIG.Has_ARESETn {true} \
  CONFIG.Has_A_TLAST {true} \
  CONFIG.Operation_Type {Accumulator} \
  CONFIG.RESULT_TLAST_Behv {Pass_A_TLAST} \
  CONFIG.Result_Precision_Type {Double} \
] [get_ips fp64_accum]

# FP64_MULT
set fp64_mult [create_ip -name floating_point -vendor xilinx.com -library ip -version 7.1 -module_name fp64_mult]
set_property -dict [list \
  CONFIG.A_Precision_Type {Double} \
  CONFIG.Axi_Optimize_Goal {Performance} \
  CONFIG.C_A_Exponent_Width {11} \
  CONFIG.C_A_Fraction_Width {53} \
  CONFIG.C_Accum_Input_Msb {32} \
  CONFIG.C_Accum_Lsb {-31} \
  CONFIG.C_Accum_Msb {32} \
  CONFIG.C_Latency {18} \
  CONFIG.C_Mult_Usage {Full_Usage} \
  CONFIG.C_Rate {1} \
  CONFIG.C_Result_Exponent_Width {11} \
  CONFIG.C_Result_Fraction_Width {53} \
  CONFIG.Has_ARESETn {true} \
  CONFIG.Operation_Type {Multiply} \
  CONFIG.Result_Precision_Type {Double} \
] [get_ips fp64_mult]

