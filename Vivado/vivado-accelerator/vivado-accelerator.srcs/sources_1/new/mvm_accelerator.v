`timescale 1ns / 1ps

module mvm_accelerator #(
    parameter DATA_WIDTH = 64,
    parameter KEEP_ENABLE = (DATA_WIDTH > 8),
    parameter KEEP_WIDTH = (DATA_WIDTH + 7) / 8,
    parameter LAST_ENABLE = 1,
    parameter USER_ENABLE = 0,
    parameter USER_WIDTH = 1
)(
    input wire clk,
    input wire rstn,

    // FIFO A output
    input  wire [DATA_WIDTH-1:0]  s_axis_a_tdata,
    input  wire [KEEP_WIDTH-1:0]  s_axis_a_tkeep,
    input  wire                   s_axis_a_tvalid,
    output wire                   s_axis_a_tready,
    input  wire                   s_axis_a_tlast,
    input  wire [USER_WIDTH-1:0]  s_axis_a_tuser,

    // FIFO B output
    input  wire [DATA_WIDTH-1:0]  s_axis_b_tdata,
    input  wire [KEEP_WIDTH-1:0]  s_axis_b_tkeep,
    input  wire                   s_axis_b_tvalid,
    output wire                   s_axis_b_tready,
    input  wire                   s_axis_b_tlast,
    input  wire [USER_WIDTH-1:0]  s_axis_b_tuser,

    // Output stream
    output wire [DATA_WIDTH-1:0]  m_axis_tdata,
    output reg  [KEEP_WIDTH-1:0]  m_axis_tkeep,
    output wire                   m_axis_tvalid,
    input  wire                   m_axis_tready,
    output reg                    m_axis_tlast,
    output reg  [USER_WIDTH-1:0]  m_axis_tuser
);

// Instantiate floating-point adder
fp64_adder u_fp64_adder (
    .aclk(clk),
    .aresetn(rstn),

    .s_axis_a_tvalid(s_axis_a_tvalid),
    .s_axis_a_tready(s_axis_a_tready),
    .s_axis_a_tdata(s_axis_a_tdata),
    .s_axis_a_tlast(s_axis_a_tlast),

    .s_axis_b_tvalid(s_axis_b_tvalid),
    .s_axis_b_tready(s_axis_b_tready),
    .s_axis_b_tdata(s_axis_b_tdata),
    .s_axis_b_tlast(s_axis_b_tlast),

    .m_axis_result_tvalid(m_axis_tvalid),
    .m_axis_result_tready(m_axis_tready),
    .m_axis_result_tdata(m_axis_tdata)
);

always @(posedge clk) begin
    if (!rstn) begin
        m_axis_tkeep <= 0;
        m_axis_tuser <= 0;
        m_axis_tlast <= 0;
    end else begin
        m_axis_tkeep <= KEEP_ENABLE ? s_axis_a_tkeep : {KEEP_WIDTH{1'b1}};
        m_axis_tuser <= USER_ENABLE ? s_axis_a_tuser : {USER_WIDTH{1'b0}};
        m_axis_tlast <= LAST_ENABLE ? s_axis_a_tlast : 1'b0;
    end
end

endmodule
