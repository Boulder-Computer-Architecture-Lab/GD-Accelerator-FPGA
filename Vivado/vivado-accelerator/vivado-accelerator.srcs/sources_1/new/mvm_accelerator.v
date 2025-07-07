`timescale 1ns / 1ps

module mvm_accelerator #(
    parameter DATA_WIDTH = 64,
    parameter WORDS_PER_TRANSFER = 17048
)(
    input wire clk,
    input wire rstn,

    // Input stream A_0
    input  wire [DATA_WIDTH-1:0]  s_axis_a_0_tdata,
    input  wire                   s_axis_a_0_tvalid,
    output wire                   s_axis_a_0_tready,    
    
    // Input stream A_1
    input  wire [DATA_WIDTH-1:0]  s_axis_a_1_tdata,
    input  wire                   s_axis_a_1_tvalid,
    output wire                   s_axis_a_1_tready,

    // Input stream B
    input  wire [DATA_WIDTH-1:0]  s_axis_b_tdata,
    input  wire                   s_axis_b_tvalid,
    output wire                   s_axis_b_tready,

    // Output stream 0
    output wire [DATA_WIDTH-1:0]  m_axis_0_tdata,
    output wire                   m_axis_0_tvalid,
    input  wire                   m_axis_0_tready,
    output wire                   m_axis_0_tlast,
      
    // Output stream 0
    output wire [DATA_WIDTH-1:0]  m_axis_1_tdata,
    output wire                   m_axis_1_tvalid,
    input  wire                   m_axis_1_tready,
    output wire                   m_axis_1_tlast
);
    // =============================================================

    // Broadcasted outputs
    wire [DATA_WIDTH-1:0] b0_data, b1_data;
    wire                  b0_valid, b1_valid;
    wire                  b0_ready, b1_ready;
    
    // Broadcaster instance
    axis_broadcaster_0 bcast (
        .aclk(clk),
        .aresetn(rstn),
    
        // Single input from PS or AXI DMA
        .s_axis_tvalid(s_axis_b_tvalid),
        .s_axis_tdata(s_axis_b_tdata),
        .s_axis_tready(s_axis_b_tready),
    
        // Broadcasted outputs
        .m_axis_tvalid({b1_valid, b0_valid}),
        .m_axis_tready({b1_ready, b0_ready}),
        .m_axis_tdata({b1_data, b0_data})
    );
    
    // =============================================================

    // FMA instance 0
    fma_wrapper #(
        .DATA_WIDTH(DATA_WIDTH),
        .WORDS_PER_TRANSFER(WORDS_PER_TRANSFER)
    ) fma0 (
        .clk(clk),
        .rstn(rstn),

        .s_axis_a_tdata(s_axis_a_0_tdata),
        .s_axis_a_tvalid(s_axis_a_0_tvalid),
        .s_axis_a_tready(s_axis_a_0_tready),

        .s_axis_b_tdata(b0_data),
        .s_axis_b_tvalid(b0_valid),
        .s_axis_b_tready(b0_ready),

        .m_axis_tdata(m_axis_0_tdata),
        .m_axis_tvalid(m_axis_0_tvalid),
        .m_axis_tready(m_axis_0_tready),
        .m_axis_tlast(m_axis_0_tlast)
    );
    
    // =============================================================
    
    // FMA instance 1
    fma_wrapper #(
        .DATA_WIDTH(DATA_WIDTH),
        .WORDS_PER_TRANSFER(WORDS_PER_TRANSFER)
    ) fma1 (
        .clk(clk),
        .rstn(rstn),

        .s_axis_a_tdata(s_axis_a_1_tdata),
        .s_axis_a_tvalid(s_axis_a_1_tvalid),
        .s_axis_a_tready(s_axis_a_1_tready),

        .s_axis_b_tdata(b1_data),
        .s_axis_b_tvalid(b1_valid),
        .s_axis_b_tready(b1_ready),

        .m_axis_tdata(m_axis_1_tdata),
        .m_axis_tvalid(m_axis_1_tvalid),
        .m_axis_tready(m_axis_1_tready),
        .m_axis_tlast(m_axis_1_tlast)
    );
    
    // =============================================================

endmodule
