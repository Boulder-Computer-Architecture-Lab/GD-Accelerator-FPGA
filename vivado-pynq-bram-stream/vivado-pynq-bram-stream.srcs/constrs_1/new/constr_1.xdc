# Prevent synthesis from removing ILA and debug hub cores
set_property DONT_TOUCH true [get_cells -hierarchical *ila*]
set_property DONT_TOUCH true [get_cells -hierarchical *dbg_hub*]

# dbg_hub cfg
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets processing_system7_0_FCLK_CLK0]

# ila_0: axi_dma_0 MM2S stream
set_property KEEP TRUE [get_nets axi_dma_0_m_axis_mm2s_tvalid]
set_property KEEP TRUE [get_nets axi_dma_0_m_axis_mm2s_tlast]
set_property KEEP TRUE [get_nets axi_dma_0_m_axis_mm2s_tdata[*]]

# ila_1: bram_stream_writer
set_property KEEP TRUE [get_nets bram_stream_writer_0_bram_en]
set_property KEEP TRUE [get_nets bram_stream_writer_0_bram_we[*]]
set_property KEEP TRUE [get_nets bram_stream_writer_0_bram_addr[*]]
set_property KEEP TRUE [get_nets bram_stream_writer_0_bram_din[*]]

# ila_2: bram_stream_reader AXIS output
set_property KEEP TRUE [get_nets bram_stream_reader_0_m00_axis_tvalid]
set_property KEEP TRUE [get_nets bram_stream_reader_0_m00_axis_tdata[*]]
set_property KEEP TRUE [get_nets bram_stream_reader_0_m00_axis_tlast]

# ila_3: bram_stream_reader BRAM interface + reset
set_property KEEP TRUE [get_nets bram_stream_reader_0_bram_en]
set_property KEEP TRUE [get_nets bram_stream_reader_0_bram_addr[*]]
set_property KEEP TRUE [get_nets Net2[*]]
set_property KEEP TRUE [get_nets rst_ps7_0_100M_peripheral_aresetn]

