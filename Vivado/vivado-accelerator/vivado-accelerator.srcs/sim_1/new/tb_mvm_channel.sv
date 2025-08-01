`timescale 1ns / 1ps

module tb_mvm_channel;

    parameter DATA_WIDTH = 1024;
    parameter ADDR_WIDTH = 32;
    parameter ID_WIDTH = 4;
    parameter STRB_WIDTH = DATA_WIDTH/8;
    
    parameter int VECTOR_LEN = 2048;
    
    localparam ELEMENTS_PER_WORD = DATA_WIDTH/64;
    localparam ELEMENT_WIDTH = DATA_WIDTH/ELEMENTS_PER_WORD;
    localparam WORDS_PER_TRANSFER = VECTOR_LEN/ELEMENTS_PER_WORD;
    
    reg clk = 0;
    reg rstn = 1;

    reg start = 0;
    
    // Inputs
    reg [DATA_WIDTH-1:0] s_axis_a_tdata;
    reg                  s_axis_a_tvalid;
    reg                  s_axis_a_tready;
    
    reg [DATA_WIDTH-1:0] s_axis_b_tdata;
    reg                  s_axis_b_tvalid;
    reg                  s_axis_b_tready;
    
    // Outputs
    reg [ELEMENT_WIDTH-1:0] m_axis_tdata;
    reg                     m_axis_tvalid;
    reg                     m_axis_tready;
    reg                     m_axis_tlast;
    
    // Buffer signals
    wire [DATA_WIDTH-1:0] fifo_a_m_axis_tdata;
    wire                  fifo_a_m_axis_tvalid;
    wire                  fifo_a_m_axis_tready;
    wire [DATA_WIDTH-1:0] fifo_b_m_axis_tdata;
    wire                  fifo_b_m_axis_tvalid;
    wire                  fifo_b_m_axis_tready;
    
    // FIFO A
    axis_data_fifo_bram axis_data_fifo_in (
        .s_axis_aclk(clk),
        .s_axis_aresetn(rstn),
        
        .s_axis_tdata (s_axis_a_tdata),    
        .s_axis_tvalid(s_axis_a_tvalid),
        .s_axis_tready(s_axis_a_tready),

        .m_axis_tdata (fifo_a_m_axis_tdata),    
        .m_axis_tvalid(fifo_a_m_axis_tvalid),
        .m_axis_tready(fifo_a_m_axis_tready)
    );
    
    // FIFO B
    axis_data_fifo_bram axis_data_fifo_b (
        .s_axis_aclk(clk),        
        .s_axis_aresetn(rstn),
        
        .s_axis_tdata (s_axis_b_tdata),
        .s_axis_tvalid(s_axis_b_tvalid),
        .s_axis_tready(s_axis_b_tready),
    
        .m_axis_tdata (fifo_b_m_axis_tdata),
        .m_axis_tvalid(fifo_b_m_axis_tvalid),
        .m_axis_tready(fifo_b_m_axis_tready)
    );

    // DUT
    mvm_compute #(
        .DATA_WIDTH(DATA_WIDTH),
        .ELEMENTS_PER_WORD(ELEMENTS_PER_WORD),
        .ELEMENT_WIDTH(ELEMENT_WIDTH),
        .WORDS_PER_TRANSFER(WORDS_PER_TRANSFER)
    ) dut (
        .clk(clk),
        .rstn(rstn),

        .s_axis_a_tdata(fifo_a_m_axis_tdata),
        .s_axis_a_tvalid(fifo_a_m_axis_tvalid),
        .s_axis_a_tready(fifo_a_m_axis_tready),

        .s_axis_b_tdata(fifo_b_m_axis_tdata),
        .s_axis_b_tvalid(fifo_b_m_axis_tvalid),
        .s_axis_b_tready(fifo_b_m_axis_tready),

        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast)
    );
        
    // Clock
    always #5 clk = ~clk;
    
    real a_values [VECTOR_LEN];
    real b_values [VECTOR_LEN];
    
    real expected_partial [ELEMENTS_PER_WORD];
    real expected = 0.0;
        
    // Initialization
    initial begin
    
        rstn = 0;
        #45 rstn = 1;
        
        repeat (3) @(posedge clk);
    
        m_axis_tready = 1;
        
        for (int j = 0; j < VECTOR_LEN; j = j + 1) begin
            a_values[j] = (j+1) / 1000.0;
            b_values[j] = (j+1) / 10000.0;
            expected += a_values[j] * b_values[j];
            $display("a[%0d] = %f (hex = %h), b[%0d] = %f (hex = %h)", 
                            j, a_values[j], $realtobits(a_values[j]), j, b_values[j], $realtobits(b_values[j]));
        end
        
        for (int k = 0; k < ELEMENTS_PER_WORD; k++) begin
            expected_partial[k] = 0.0;
    
            for (int i = 0; i < WORDS_PER_TRANSFER; i++) begin
                expected_partial[k] += a_values[i * ELEMENTS_PER_WORD + k] * b_values[i * ELEMENTS_PER_WORD + k];
            end
    
            $display("partial[%0d] = %f (hex = %h)",
                            k, expected_partial[k], $realtobits(expected_partial[k]));
        end
        
        start = 1;
    end
                
    // AXIS A stream driver
    initial begin
        wait(start);
        repeat (10) @(posedge clk);

        for (int i = 0; i < VECTOR_LEN; i += ELEMENTS_PER_WORD) begin
            s_axis_a_tdata = '0;
            for (int j = 0; j < ELEMENTS_PER_WORD; j++) begin
                s_axis_a_tdata[j*64 +: 64] = $realtobits(a_values[i + j]);
            end

            s_axis_a_tvalid = 1;
            wait (s_axis_a_tready);
            @(posedge clk);
            s_axis_a_tvalid = 0;
        end
    end

    // AXIS B stream driver
    initial begin
        wait(start);
        repeat (10) @(posedge clk);

        for (int i = 0; i < VECTOR_LEN; i += ELEMENTS_PER_WORD) begin
            s_axis_b_tdata = '0;
            for (int j = 0; j < ELEMENTS_PER_WORD; j++) begin
                s_axis_b_tdata[j*64 +: 64] = $realtobits(b_values[i + j]);
            end

            s_axis_b_tvalid = 1;
            wait (s_axis_b_tready);
            @(posedge clk);
            s_axis_b_tvalid = 0;
        end
    end

    // Output checker
    initial begin
        wait(start);
        
        wait (m_axis_tvalid);
        @(posedge clk);

        $display("Result   = %f", $bitstoreal(m_axis_tdata));
        $display("Expected = %f", expected);

        repeat (10) @(posedge clk);
        $finish;
    end

endmodule