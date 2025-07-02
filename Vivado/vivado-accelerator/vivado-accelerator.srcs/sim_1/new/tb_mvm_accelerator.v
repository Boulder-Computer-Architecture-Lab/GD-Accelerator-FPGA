`timescale 1ns / 1ps

module tb_mvm_accelerator;

    parameter DATA_WIDTH = 64;
    parameter KEEP_WIDTH = DATA_WIDTH / 8;
    parameter USER_WIDTH = 1;
    parameter VECTOR_LEN = 64;
    parameter NUM_TRANSFERS = 2;

    reg clk = 0;
    reg rstn = 1;

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
    mvm_accelerator #(.WORDS_PER_TRANSFER(VECTOR_LEN)) uut (
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

    integer i, j;
    real a_values [0:VECTOR_LEN*NUM_TRANSFERS-1];
    real b_values [0:VECTOR_LEN*NUM_TRANSFERS-1];
    real expected = 0.0;

    initial begin

        for (i = 0; i < VECTOR_LEN*NUM_TRANSFERS; i = i + 1) begin
            a_values[i] = (i+1) / 10.0;
            b_values[i] = (i+1) / 100.0;
            $display("a[%2d]: %h, %f | b[%2d]: %h, %f", i, $realtobits(a_values[i]), a_values[i], i, $realtobits(b_values[i]), b_values[i]);
        end
        
        rstn = 0;
        #45 rstn = 1;
                            
        for (j = 0; j < NUM_TRANSFERS; j = j + 1) begin
            
            // Init
            s_axis_a_tvalid = 0;
            s_axis_b_tvalid = 0;
            s_axis_a_tkeep  = 8'hFF;
            s_axis_b_tkeep  = 8'hFF;
            s_axis_a_tuser  = 0;
            s_axis_b_tuser  = 0;
            s_axis_a_tlast  = 0;
            s_axis_b_tlast  = 0;
        
            // Stimulus
            for (i = j*VECTOR_LEN; i < (j+1)*VECTOR_LEN; i = i + 1) begin
                expected = expected + (a_values[i] * b_values[i]);
            
                @(posedge clk);
                s_axis_a_tdata  <= $realtobits(a_values[i]);
                s_axis_b_tdata  <= $realtobits(b_values[i]);
                s_axis_a_tvalid <= 1;
                s_axis_b_tvalid <= 1;
                s_axis_a_tlast  <= (i == ((j+1)*VECTOR_LEN - 1));
                s_axis_b_tlast  <= (i == ((j+1)*VECTOR_LEN - 1));
    
                // Wait for ready
                wait (s_axis_a_tready && s_axis_b_tready);
                @(posedge clk);
                s_axis_a_tvalid <= 0;
                s_axis_b_tvalid <= 0;
                s_axis_a_tlast = 0;
                s_axis_b_tlast = 0;
            end
            
            wait (m_axis_tvalid);
            @(posedge clk)
            $display("Result #%0d (IEEE 754): %h", j, m_axis_tdata);
            $display("Result #%0d (real):     %f", j, $bitstoreal(m_axis_tdata));
            $display("Expected result #%0d: %f", j, expected);
    
            // Wait until DUT deasserts valid (i.e., result consumed)
            wait (!m_axis_tvalid);
            #50;
        
        end
        
        #100;
        $finish;
    end

endmodule
