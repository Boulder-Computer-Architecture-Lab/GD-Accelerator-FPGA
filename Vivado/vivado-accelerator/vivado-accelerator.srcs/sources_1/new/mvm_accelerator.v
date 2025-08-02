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
    
    parameter AXI_RAM_BASE_ADDR  = 32'h8000_0000,    
    parameter NUM_CHANNELS       = 4,
    parameter NUM_RAM_PARTITIONS = NUM_CHANNELS
)(
    input wire clk,
    input wire rstn,
    
    // Input streams
    input  wire [DATA_WIDTH-1:0] s_axis_a_0_tdata,
    input  wire                  s_axis_a_0_tvalid,
    output wire                  s_axis_a_0_tready,
    
    input  wire [DATA_WIDTH-1:0] s_axis_a_1_tdata,
    input  wire                  s_axis_a_1_tvalid,
    output wire                  s_axis_a_1_tready,
    
    input  wire [DATA_WIDTH-1:0] s_axis_a_2_tdata,
    input  wire                  s_axis_a_2_tvalid,
    output wire                  s_axis_a_2_tready,
    
    input  wire [DATA_WIDTH-1:0] s_axis_a_3_tdata,
    input  wire                  s_axis_a_3_tvalid,
    output wire                  s_axis_a_3_tready,
    
    input  wire [DATA_WIDTH-1:0] s_axis_a_4_tdata,
    input  wire                  s_axis_a_4_tvalid,
    output wire                  s_axis_a_4_tready,
    
    input  wire [DATA_WIDTH-1:0] s_axis_a_5_tdata,
    input  wire                  s_axis_a_5_tvalid,
    output wire                  s_axis_a_5_tready,
    
    input  wire [DATA_WIDTH-1:0] s_axis_a_6_tdata,
    input  wire                  s_axis_a_6_tvalid,
    output wire                  s_axis_a_6_tready,
    
    input  wire [DATA_WIDTH-1:0] s_axis_a_7_tdata,
    input  wire                  s_axis_a_7_tvalid,
    output wire                  s_axis_a_7_tready,
    
    // Output streams
    output wire [ELEMENT_WIDTH-1:0] m_axis_0_tdata,
    output wire                     m_axis_0_tvalid,
    input  wire                     m_axis_0_tready,
    output wire                     m_axis_0_tlast,
    
    output wire [ELEMENT_WIDTH-1:0] m_axis_1_tdata,
    output wire                     m_axis_1_tvalid,
    input  wire                     m_axis_1_tready,
    output wire                     m_axis_1_tlast,
    
    output wire [ELEMENT_WIDTH-1:0] m_axis_2_tdata,
    output wire                     m_axis_2_tvalid,
    input  wire                     m_axis_2_tready,
    output wire                     m_axis_2_tlast,

    output wire [ELEMENT_WIDTH-1:0] m_axis_3_tdata,
    output wire                     m_axis_3_tvalid,
    input  wire                     m_axis_3_tready,
    output wire                     m_axis_3_tlast,
    
    output wire [ELEMENT_WIDTH-1:0] m_axis_4_tdata,
    output wire                     m_axis_4_tvalid,
    input  wire                     m_axis_4_tready,
    output wire                     m_axis_4_tlast,
    
    output wire [ELEMENT_WIDTH-1:0] m_axis_5_tdata,
    output wire                     m_axis_5_tvalid,
    input  wire                     m_axis_5_tready,
    output wire                     m_axis_5_tlast,
    
    output wire [ELEMENT_WIDTH-1:0] m_axis_6_tdata,
    output wire                     m_axis_6_tvalid,
    input  wire                     m_axis_6_tready,
    output wire                     m_axis_6_tlast,

    output wire [ELEMENT_WIDTH-1:0] m_axis_7_tdata,
    output wire                     m_axis_7_tvalid,
    input  wire                     m_axis_7_tready,
    output wire                     m_axis_7_tlast,

    // S-AXI interface (for writing vector b)
    input  wire [(ID_WIDTH+4)-1:0] s_axi_b_awid,
    input  wire [ADDR_WIDTH-1:0]   s_axi_b_awaddr,
    input  wire [7:0]              s_axi_b_awlen,
    input  wire [2:0]              s_axi_b_awsize,
    input  wire [1:0]              s_axi_b_awburst,
    input  wire                    s_axi_b_awlock,
    input  wire [3:0]              s_axi_b_awcache,
    input  wire [2:0]              s_axi_b_awprot,
    input  wire                    s_axi_b_awvalid,
    output wire                    s_axi_b_awready,
    
    input  wire [DATA_WIDTH-1:0]   s_axi_b_wdata,
    input  wire [STRB_WIDTH-1:0]   s_axi_b_wstrb,
    input  wire                    s_axi_b_wlast,
    input  wire                    s_axi_b_wvalid,
    output wire                    s_axi_b_wready,
    
    output wire [(ID_WIDTH+4)-1:0] s_axi_b_bid,
    output wire [1:0]              s_axi_b_bresp,
    output wire                    s_axi_b_bvalid,
    input  wire                    s_axi_b_bready
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
                .AXI_RAM_BASE_ADDR(AXI_RAM_BASE_ADDR),
                .NUM_CHANNELS(NUM_CHANNELS),
                .NUM_RAM_PARTITIONS(NUM_RAM_PARTITIONS)
            ) mvm (
                .clk(clk),
                .rstn(rstn),
                            
                // Input channels
                .s_axis_a_0_tdata(s_axis_a_0_tdata),
                .s_axis_a_0_tvalid(s_axis_a_0_tvalid),
                .s_axis_a_0_tready(s_axis_a_0_tready),
            
                .s_axis_a_1_tdata(s_axis_a_1_tdata),
                .s_axis_a_1_tvalid(s_axis_a_1_tvalid),
                .s_axis_a_1_tready(s_axis_a_1_tready),
            
                .s_axis_a_2_tdata(s_axis_a_2_tdata),
                .s_axis_a_2_tvalid(s_axis_a_2_tvalid),
                .s_axis_a_2_tready(s_axis_a_2_tready),
            
                .s_axis_a_3_tdata(s_axis_a_3_tdata),
                .s_axis_a_3_tvalid(s_axis_a_3_tvalid),
                .s_axis_a_3_tready(s_axis_a_3_tready),
            
                .s_axis_a_4_tdata(s_axis_a_4_tdata),
                .s_axis_a_4_tvalid(s_axis_a_4_tvalid),
                .s_axis_a_4_tready(s_axis_a_4_tready),
            
                .s_axis_a_5_tdata(s_axis_a_5_tdata),
                .s_axis_a_5_tvalid(s_axis_a_5_tvalid),
                .s_axis_a_5_tready(s_axis_a_5_tready),
            
                .s_axis_a_6_tdata(s_axis_a_6_tdata),
                .s_axis_a_6_tvalid(s_axis_a_6_tvalid),
                .s_axis_a_6_tready(s_axis_a_6_tready),
            
                .s_axis_a_7_tdata(s_axis_a_7_tdata),
                .s_axis_a_7_tvalid(s_axis_a_7_tvalid),
                .s_axis_a_7_tready(s_axis_a_7_tready),
            
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
            
                .m_axis_4_tdata(m_axis_4_tdata),
                .m_axis_4_tvalid(m_axis_4_tvalid),
                .m_axis_4_tready(m_axis_4_tready),
                .m_axis_4_tlast(m_axis_4_tlast),
            
                .m_axis_5_tdata(m_axis_5_tdata),
                .m_axis_5_tvalid(m_axis_5_tvalid),
                .m_axis_5_tready(m_axis_5_tready),
                .m_axis_5_tlast(m_axis_5_tlast),
            
                .m_axis_6_tdata(m_axis_6_tdata),
                .m_axis_6_tvalid(m_axis_6_tvalid),
                .m_axis_6_tready(m_axis_6_tready),
                .m_axis_6_tlast(m_axis_6_tlast),
            
                .m_axis_7_tdata(m_axis_7_tdata),
                .m_axis_7_tvalid(m_axis_7_tvalid),
                .m_axis_7_tready(m_axis_7_tready),
                .m_axis_7_tlast(m_axis_7_tlast),
            
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
        end else if (ARCH_TYPE -- 1) begin
            mvm_accelerator_async #(
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH),
                .STRB_WIDTH(STRB_WIDTH),
                .ID_WIDTH(ID_WIDTH),
                .AXI_RAM_BASE_ADDR(AXI_RAM_BASE_ADDR),
                .WORDS_PER_TRANSFER(WORDS_PER_TRANSFER),
                .NUM_CHANNELS(NUM_CHANNELS)
            ) mvm (
                .clk(clk),
                .rstn(rstn),
            
                // Input channels
                .s_axis_a_0_tdata(s_axis_a_0_tdata),
                .s_axis_a_0_tvalid(s_axis_a_0_tvalid),
                .s_axis_a_0_tready(s_axis_a_0_tready),
            
                .s_axis_a_1_tdata(s_axis_a_1_tdata),
                .s_axis_a_1_tvalid(s_axis_a_1_tvalid),
                .s_axis_a_1_tready(s_axis_a_1_tready),
            
                .s_axis_a_2_tdata(s_axis_a_2_tdata),
                .s_axis_a_2_tvalid(s_axis_a_2_tvalid),
                .s_axis_a_2_tready(s_axis_a_2_tready),
            
                .s_axis_a_3_tdata(s_axis_a_3_tdata),
                .s_axis_a_3_tvalid(s_axis_a_3_tvalid),
                .s_axis_a_3_tready(s_axis_a_3_tready),
            
                .s_axis_a_4_tdata(s_axis_a_4_tdata),
                .s_axis_a_4_tvalid(s_axis_a_4_tvalid),
                .s_axis_a_4_tready(s_axis_a_4_tready),
            
                .s_axis_a_5_tdata(s_axis_a_5_tdata),
                .s_axis_a_5_tvalid(s_axis_a_5_tvalid),
                .s_axis_a_5_tready(s_axis_a_5_tready),
            
                .s_axis_a_6_tdata(s_axis_a_6_tdata),
                .s_axis_a_6_tvalid(s_axis_a_6_tvalid),
                .s_axis_a_6_tready(s_axis_a_6_tready),
            
                .s_axis_a_7_tdata(s_axis_a_7_tdata),
                .s_axis_a_7_tvalid(s_axis_a_7_tvalid),
                .s_axis_a_7_tready(s_axis_a_7_tready),
            
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
            
                .m_axis_4_tdata(m_axis_4_tdata),
                .m_axis_4_tvalid(m_axis_4_tvalid),
                .m_axis_4_tready(m_axis_4_tready),
                .m_axis_4_tlast(m_axis_4_tlast),
            
                .m_axis_5_tdata(m_axis_5_tdata),
                .m_axis_5_tvalid(m_axis_5_tvalid),
                .m_axis_5_tready(m_axis_5_tready),
                .m_axis_5_tlast(m_axis_5_tlast),
            
                .m_axis_6_tdata(m_axis_6_tdata),
                .m_axis_6_tvalid(m_axis_6_tvalid),
                .m_axis_6_tready(m_axis_6_tready),
                .m_axis_6_tlast(m_axis_6_tlast),
            
                .m_axis_7_tdata(m_axis_7_tdata),
                .m_axis_7_tvalid(m_axis_7_tvalid),
                .m_axis_7_tready(m_axis_7_tready),
                .m_axis_7_tlast(m_axis_7_tlast),
            
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
        end else if (ARCH_TYPE == 2) begin
            mvm_accelerator_sync #(
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH),
                .STRB_WIDTH(STRB_WIDTH),
                .ID_WIDTH(ID_WIDTH),
                .AXI_RAM_BASE_ADDR(AXI_RAM_BASE_ADDR),
                .WORDS_PER_TRANSFER(WORDS_PER_TRANSFER),
                .NUM_CHANNELS(NUM_CHANNELS)
            ) mvm (
                .clk(clk),
                .rstn(rstn),
            
                // Input channels
                .s_axis_a_0_tdata(s_axis_a_0_tdata),
                .s_axis_a_0_tvalid(s_axis_a_0_tvalid),
                .s_axis_a_0_tready(s_axis_a_0_tready),
            
                .s_axis_a_1_tdata(s_axis_a_1_tdata),
                .s_axis_a_1_tvalid(s_axis_a_1_tvalid),
                .s_axis_a_1_tready(s_axis_a_1_tready),
            
                .s_axis_a_2_tdata(s_axis_a_2_tdata),
                .s_axis_a_2_tvalid(s_axis_a_2_tvalid),
                .s_axis_a_2_tready(s_axis_a_2_tready),
            
                .s_axis_a_3_tdata(s_axis_a_3_tdata),
                .s_axis_a_3_tvalid(s_axis_a_3_tvalid),
                .s_axis_a_3_tready(s_axis_a_3_tready),
            
                .s_axis_a_4_tdata(s_axis_a_4_tdata),
                .s_axis_a_4_tvalid(s_axis_a_4_tvalid),
                .s_axis_a_4_tready(s_axis_a_4_tready),
            
                .s_axis_a_5_tdata(s_axis_a_5_tdata),
                .s_axis_a_5_tvalid(s_axis_a_5_tvalid),
                .s_axis_a_5_tready(s_axis_a_5_tready),
            
                .s_axis_a_6_tdata(s_axis_a_6_tdata),
                .s_axis_a_6_tvalid(s_axis_a_6_tvalid),
                .s_axis_a_6_tready(s_axis_a_6_tready),
            
                .s_axis_a_7_tdata(s_axis_a_7_tdata),
                .s_axis_a_7_tvalid(s_axis_a_7_tvalid),
                .s_axis_a_7_tready(s_axis_a_7_tready),
            
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
            
                .m_axis_4_tdata(m_axis_4_tdata),
                .m_axis_4_tvalid(m_axis_4_tvalid),
                .m_axis_4_tready(m_axis_4_tready),
                .m_axis_4_tlast(m_axis_4_tlast),
            
                .m_axis_5_tdata(m_axis_5_tdata),
                .m_axis_5_tvalid(m_axis_5_tvalid),
                .m_axis_5_tready(m_axis_5_tready),
                .m_axis_5_tlast(m_axis_5_tlast),
            
                .m_axis_6_tdata(m_axis_6_tdata),
                .m_axis_6_tvalid(m_axis_6_tvalid),
                .m_axis_6_tready(m_axis_6_tready),
                .m_axis_6_tlast(m_axis_6_tlast),
            
                .m_axis_7_tdata(m_axis_7_tdata),
                .m_axis_7_tvalid(m_axis_7_tvalid),
                .m_axis_7_tready(m_axis_7_tready),
                .m_axis_7_tlast(m_axis_7_tlast),
            
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
