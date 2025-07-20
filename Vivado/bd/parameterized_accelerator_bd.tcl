# accelerator_bd.tcl - Parameterized block design creation for mvm_accelerator

set NUM_MODULES 2
set NUM_A_CH_PER_MODULE 2

create_bd_design "accelerator"

# PS block
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 ps7
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" } [get_bd_cells ps7]

# AXI interconnects
# Control interconnect (AXI-Full)
create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 axi_full_ctrl
set_property -dict [list CONFIG.NUM_SI $NUM_MODULES CONFIG.NUM_MI $NUM_MODULES] [get_bd_cells axi_full_ctrl]
connect_bd_intf_net [get_bd_intf_pins ps7/M_AXI_GP1] [get_bd_intf_pins axi_full_ctrl/S00_AXI]

# DMA control interconnect (AXI-Lite)
create_bd_cell -type ip -vlnv xilinx.com:ip:ps7_axi_periph ps7_0_axi_periph
set_property CONFIG.NUM_SLAVES [expr $NUM_MODULES * ($NUM_A_CH_PER_MODULE + 1) * 2] [get_bd_cells ps7_0_axi_periph]
connect_bd_intf_net [get_bd_intf_pins ps7/M_AXI_GP0] [get_bd_intf_pins ps7_0_axi_periph/M00_AXI]

# Create modules and attach DMA
for {set i 0} {$i < $NUM_MODULES} {incr i} {
    set accel_name "mvm_accel_$i"
    create_bd_cell -type module -reference mvm_accelerator $accel_name

    # Create SmartConnect for MM2S
    set sc_mm2s [create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 sc_mm2s_$i]
    set_property -dict [list CONFIG.NUM_MI 1 CONFIG.NUM_SI $NUM_A_CH_PER_MODULE] [get_bd_cells $sc_mm2s]
    connect_bd_intf_net [get_bd_intf_pins ps7/S_AXI_HP0] [get_bd_intf_pins $sc_mm2s/M00_AXI]

    # Create SmartConnect for S2MM
    set sc_s2mm [create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 sc_s2mm_$i]
    set_property -dict [list CONFIG.NUM_MI 1 CONFIG.NUM_SI $NUM_A_CH_PER_MODULE] [get_bd_cells $sc_s2mm]
    connect_bd_intf_net [get_bd_intf_pins ps7/S_AXI_HP2] [get_bd_intf_pins $sc_s2mm/M00_AXI]

    for {set j 0} {$j < $NUM_A_CH_PER_MODULE} {incr j} {
        set dma_name "axi_dma_${i}_${j}"
        create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 $dma_name
        set_property -dict [list CONFIG.c_include_sg 0 CONFIG.c_sg_length_width 14 CONFIG.c_include_mm2s_dre 1 CONFIG.c_include_s2mm_dre 1 CONFIG.c_include_mm2s 1 CONFIG.c_include_s2mm 1] [get_bd_cells $dma_name]

        # Connect MM2S to input interconnect
        connect_bd_intf_net [get_bd_intf_pins $dma_name/M_AXI_MM2S] [get_bd_intf_pins $sc_mm2s/S0${j}_AXI]

        # Connect S2MM to output interconnect
        connect_bd_intf_net [get_bd_intf_pins $dma_name/M_AXI_S2MM] [get_bd_intf_pins $sc_s2mm/S0${j}_AXI]

        # AXI-Stream MM2S → mvm_accel.s_axis_a[j]
        connect_bd_intf_net [get_bd_intf_pins $dma_name/M_AXIS_MM2S] [get_bd_intf_pins $accel_name/s_axis_a_$j]

        # mvm_accel.m_axis[j] → AXI-Stream S2MM
        connect_bd_intf_net [get_bd_intf_pins $accel_name/m_axis_$j] [get_bd_intf_pins $dma_name/S_AXIS_S2MM]

        # Control ports
        connect_bd_intf_net [get_bd_intf_pins $dma_name/S_AXI_LITE] [get_bd_intf_pins ps7_0_axi_periph/S0${i}${j}_AXI]
    }

    # Add DMA for s_axis_b
    set dma_b "axi_dma_b_${i}"
    create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 $dma_b
    set_property -dict [list CONFIG.c_include_sg 0 CONFIG.c_include_mm2s 1 CONFIG.c_include_s2mm 0 CONFIG.c_include_mm2s_dre 1] [get_bd_cells $dma_b]
    connect_bd_intf_net [get_bd_intf_pins $dma_b/M_AXI_MM2S] [get_bd_intf_pins $sc_mm2s/S0${NUM_A_CH_PER_MODULE}_AXI]
    connect_bd_intf_net [get_bd_intf_pins $dma_b/M_AXIS_MM2S] [get_bd_intf_pins $accel_name/s_axis_b]
    connect_bd_intf_net [get_bd_intf_pins $dma_b/S_AXI_LITE] [get_bd_intf_pins ps7_0_axi_periph/S0${i}${NUM_A_CH_PER_MODULE}_AXI]

    # Connect control interface (AXI Full write) for s_axi_b
    connect_bd_intf_net [get_bd_intf_pins axi_full_ctrl/M0${i}_AXI] [get_bd_intf_pins $accel_name/s_axi_b]

    # Clock/Reset
    set clk [get_bd_pins ps7/FCLK_CLK0]
    set rst [get_bd_pins ps7/FCLK_RESET0_N]
    connect_bd_net $clk [get_bd_pins $accel_name/ap_clk]
    connect_bd_net $rst [get_bd_pins $accel_name/ap_rst_n]
}

assign_bd_address
save_bd_design

