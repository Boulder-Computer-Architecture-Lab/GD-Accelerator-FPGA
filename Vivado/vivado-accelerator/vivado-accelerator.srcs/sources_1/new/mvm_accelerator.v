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

    reg                   s_axis_c_tvalid;
    wire                  s_axis_c_tready;
    reg  [DATA_WIDTH-1:0] s_axis_c_tdata;

    wire                  fma_result_valid;
    wire                  fma_result_ready;
    wire [DATA_WIDTH-1:0] fma_result_data;

    // FMA Instance
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
    reg tlast_a_reg, tlast_b_reg;
    wire tlast;
    
    assign tlast = tlast_a_reg && tlast_b_reg;
    
    always @* begin
        if (!rstn) begin
            tlast_a_reg <= 1'b0;
            tlast_b_reg <= 1'b0;
        end else begin
            if (s_axis_a_tlast)
                tlast_a_reg <= 1'b1;
            if (s_axis_b_tlast)
                tlast_b_reg <= 1'b1;
            
            // Done
            if (m_axis_tvalid && m_axis_tready) begin
                tlast_a_reg <= 1'b0;
                tlast_b_reg <= 1'b0;
            end
        end
    end
    
    // ========================================
    
    assign fma_result_ready = s_axis_c_tready;
    
    always @(posedge clk) begin
        if (!rstn) begin
            s_axis_c_tdata   <= 64'd0;
            s_axis_c_tvalid  <= 1'b1;
            m_axis_tvalid    <= 1'b0;
            m_axis_tdata     <= 1'b0;
            m_axis_tlast     <= 1'b0;
        end else begin
            // Check for valid FMA output
            if (fma_result_valid && fma_result_ready) begin
                if (!tlast) begin
                    s_axis_c_tdata <= fma_result_data; // Loopback
                    s_axis_c_tvalid <= 1'b1;
                end
            end
            
            // FMA output consumed by accumulator
            if (s_axis_c_tvalid && s_axis_c_tready) begin
                s_axis_c_tvalid <= 1'b0;
            end 
            
            // If last forward to output
            if (tlast && fma_result_valid && m_axis_tready) begin
                m_axis_tdata  <= fma_result_data;
                m_axis_tvalid <= 1'b1;
                m_axis_tlast  <= 1'b1; 
            end
            
            // Done
            if (m_axis_tvalid && m_axis_tready) begin
                m_axis_tvalid <= 1'b0;
                m_axis_tlast  <= 1'b0;
                //s_axis_c_tvalid <= 1'b1; // Prepare for next transfer (this still gets reset after 1 cycle, need to fix)
            end
        end
    end
    
    assign m_axis_tkeep = KEEP_ENABLE ? {KEEP_WIDTH{1'b1}} : {KEEP_WIDTH{1'b0}};
    assign m_axis_tuser = {USER_WIDTH{1'b0}};

endmodule