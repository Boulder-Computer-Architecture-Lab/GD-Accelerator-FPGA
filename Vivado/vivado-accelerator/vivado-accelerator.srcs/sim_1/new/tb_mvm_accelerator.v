`timescale 1ns / 1ps

module tb_mvm_accelerator;

    parameter DATA_WIDTH = 64;
    parameter VECTOR_LEN = 256;
    parameter NUM_TRANSFERS = 2;

    reg clk = 0;
    reg rstn = 1;

    // Inputs
    reg  [DATA_WIDTH-1:0] s_axis_a_tdata;
    reg                   s_axis_a_tvalid;
    wire                  s_axis_a_tready;

    reg  [DATA_WIDTH-1:0] s_axis_b_tdata;
    reg                   s_axis_b_tvalid;
    wire                  s_axis_b_tready;

    // Outputs
    wire [DATA_WIDTH-1:0] m_axis_tdata;
    wire                  m_axis_tvalid;
    reg                   m_axis_tready;
    wire                  m_axis_tlast;


    // Instantiate DUT
    mvm_accelerator #(.WORDS_PER_TRANSFER(VECTOR_LEN)) uut (
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
    
    // Simulate backpressure
    always @(posedge clk) begin
        m_axis_tready <= ($urandom_range(0, 99) < 80); // 80% of the time ready
    end

    // Clock generation
    always #5 clk = ~clk;

    integer i, j;
    real a_values [0:VECTOR_LEN-1];
    real b_values [0:VECTOR_LEN-1];
    real expected;

    initial begin

        for (i = 0; i < VECTOR_LEN; i = i + 1) begin
            a_values[i] = (i+1) / 100.0;
            b_values[i] = (i+1) / 1000.0;
            $display("a[%2d]: %h, %f | b[%2d]: %h, %f", i, $realtobits(a_values[i]), a_values[i], i, $realtobits(b_values[i]), b_values[i]);
        end
        
        rstn = 0;
        #45 rstn = 1;
                            
        for (j = 0; j < NUM_TRANSFERS; j = j + 1) begin
            
            // Init
            s_axis_a_tvalid = 0;
            s_axis_b_tvalid = 0;
            expected = 0;
            i = 0;
        
            // Stimulus
            while (i < VECTOR_LEN) begin
                // Random stall before each word
                s_axis_a_tvalid <= 0;
                s_axis_b_tvalid <= 0;
                repeat (1 + $urandom_range(0, 3)) @(posedge clk);  // Optional initial delay
                
                s_axis_a_tdata <= $realtobits(a_values[i]);
                s_axis_b_tdata <= $realtobits(b_values[i]);
                
                if ($urandom_range(0, 99) < 80) begin
                    // Assert tvalid
                    s_axis_a_tvalid <= 1;
                    s_axis_b_tvalid <= 1;
                
                    // Wait for both ready signals (AXI handshake)
                    wait (s_axis_a_tready && s_axis_b_tready);
                    @(posedge clk);
                
                    // Deassert tvalid after handshake
                    s_axis_a_tvalid <= 0;
                    s_axis_b_tvalid <= 0;
                    
                    // Increment counter and accumulate expected
                    expected = expected + (a_values[i] * b_values[i]);
                    i = i + 1;
                end else begin
                    // Insert a bubble/stall (no valid this cycle)
                    @(posedge clk);
                end
            end
            
            wait (m_axis_tvalid && m_axis_tready);
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
