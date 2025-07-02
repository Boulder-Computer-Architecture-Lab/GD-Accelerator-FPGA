`timescale 1ns / 1ps

module tb_mvm_accelerator;

    parameter DATA_WIDTH = 64;
    parameter KEEP_WIDTH = DATA_WIDTH / 8;
    parameter USER_WIDTH = 1;
    parameter VECTOR_LEN = 32;

    reg clk = 0;
    reg rstn = 0;

    // Inputs
    reg  [DATA_WIDTH-1:0] s_axis_a_tdata;
    reg  [KEEP_WIDTH-1:0] s_axis_a_tkeep;
    reg                   s_axis_a_tvalid;
    wire                  s_axis_a_tready;
    reg                   s_axis_a_tlast;
    reg  [USER_WIDTH-1:0] s_axis_a_tuser;

    reg  [DATA_WIDTH-1:0] s_axis_b_tdata;
    reg  [KEEP_WIDTH-1:0] s_axis_b_tkeep;
    reg                   s_axis_b_tvalid;
    wire                  s_axis_b_tready;
    reg                   s_axis_b_tlast;
    reg  [USER_WIDTH-1:0] s_axis_b_tuser;

    // Outputs
    wire [DATA_WIDTH-1:0] m_axis_tdata;
    wire [KEEP_WIDTH-1:0] m_axis_tkeep;
    wire                  m_axis_tvalid;
    reg                   m_axis_tready = 1;
    wire                  m_axis_tlast;
    wire [USER_WIDTH-1:0] m_axis_tuser;

    // Instantiate DUT
    mvm_accelerator uut (
        .clk(clk),
        .rstn(rstn),
        .s_axis_a_tdata(s_axis_a_tdata),
        .s_axis_a_tkeep(s_axis_a_tkeep),
        .s_axis_a_tvalid(s_axis_a_tvalid),
        .s_axis_a_tready(s_axis_a_tready),
        .s_axis_a_tlast(s_axis_a_tlast),
        .s_axis_a_tuser(s_axis_a_tuser),

        .s_axis_b_tdata(s_axis_b_tdata),
        .s_axis_b_tkeep(s_axis_b_tkeep),
        .s_axis_b_tvalid(s_axis_b_tvalid),
        .s_axis_b_tready(s_axis_b_tready),
        .s_axis_b_tlast(s_axis_b_tlast),
        .s_axis_b_tuser(s_axis_b_tuser),

        .m_axis_tdata(m_axis_tdata),
        .m_axis_tkeep(m_axis_tkeep),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tuser(m_axis_tuser)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Helper: convert real to IEEE 754
    function [63:0] real_to_bits(input real r);
        begin
            real_to_bits = $realtobits(r);
        end
    endfunction

    integer i;
    real a_values [0:VECTOR_LEN-1];
    real b_values [0:VECTOR_LEN-1];

    initial begin

        for (i = 0; i < VECTOR_LEN; i = i + 1) begin
            a_values[i] = i;
            b_values[i] = 10.0 * i;
        end
        
        // Init
        s_axis_a_tvalid = 0;
        s_axis_b_tvalid = 0;
        s_axis_a_tkeep  = 8'hFF;
        s_axis_b_tkeep  = 8'hFF;
        s_axis_a_tuser  = 0;
        s_axis_b_tuser  = 0;
        s_axis_a_tlast  = 0;
        s_axis_b_tlast  = 0;

        #45 rstn = 1;

        // Stimulus
        for (i = 0; i < VECTOR_LEN; i = i + 1) begin
            @(posedge clk);
            s_axis_a_tdata  <= real_to_bits(a_values[i]);
            s_axis_b_tdata  <= real_to_bits(b_values[i]);
            s_axis_a_tvalid <= 1;
            s_axis_b_tvalid <= 1;
            s_axis_a_tlast  <= (i == VECTOR_LEN-1);
            s_axis_b_tlast  <= (i == VECTOR_LEN-1);

            // Wait for ready
            wait (s_axis_a_tready && s_axis_b_tready);
            @(posedge clk);
            s_axis_a_tvalid <= 0;
            s_axis_b_tvalid <= 0;
        end
        
        s_axis_a_tlast = 0;
        s_axis_b_tlast = 0;
        
        // Wait for result
        wait (m_axis_tvalid);
        $display("Dot product result (IEEE 754): %h", m_axis_tdata);
        $display("Dot product result (real):     %f", $bitstoreal(m_axis_tdata));
        
        #100;
        $finish;
    end
endmodule
