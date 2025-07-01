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

    // Input stream A
    input  wire [DATA_WIDTH-1:0]  s_axis_a_tdata,
    input  wire [KEEP_WIDTH-1:0]  s_axis_a_tkeep,
    input  wire                   s_axis_a_tvalid,
    output wire                   s_axis_a_tready,
    input  wire                   s_axis_a_tlast,
    input  wire [USER_WIDTH-1:0]  s_axis_a_tuser,

    // Input stream B
    input  wire [DATA_WIDTH-1:0]  s_axis_b_tdata,
    input  wire [KEEP_WIDTH-1:0]  s_axis_b_tkeep,
    input  wire                   s_axis_b_tvalid,
    output wire                   s_axis_b_tready,
    input  wire                   s_axis_b_tlast,
    input  wire [USER_WIDTH-1:0]  s_axis_b_tuser,

    // Output stream
    output reg  [DATA_WIDTH-1:0]  m_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  m_axis_tkeep,
    output reg                    m_axis_tvalid,
    input  wire                   m_axis_tready,
    output reg                    m_axis_tlast,
    output wire [USER_WIDTH-1:0]  m_axis_tuser
);

    assign m_axis_tkeep = KEEP_ENABLE ? {KEEP_WIDTH{1'b1}} : {KEEP_WIDTH{1'b0}};
    assign m_axis_tuser = {USER_WIDTH{1'b0}};

    reg  [DATA_WIDTH-1:0] acc_data;
    wire                  acc_ready;
    reg                   acc_valid;

    wire [DATA_WIDTH-1:0] fma_result;
    wire                  fma_result_valid;

    reg got_last;

    // Floating-point FMA
    fp64_fma u_fp64_fma (
        .aclk(clk),
        .aresetn(rstn),

        .s_axis_a_tvalid(s_axis_a_tvalid),
        .s_axis_a_tready(s_axis_a_tready),
        .s_axis_a_tdata(s_axis_a_tdata),

        .s_axis_b_tvalid(s_axis_b_tvalid),
        .s_axis_b_tready(s_axis_b_tready),
        .s_axis_b_tdata(s_axis_b_tdata),

        .s_axis_c_tvalid(acc_valid),
        .s_axis_c_tready(acc_ready),
        .s_axis_c_tdata(acc_data),

        .m_axis_result_tvalid(fma_result_valid),
        .m_axis_result_tready(acc_ready),
        .m_axis_result_tdata(fma_result)
    );

    // Accumulate and output
    always @(posedge clk) begin
        if (!rstn) begin
            acc_data      <= 64'd0;
            acc_valid     <= 1'b0;
            m_axis_tvalid <= 1'b0;
            m_axis_tlast  <= 1'b0;
            got_last      <= 1'b0;
        end else begin
            if (acc_ready) begin
                acc_valid <= 1'b1;
            end
            
            if (fma_result_valid) begin
                acc_data <= fma_result;
            end
            
            if (s_axis_a_tvalid && s_axis_a_tlast && acc_ready) begin
                got_last <= 1'b1;
            end

            if (got_last && fma_result_valid) begin
                m_axis_tvalid <= 1'b1;
                m_axis_tlast  <= 1'b1;
                m_axis_tdata  <= fma_result;
                got_last      <= 1'b0;
            end else if (m_axis_tvalid && m_axis_tready) begin
                m_axis_tvalid <= 1'b0;
                m_axis_tlast  <= 1'b0;
            end
        end
    end

endmodule
