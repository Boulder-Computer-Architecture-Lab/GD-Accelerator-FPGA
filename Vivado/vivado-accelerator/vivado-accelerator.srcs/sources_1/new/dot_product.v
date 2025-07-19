`timescale 1ns / 1ps

module dot_product #(
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
    
    // Accumulator input (multiplier output)
    wire                  acc_axis_a_tvalid;
    wire                  acc_axis_a_tready;
    wire [DATA_WIDTH-1:0] acc_axis_a_tdata;
    wire                  acc_axis_a_tlast;
    
    // Accumulator output
    wire                  acc_axis_result_tvalid;
    wire                  acc_axis_result_tready;
    wire [DATA_WIDTH-1:0] acc_axis_result_tdata;
    wire                  acc_axis_result_tlast;

    // Instance
    fp64_mult u_fp64_mult (
        .aclk(clk),
        .aresetn(rstn),
        
        .s_axis_a_tvalid(s_axis_a_tvalid),
        .s_axis_a_tready(s_axis_a_tready),
        .s_axis_a_tdata(s_axis_a_tdata),

        .s_axis_b_tvalid(s_axis_b_tvalid),
        .s_axis_b_tready(s_axis_b_tready),
        .s_axis_b_tdata(s_axis_b_tdata),

        .m_axis_result_tvalid(acc_axis_a_tvalid),
        .m_axis_result_tready(acc_axis_a_tready),
        .m_axis_result_tdata(acc_axis_a_tdata)
    );
    
    fp64_accum u_fp64_accum (
        .aclk(clk),
        .aresetn(rstn),

        .s_axis_a_tvalid(acc_axis_a_tvalid),
        .s_axis_a_tready(acc_axis_a_tready),
        .s_axis_a_tdata(acc_axis_a_tdata),
        .s_axis_a_tlast(acc_axis_a_tlast),

        .m_axis_result_tvalid(acc_axis_result_tvalid),
        .m_axis_result_tready(acc_axis_result_tready),
        .m_axis_result_tdata(acc_axis_result_tdata),
        .m_axis_result_tlast(acc_axis_result_tlast)
    );
    
    // ========================================
    // Tlast handling
    
    reg [$clog2(WORDS_PER_TRANSFER+1):0] word_count;
    
    assign tlast = (word_count == WORDS_PER_TRANSFER - 1);
    assign acc_axis_a_tlast = tlast && acc_axis_a_tready && acc_axis_a_tvalid;
    assign m_axis_tlast = tlast && m_axis_tvalid;
    
    always @(posedge clk) begin
        if (!rstn) begin
            word_count <= 0;
        end else begin
            if (!tlast) begin
                if (acc_axis_a_tvalid && acc_axis_a_tready) begin
                    word_count <= word_count + 1;
                end
            end else if (m_axis_tvalid && m_axis_tready && m_axis_tlast) begin
                word_count <= 0;
            end
        end
    end
    
    // ========================================
    // Forward output
    
    always @(posedge clk) begin
        if (!rstn) begin
            m_axis_tdata  <= 64'd0;
            m_axis_tvalid <= 1'b0;
        end else begin
            if (acc_axis_result_tvalid && acc_axis_result_tready) begin
                if (acc_axis_result_tlast) begin
                    m_axis_tdata  <= acc_axis_result_tdata;
                    m_axis_tvalid <= 1'b1;
                end
            end
    
            if (m_axis_tvalid && m_axis_tready) begin
                m_axis_tvalid <= 1'b0;
            end
        end
    end
    
    assign acc_axis_result_tready = !m_axis_tvalid || (m_axis_tvalid & m_axis_tready);


endmodule