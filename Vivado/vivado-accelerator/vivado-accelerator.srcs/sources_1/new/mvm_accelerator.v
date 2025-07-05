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
    output reg  [DATA_WIDTH-1:0]  m_axis_tdata,
    output reg                    m_axis_tvalid,
    input  wire                   m_axis_tready,
    output wire                   m_axis_tlast
);
  
    // ========================================
    // FMA

    // s_axis_c (accumulator)
    reg                   s_axis_c_tvalid;
    wire                  s_axis_c_tready;
    reg  [DATA_WIDTH-1:0] s_axis_c_tdata;
    // FMA output
    wire                  fma_result_valid;
    wire                  fma_result_ready;
    wire [DATA_WIDTH-1:0] fma_result_data;
    
    // Instance
    fp64_fma u_fp64_fma (
        .aclk(clk),
        .aresetn(rstn),

        .s_axis_a_tvalid(s_axis_a_tvalid),
        .s_axis_a_tready(s_axis_a_tready),
        .s_axis_a_tdata(s_axis_a_tdata),

        .s_axis_b_tvalid(s_axis_b_tvalid),
        .s_axis_b_tready(s_axis_b_tready),
        .s_axis_b_tdata(s_axis_b_tdata),

        .s_axis_c_tvalid(s_axis_c_tvalid),
        .s_axis_c_tready(s_axis_c_tready),
        .s_axis_c_tdata(s_axis_c_tdata),

        .m_axis_result_tvalid(fma_result_valid),
        .m_axis_result_tready(fma_result_ready),
        .m_axis_result_tdata(fma_result_data)
    );
    
    // ========================================
    // Internal counter (not using axis_tlast)
    
    reg [$clog2(WORDS_PER_TRANSFER+1):0] word_count;
    wire tlast;
    
    assign tlast = (word_count == WORDS_PER_TRANSFER-1);
    
    always @(posedge clk) begin
        if (!rstn) begin
            word_count <= 0;
        end else begin
            if (!tlast) begin
                if (fma_result_valid && fma_result_ready) begin
                    word_count <= word_count + 1;
                end
            end else if (m_axis_tvalid && m_axis_tready) begin
                word_count <= 0;
            end
        end
    end
    
    // ========================================
    // Accumulator logic
    assign fma_result_ready = tlast ? m_axis_tready : s_axis_c_tready; // accumulator loopback
    assign m_axis_tlast = m_axis_tvalid; // only one output value
    
    always @(posedge clk) begin
        if (!rstn) begin
            s_axis_c_tdata      <= 64'd0;
            s_axis_c_tvalid     <= 1'b1;
            m_axis_tvalid       <= 1'b0;
            m_axis_tdata        <= 64'd0;
        end else begin
            if (!tlast) begin
                // Accumulate fma_result
                if (fma_result_valid && fma_result_ready) begin
                    s_axis_c_tdata <= fma_result_data;
                    s_axis_c_tvalid <= 1'b1;
                end
            end else begin
                // Forward data to output
                if (fma_result_valid && !m_axis_tvalid) begin
                    m_axis_tdata  <= fma_result_data;
                    m_axis_tvalid <= 1'b1;
                end
                // Reset accumulator once output is consumed
                if (m_axis_tvalid && m_axis_tready) begin
                    m_axis_tvalid   <= 1'b0;
                    s_axis_c_tdata  <= 64'd0;
                    s_axis_c_tvalid <= 1'b1;
                end
            end
            // FMA should always consume s_axis_c
            if (s_axis_c_tvalid && s_axis_c_tready) begin
                s_axis_c_tvalid <= 1'b0;
            end
        end
    end
    
    // ========================================

endmodule