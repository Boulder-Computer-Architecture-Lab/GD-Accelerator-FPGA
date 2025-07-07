`timescale 1ns / 1ps

module tb_mvm_accelerator;

    parameter DATA_WIDTH = 64;
    parameter VECTOR_LEN = 16;
    parameter NUM_TRANSFERS = 8;

    reg clk = 0;
    reg rstn = 1;

    // Inputs
    reg  [DATA_WIDTH-1:0] s_axis_a_0_tdata, s_axis_a_1_tdata;
    reg                   s_axis_a_0_tvalid, s_axis_a_1_tvalid;
    wire                  s_axis_a_0_tready, s_axis_a_1_tready;
    
    reg  [DATA_WIDTH-1:0] s_axis_b_tdata;
    reg                   s_axis_b_tvalid;
    wire                  s_axis_b_tready;

    // Outputs
    wire [DATA_WIDTH-1:0] m_axis_0_tdata, m_axis_1_tdata;
    wire                  m_axis_0_tvalid, m_axis_1_tvalid;
    reg                   m_axis_0_tready, m_axis_1_tready;
    wire                  m_axis_0_tlast, m_axis_1_tlast;


    // Instantiate DUT
    mvm_accelerator #(.WORDS_PER_TRANSFER(VECTOR_LEN)) uut (
        .clk(clk),
        .rstn(rstn),
    
        .s_axis_a_0_tdata(s_axis_a_0_tdata),
        .s_axis_a_0_tvalid(s_axis_a_0_tvalid),
        .s_axis_a_0_tready(s_axis_a_0_tready),
    
        .s_axis_a_1_tdata(s_axis_a_1_tdata),
        .s_axis_a_1_tvalid(s_axis_a_1_tvalid),
        .s_axis_a_1_tready(s_axis_a_1_tready),
    
        .s_axis_b_tdata(s_axis_b_tdata),
        .s_axis_b_tvalid(s_axis_b_tvalid),
        .s_axis_b_tready(s_axis_b_tready),
    
        .m_axis_0_tdata(m_axis_0_tdata),
        .m_axis_0_tvalid(m_axis_0_tvalid),
        .m_axis_0_tready(m_axis_0_tready),
        .m_axis_0_tlast(m_axis_0_tlast),
    
        .m_axis_1_tdata(m_axis_1_tdata),
        .m_axis_1_tvalid(m_axis_1_tvalid),
        .m_axis_1_tready(m_axis_1_tready),
        .m_axis_1_tlast(m_axis_1_tlast)
    );
    
    // Simulate backpressure
    always @(posedge clk) begin
        m_axis_0_tready <= ($urandom_range(0, 99) < 80); // 80% of the time ready
        m_axis_1_tready <= ($urandom_range(0, 99) < 80); // 80% of the time ready
    end

    // Clock generation
    always #5 clk = ~clk;

    integer i, j;
    real a0_values [0:VECTOR_LEN-1];
    real a1_values [0:VECTOR_LEN-1];
    real b_values [0:VECTOR_LEN-1];
    real expected_0, expected_1;

    initial begin

        for (i = 0; i < VECTOR_LEN; i = i + 1) begin
            a0_values[i] = (i+1) / 100.0;
            a1_values[i] = (i+1) / 200.0;
            b_values[i] = (i+1) / 1000.0;
        end
        
        rstn = 0;
        #45 rstn = 1;
                            
        for (j = 0; j < NUM_TRANSFERS; j = j + 1) begin
            
            // Init
            s_axis_a_0_tvalid = 0;
            s_axis_a_1_tvalid = 0;
            s_axis_b_tvalid = 0;
            
            i = 0;
            expected_0 = 0;
            expected_1 = 0;
        
            // Stimulus
            while (i < VECTOR_LEN) begin
                repeat (1 + $urandom_range(0, 3)) @(posedge clk);
            
                s_axis_a_0_tdata <= $realtobits(a0_values[i]);
                s_axis_a_1_tdata <= $realtobits(a1_values[i]);
                s_axis_b_tdata   <= $realtobits(b_values[i]);
            
            if ($urandom_range(0, 99) < 80) begin
                s_axis_a_0_tvalid <= 1;
                s_axis_a_1_tvalid <= 1;
                s_axis_b_tvalid   <= 1;
            
                // Wait until all inputs are actually accepted
                while (!(s_axis_a_0_tready && s_axis_a_0_tvalid &&
                         s_axis_a_1_tready && s_axis_a_1_tvalid &&
                         s_axis_b_tready   && s_axis_b_tvalid))
                    @(posedge clk);
            
                s_axis_a_0_tvalid <= 0;
                s_axis_a_1_tvalid <= 0;
                s_axis_b_tvalid   <= 0;
            
                expected_0 = expected_0 + (a0_values[i] * b_values[i]);
                expected_1 = expected_1 + (a1_values[i] * b_values[i]);
                i = i + 1;
                end else begin
                    @(posedge clk);
                end
            end
            
            wait (m_axis_0_tvalid && m_axis_0_tready && m_axis_0_tlast);
            wait (m_axis_1_tvalid && m_axis_1_tready && m_axis_1_tvalid);
            @(posedge clk)
            
            $display("Result 0 (real): %f | Expected: %f", $bitstoreal(m_axis_0_tdata), expected_0);
            $display("Result 1 (real): %f | Expected: %f", $bitstoreal(m_axis_1_tdata), expected_1);
            #50;
        end
        
        #50;
        $finish;
    end

endmodule
