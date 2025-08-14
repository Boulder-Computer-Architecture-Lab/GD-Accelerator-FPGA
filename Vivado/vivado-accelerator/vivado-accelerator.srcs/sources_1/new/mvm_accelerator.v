`timescale 1ns / 1ps

module mvm_accelerator #(
    parameter ARCH_TYPE = 0,
    
    parameter DATA_WIDTH         = 1024,
    parameter ADDR_WIDTH         = 32,
    parameter STRB_WIDTH         = DATA_WIDTH / 8,
    parameter ID_WIDTH           = 4,
    
    parameter ELEMENT_WIDTH      = 64,
    parameter ELEMENTS_PER_WORD  = DATA_WIDTH / ELEMENT_WIDTH, // MUST BE A POWER OF 2!
    
    parameter WORDS_PER_TRANSFER = 17048,
    
    parameter NUM_CHANNELS       = 4,
    parameter NUM_RAM_PARTITIONS = NUM_CHANNELS,
    
    parameter AXI_RAM_BASE_ADDR  = 32'h8000_0000,
    parameter AXI_RAM_ID_WIDTH = ID_WIDTH + 4 + $clog2(NUM_CHANNELS)
)(

    // Note: per channel clock signals are for vivado to auto-infer 
    // associated clocks on BD, but all s_axis/b_axi clocks should be
    // on the same frequency (limited by PS/S_AXI_HP interface) and
    // m_axi clocks can be different frequency (limited by PS/S_AXI_ACP
    // and PS/M_AXI_GP* interfaces).
    
    // Input streams
    input  wire                  s_axis_a_0_clk,
    input  wire                  s_axis_a_0_rstn,
    input  wire [DATA_WIDTH-1:0] s_axis_a_0_tdata,
    input  wire                  s_axis_a_0_tvalid,
    output wire                  s_axis_a_0_tready,
    input  wire                  s_axis_a_0_tlast,
    
    input  wire                  s_axis_a_1_clk,
    input  wire                  s_axis_a_1_rstn,
    input  wire [DATA_WIDTH-1:0] s_axis_a_1_tdata,
    input  wire                  s_axis_a_1_tvalid,
    output wire                  s_axis_a_1_tready,
    input  wire                  s_axis_a_1_tlast,

    input  wire                  s_axis_a_2_clk,
    input  wire                  s_axis_a_2_rstn,
    input  wire [DATA_WIDTH-1:0] s_axis_a_2_tdata,
    input  wire                  s_axis_a_2_tvalid,
    output wire                  s_axis_a_2_tready,
    input  wire                  s_axis_a_2_tlast,
    
    input  wire                  s_axis_a_3_clk,
    input  wire                  s_axis_a_3_rstn, 
    input  wire [DATA_WIDTH-1:0] s_axis_a_3_tdata,
    input  wire                  s_axis_a_3_tvalid,
    output wire                  s_axis_a_3_tready,
    input  wire                  s_axis_a_3_tlast,

    // Output streams
    input  wire                     m_axis_0_clk,
    input  wire                     m_axis_0_rstn,
    output wire [ELEMENT_WIDTH-1:0] m_axis_0_tdata,
    output wire                     m_axis_0_tvalid,
    input  wire                     m_axis_0_tready,
    output wire                     m_axis_0_tlast,
    
    input  wire                     m_axis_1_clk,
    input  wire                     m_axis_1_rstn,    
    output wire [ELEMENT_WIDTH-1:0] m_axis_1_tdata,
    output wire                     m_axis_1_tvalid,
    input  wire                     m_axis_1_tready,
    output wire                     m_axis_1_tlast,
    
    input  wire                     m_axis_2_clk,
    input  wire                     m_axis_2_rstn,    
    output wire [ELEMENT_WIDTH-1:0] m_axis_2_tdata,
    output wire                     m_axis_2_tvalid,
    input  wire                     m_axis_2_tready,
    output wire                     m_axis_2_tlast,

    input  wire                     m_axis_3_clk,
    input  wire                     m_axis_3_rstn,
    output wire [ELEMENT_WIDTH-1:0] m_axis_3_tdata,
    output wire                     m_axis_3_tvalid,
    input  wire                     m_axis_3_tready,
    output wire                     m_axis_3_tlast,

    // S-AXI interface (for writing vector b)
    input wire                         s_axi_b_clk,
    input wire                         s_axi_b_rstn,

    input  wire [AXI_RAM_ID_WIDTH-1:0] s_axi_b_awid,
    input  wire [ADDR_WIDTH-1:0]       s_axi_b_awaddr,
    input  wire [7:0]                  s_axi_b_awlen,
    input  wire [2:0]                  s_axi_b_awsize,
    input  wire [1:0]                  s_axi_b_awburst,
    input  wire                        s_axi_b_awlock,
    input  wire [3:0]                  s_axi_b_awcache,
    input  wire [2:0]                  s_axi_b_awprot,
    input  wire                        s_axi_b_awvalid,
    output wire                        s_axi_b_awready,
    
    input  wire [DATA_WIDTH-1:0]       s_axi_b_wdata,
    input  wire [STRB_WIDTH-1:0]       s_axi_b_wstrb,
    input  wire                        s_axi_b_wlast,
    input  wire                        s_axi_b_wvalid,
    output wire                        s_axi_b_wready,
    
    output wire [AXI_RAM_ID_WIDTH-1:0] s_axi_b_bid,
    output wire [1:0]                  s_axi_b_bresp,
    output wire                        s_axi_b_bvalid,
    input  wire                        s_axi_b_bready
);

    generate
        if (ARCH_TYPE == 0) begin
            mvm_accelerator_split #(
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH),
                .STRB_WIDTH(STRB_WIDTH),
                .ID_WIDTH(ID_WIDTH),
                .ELEMENT_WIDTH(ELEMENT_WIDTH),
                .ELEMENTS_PER_WORD(ELEMENTS_PER_WORD),
                .WORDS_PER_TRANSFER(WORDS_PER_TRANSFER),
                .NUM_CHANNELS(NUM_CHANNELS),
                .NUM_RAM_PARTITIONS(NUM_RAM_PARTITIONS),
                .AXI_RAM_BASE_ADDR(AXI_RAM_BASE_ADDR),
                .AXI_RAM_ID_WIDTH(AXI_RAM_ID_WIDTH)
            ) mvm (
                .s_clk(s_axis_a_0_clk), .m_clk(m_axis_0_clk),
                .s_rstn(s_axis_a_0_rstn), .m_rstn(m_axis_0_rstn),
                
                // Input channels
                .s_axis_a_0_tdata(s_axis_a_0_tdata),
                .s_axis_a_0_tvalid(s_axis_a_0_tvalid),
                .s_axis_a_0_tready(s_axis_a_0_tready),
                .s_axis_a_0_tlast(s_axis_a_0_tlast),
            
                .s_axis_a_1_tdata(s_axis_a_1_tdata),
                .s_axis_a_1_tvalid(s_axis_a_1_tvalid),
                .s_axis_a_1_tready(s_axis_a_1_tready),
                .s_axis_a_1_tlast(s_axis_a_1_tlast),

                .s_axis_a_2_tdata(s_axis_a_2_tdata),
                .s_axis_a_2_tvalid(s_axis_a_2_tvalid),
                .s_axis_a_2_tready(s_axis_a_2_tready),
                .s_axis_a_2_tlast(s_axis_a_2_tlast),
            
                .s_axis_a_3_tdata(s_axis_a_3_tdata),
                .s_axis_a_3_tvalid(s_axis_a_3_tvalid),
                .s_axis_a_3_tready(s_axis_a_3_tready),
                .s_axis_a_3_tlast(s_axis_a_3_tlast),
            
                // Output channels
                .m_axis_0_tdata(m_axis_0_tdata),
                .m_axis_0_tvalid(m_axis_0_tvalid),
                .m_axis_0_tready(m_axis_0_tready),
                .m_axis_0_tlast(m_axis_0_tlast),
            
                .m_axis_1_tdata(m_axis_1_tdata),
                .m_axis_1_tvalid(m_axis_1_tvalid),
                .m_axis_1_tready(m_axis_1_tready),
                .m_axis_1_tlast(m_axis_1_tlast),
            
                .m_axis_2_tdata(m_axis_2_tdata),
                .m_axis_2_tvalid(m_axis_2_tvalid),
                .m_axis_2_tready(m_axis_2_tready),
                .m_axis_2_tlast(m_axis_2_tlast),
            
                .m_axis_3_tdata(m_axis_3_tdata),
                .m_axis_3_tvalid(m_axis_3_tvalid),
                .m_axis_3_tready(m_axis_3_tready),
                .m_axis_3_tlast(m_axis_3_tlast),
            
                // AXI slave interface
                .s_axi_b_awid(s_axi_b_awid),
                .s_axi_b_awaddr(s_axi_b_awaddr),
                .s_axi_b_awlen(s_axi_b_awlen),
                .s_axi_b_awsize(s_axi_b_awsize),
                .s_axi_b_awburst(s_axi_b_awburst),
                .s_axi_b_awlock(s_axi_b_awlock),
                .s_axi_b_awcache(s_axi_b_awcache),
                .s_axi_b_awprot(s_axi_b_awprot),
                .s_axi_b_awvalid(s_axi_b_awvalid),
                .s_axi_b_awready(s_axi_b_awready),
            
                .s_axi_b_wdata(s_axi_b_wdata),
                .s_axi_b_wstrb(s_axi_b_wstrb),
                .s_axi_b_wlast(s_axi_b_wlast),
                .s_axi_b_wvalid(s_axi_b_wvalid),
                .s_axi_b_wready(s_axi_b_wready),
            
                .s_axi_b_bid(s_axi_b_bid),
                .s_axi_b_bresp(s_axi_b_bresp),
                .s_axi_b_bvalid(s_axi_b_bvalid),
                .s_axi_b_bready(s_axi_b_bready)
            );
        end
    endgenerate

endmodule
