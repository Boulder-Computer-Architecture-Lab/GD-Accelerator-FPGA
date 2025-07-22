`timescale 1ns / 1ps

module mvm_channel_sync #(
    parameter DATA_WIDTH         = 64,
    parameter ADDR_WIDTH         = 32,
    parameter STRB_WIDTH         = DATA_WIDTH / 8,
    parameter ID_WIDTH           = 4,
    parameter WORDS_PER_TRANSFER = 17048,
    parameter AXI_RAM_BASE_ADDR  = 32'h8000_0000,
    parameter TAG                = 0
)(
    input  wire clk,
    input  wire rstn,

    // Input stream A
    input  wire [DATA_WIDTH-1:0] s_axis_a_tdata,
    input  wire                  s_axis_a_tvalid,
    output wire                  s_axis_a_tready,
    
    // Input stream B
    input  wire [DATA_WIDTH-1:0] s_axis_b_tdata,
    input  wire                  s_axis_b_tvalid,
    output wire                  s_axis_b_tready,

    // Output result stream
    output wire [DATA_WIDTH-1:0] m_axis_tdata,
    output wire                  m_axis_tvalid,
    input  wire                  m_axis_tready,
    output wire                  m_axis_tlast
);
    // ========================================
    //                FIFO A
    // ========================================

    wire [DATA_WIDTH-1:0] fifo_a_m_axis_tdata;
    wire                  fifo_a_m_axis_tvalid;
    wire                  fifo_a_m_axis_tready;
    
    axis_data_fifo_bram axis_data_fifo_a (
        .s_axis_aclk(clk),
        .s_axis_aresetn(rstn),
        
        .s_axis_tdata (s_axis_a_tdata),    
        .s_axis_tvalid(s_axis_a_tvalid),
        .s_axis_tready(s_axis_a_tready),

        .m_axis_tdata (fifo_a_m_axis_tdata),    
        .m_axis_tvalid(fifo_a_m_axis_tvalid),
        .m_axis_tready(fifo_a_m_axis_tready)
    );
    
    // ========================================
    //                FIFO B
    // ========================================
    
    wire [DATA_WIDTH-1:0] fifo_b_m_axis_tdata;
    wire                  fifo_b_m_axis_tvalid;
    wire                  fifo_b_m_axis_tready;
    
    axis_data_fifo_bram axis_data_fifo_b (
        .s_axis_aclk(clk),        
        .s_axis_aresetn(rstn),
        
        .s_axis_tdata (s_axis_b_tdata),
        .s_axis_tvalid(s_axis_b_tvalid),
        .s_axis_tready(s_axis_b_tready),
    
        .m_axis_tdata (fifo_b_m_axis_tdata),
        .m_axis_tvalid(fifo_b_m_axis_tvalid),
        .m_axis_tready(fifo_b_m_axis_tready)
    );
    
    // ========================================
    //          Dot product logic
    // ========================================

    dot_product #(
        .WORDS_PER_TRANSFER(WORDS_PER_TRANSFER)
    ) dp (
        .clk(clk),
        .rstn(rstn),

        .s_axis_a_tdata(fifo_a_m_axis_tdata),
        .s_axis_a_tvalid(fifo_a_m_axis_tvalid),
        .s_axis_a_tready(fifo_a_m_axis_tready),

        .s_axis_b_tdata(fifo_b_m_axis_tdata),
        .s_axis_b_tvalid(fifo_b_m_axis_tvalid),
        .s_axis_b_tready(fifo_b_m_axis_tready),

        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast)
    );

endmodule
