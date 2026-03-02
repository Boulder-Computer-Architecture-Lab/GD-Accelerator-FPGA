`timescale 1ns / 1ps

module iterate #(
    parameter DATA_WIDTH = 128
)(

    input  wire                  clk,
    input  wire                  rstn,

    // Input interface (matrix)
    input  wire [ID_WIDTH-1:0]   s_axi_awid,
    input  wire [ADDR_WIDTH-1:0] s_axi_awaddr,
    input  wire [7:0]            s_axi_awlen,
    input  wire [2:0]            s_axi_awsize,
    input  wire [1:0]            s_axi_awburst,
    input  wire                  s_axi_awlock,
    input  wire [3:0]            s_axi_awcache,
    input  wire [2:0]            s_axi_awprot,
    input  wire                  s_axi_awvalid,
    output wire                  s_axi_awready,
    
    input  wire [DATA_WIDTH-1:0]     s_axi_wdata,
    input  wire [(DATA_WIDTH/8)-1:0] s_axi_wstrb,
    input  wire                      s_axi_wlast,
    input  wire                      s_axi_wvalid,
    output wire                      s_axi_wready,
    
    output wire [ID_WIDTH-1:0] s_axi_bid,
    output wire [1:0]          s_axi_bresp,
    output wire                s_axi_bvalid,
    input  wire                s_axi_bready,

    // Input stream (vector)
    input  wire [DATA_WIDTH-1:0] s_axis_tdata,
    input  wire                  s_axis_tvalid,
    output wire                  s_axis_tready,
    input  wire                  s_axis_tlast,
    
    // Output stream (result vector)
    output wire [ELEMENT_WIDTH-1:0] m_axis_tdata,
    output wire                     m_axis_tvalid,
    input  wire                     m_axis_tready,
    output wire                     m_axis_tlast,

);

    mvm_accelerator #(
        .ARCH_TYPE          (0),
        .PROFILE            (0),
        //.AXI_RAM_BASE_ADDR  (),
        .DATA_WIDTH         (DATA_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .ID_WIDTH           (ID_WIDTH),
        .ELEMENT_WIDTH      (ELEMENT_WIDTH),
        .ELEMENTS_PER_ROW   (ELEMENTS_PER_ROW),
        .NUM_ROWS           (NUM_ROWS),
        .NUM_CHANNELS       (NUM_CHANNELS),
        .AXI_RAM_DATA_WIDTH (AXI_RAM_DATA_WIDTH),
    ) mvm (
        .clk(clk),
        .rstn(rstn),
        
        // Input channels
        .s_axis_a_tdata (s_axis_a_tdata),
        .s_axis_a_tvalid(s_axis_a_tvalid),
        .s_axis_a_tready(s_axis_a_tready),
        .s_axis_a_tlast (s_axis_a_tlast),
    
        // Output channels
        .m_axis_tdata (m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast (m_axis_tlast),
    
        // AXI slave interface
        .s_axi_b_awid   (s_axi_b_awid),
        .s_axi_b_awaddr (s_axi_b_awaddr),
        .s_axi_b_awlen  (s_axi_b_awlen),
        .s_axi_b_awsize (s_axi_b_awsize),
        .s_axi_b_awburst(s_axi_b_awburst),
        .s_axi_b_awlock (s_axi_b_awlock),
        .s_axi_b_awcache(s_axi_b_awcache),
        .s_axi_b_awprot (s_axi_b_awprot),
        .s_axi_b_awvalid(s_axi_b_awvalid),
        .s_axi_b_awready(s_axi_b_awready),
        .s_axi_b_wdata  (s_axi_b_wdata),
        .s_axi_b_wstrb  (s_axi_b_wstrb),
        .s_axi_b_wlast  (s_axi_b_wlast),
        .s_axi_b_wvalid (s_axi_b_wvalid),
        .s_axi_b_wready (s_axi_b_wready),
        .s_axi_b_bid    (s_axi_b_bid),
        .s_axi_b_bresp  (s_axi_b_bresp),
        .s_axi_b_bvalid (s_axi_b_bvalid),
        .s_axi_b_bready (s_axi_b_bready)
    );

endmodule
