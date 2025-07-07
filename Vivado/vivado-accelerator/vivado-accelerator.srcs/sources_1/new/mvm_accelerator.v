`timescale 1ns / 1ps

module mvm_accelerator #(
    parameter DATA_WIDTH = 64,
    parameter WORDS_PER_TRANSFER = 17048
)(
    input wire clk,
    input wire rstn,

    // Input stream A
    input  wire [DATA_WIDTH-1:0]  s_axis_a_tdata,
    input  wire                   s_axis_a_tvalid,
    output wire                   s_axis_a_tready,

    // Input stream B
    input  wire [DATA_WIDTH-1:0]  s_axis_b_tdata,
    input  wire                   s_axis_b_tvalid,
    output wire                   s_axis_b_tready,

    // Output stream
    output wire [DATA_WIDTH-1:0]  m_axis_tdata,
    output wire                   m_axis_tvalid,
    input  wire                   m_axis_tready,
    output wire                   m_axis_tlast
);

    fma_wrapper #(
        .DATA_WIDTH(DATA_WIDTH),
        .WORDS_PER_TRANSFER(WORDS_PER_TRANSFER)
    ) u_fma_wrapper (
        .clk(clk),
        .rstn(rstn),

        .s_axis_a_tdata(s_axis_a_tdata),
        .s_axis_a_tvalid(s_axis_a_tvalid),
        .s_axis_a_tready(s_axis_a_tready),

        .s_axis_b_tdata(s_axis_b_tdata),
        .s_axis_b_tvalid(s_axis_b_tvalid),
        .s_axis_b_tready(s_axis_b_tready),

        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast)
    );

endmodule
