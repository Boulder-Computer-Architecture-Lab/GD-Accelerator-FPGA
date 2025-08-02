`timescale 1ns / 1ps

module tb_mvm_accelerator;

    `include "axi_a_channel_bindings.svh"
    `define GET_CHANNELS `CHANNELS_4 // `CHANNELS_{CHANNELS_PER_INST} (must match parameter)

    parameter ARCH_TYPE = 0; // select accelerator type (0=split, 1=async, 2=sync)

    parameter DATA_WIDTH = 1024;
    parameter ADDR_WIDTH = 32;
    parameter ID_WIDTH = 4;
    parameter STRB_WIDTH = DATA_WIDTH/8;
    
    parameter ELEMENT_WIDTH = 64;
    
    parameter int NUM_ACCEL_INST     = 1;
    parameter int CHANNELS_PER_INST  = 4;
    parameter int NUM_CHANNELS       = NUM_ACCEL_INST * CHANNELS_PER_INST;
    parameter int NUM_RAM_PARTITIONS = CHANNELS_PER_INST;
    
    parameter int VECTOR_LEN    = 2048;
    parameter int NUM_TRANSFERS = 1;
    
    localparam ELEMENTS_PER_WORD      = DATA_WIDTH/ELEMENT_WIDTH;
    localparam WORDS_PER_TRANSFER     = VECTOR_LEN/ELEMENTS_PER_WORD;
    localparam WORDS_PER_PARTITION    = WORDS_PER_TRANSFER/NUM_RAM_PARTITIONS;
    localparam ELEMENTS_PER_PARTITION = WORDS_PER_PARTITION * ELEMENTS_PER_WORD;
    
    localparam MAX_BURST_LEN = 256;
    
    reg clk = 0;
    reg rstn = 1;

    reg start = 0;
    
    // Inputs
    logic [DATA_WIDTH-1:0] s_axis_a_tdata   [NUM_CHANNELS];
    logic                  s_axis_a_tvalid  [NUM_CHANNELS];
    logic                  s_axis_a_tready  [NUM_CHANNELS];
    
    // Outputs
    logic [ELEMENT_WIDTH-1:0] m_axis_tdata     [NUM_CHANNELS];
    logic                     m_axis_tvalid    [NUM_CHANNELS];
    logic                     m_axis_tready    [NUM_CHANNELS];
    logic                     m_axis_tlast     [NUM_CHANNELS];

    // AXI Full write interface for vector b
    reg  [(ID_WIDTH+4)-1:0]   s_axi_b_awid      [NUM_ACCEL_INST];
    reg  [ADDR_WIDTH-1:0]     s_axi_b_awaddr    [NUM_ACCEL_INST];
    reg  [7:0]                s_axi_b_awlen     [NUM_ACCEL_INST];
    reg  [2:0]                s_axi_b_awsize    [NUM_ACCEL_INST];
    reg  [1:0]                s_axi_b_awburst   [NUM_ACCEL_INST];
    reg                       s_axi_b_awlock    [NUM_ACCEL_INST];
    reg  [3:0]                s_axi_b_awcache   [NUM_ACCEL_INST];
    reg  [2:0]                s_axi_b_awprot    [NUM_ACCEL_INST];
    reg                       s_axi_b_awvalid   [NUM_ACCEL_INST];
    wire                      s_axi_b_awready   [NUM_ACCEL_INST];
    reg  [DATA_WIDTH-1:0]     s_axi_b_wdata     [NUM_ACCEL_INST];
    reg  [STRB_WIDTH-1:0]     s_axi_b_wstrb     [NUM_ACCEL_INST];
    reg                       s_axi_b_wlast     [NUM_ACCEL_INST];
    reg                       s_axi_b_wvalid    [NUM_ACCEL_INST];
    wire                      s_axi_b_wready    [NUM_ACCEL_INST];
    wire [(ID_WIDTH+4)-1:0]   s_axi_b_bid       [NUM_ACCEL_INST];
    wire [1:0]                s_axi_b_bresp     [NUM_ACCEL_INST];
    wire                      s_axi_b_bvalid    [NUM_ACCEL_INST];
    reg                       s_axi_b_bready    [NUM_ACCEL_INST];
             
    reg [DATA_WIDTH-1:0] bram [WORDS_PER_TRANSFER-1:0]; // Virtual BRAM
    
    // AXI write task for writing B vector
    task axi_write_burst(input [31:0] addr, input integer len, input integer bram_offset, input integer inst);
        integer k, idx;
        begin
            // Write address
            s_axi_b_awaddr[inst]  = addr;
            s_axi_b_awlen[inst]   = len - 1;
            s_axi_b_awsize[inst]  = $clog2(STRB_WIDTH);
            s_axi_b_awburst[inst] = 1;
            s_axi_b_awvalid[inst] = 1;
            
            $display("\n[AXI WRITE] Instance %0d: Starting burst write", inst);
            $display("[AXI WRITE]   Address    = 0x%08h", addr);
            $display("[AXI WRITE]   Burst Len  = %0d (beats)", len);
            $display("[AXI WRITE]   Beat Size  = %0d bytes", (1 << s_axi_b_awsize[inst]));
            $display("[AXI WRITE]   Total Size = %0d bytes", len * (1 << s_axi_b_awsize[inst]));

            wait (s_axi_b_awready[inst] && s_axi_b_awvalid[inst]);
            @(posedge clk);
            s_axi_b_awvalid[inst] = 0;
            $display("[AXI WRITE] Instance %0d: AW handshake done", inst);
                
            // Write data
            for (k = 0; k < len; k = k + 1) begin
                idx = k + bram_offset;
                $display("[AXI WRITE] Instance %0d: Writing beat %0d: data = %h (bram[%0d])", inst, k, bram[idx], idx);
                s_axi_b_wdata[inst] = bram[idx];
                s_axi_b_wstrb[inst] = {STRB_WIDTH{1'b1}};;
                s_axi_b_wvalid[inst] = 1;
                s_axi_b_wlast[inst] = (k == len-1);
                
                wait (s_axi_b_wready[inst] && s_axi_b_wvalid[inst]);
                @(posedge clk);
                s_axi_b_wvalid[inst] = 0;
            end
            s_axi_b_wvalid[inst] = 0;
            s_axi_b_wlast[inst] = 0;
            $display("[AXI WRITE] Instance %0d: Data phase complete", inst);
                    
            // Write response
            s_axi_b_bready[inst] = 1;
            wait (s_axi_b_bvalid[inst] && s_axi_b_bready[inst]);
            @(posedge clk);
            s_axi_b_bready[inst] = 0;
            $display("[AXI WRITE] Instance %0d: Received B response", inst);
            
            // Reset
            s_axi_b_awvalid[inst] = 0;
            s_axi_b_wvalid[inst]  = 0;
            s_axi_b_bready[inst]  = 0;
            s_axi_b_awid[inst]    = 0;
            s_axi_b_awlock[inst]  = 0;
            s_axi_b_awcache[inst] = 0;
            s_axi_b_awprot[inst]  = 0;
            s_axi_b_wlast[inst]   = 0;
            s_axi_b_wstrb[inst]   = {STRB_WIDTH{1'b1}};
            $display("[AXI WRITE] Instance %0d: Burst write complete\n", inst);
        end
    endtask

    // Instantiate DUTs
    generate
        for (genvar inst = 0; inst < NUM_ACCEL_INST; inst = inst + 1) begin : gen_accel
            localparam int base_idx = inst * CHANNELS_PER_INST;
        
            mvm_accelerator #(
                .ARCH_TYPE(ARCH_TYPE),
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH),
                .STRB_WIDTH(STRB_WIDTH),
                .ID_WIDTH(ID_WIDTH),
                .AXI_RAM_BASE_ADDR(32'h1000_0000*inst),
                .WORDS_PER_TRANSFER(WORDS_PER_TRANSFER),
                .NUM_CHANNELS(CHANNELS_PER_INST),
                .NUM_RAM_PARTITIONS(NUM_RAM_PARTITIONS)
            ) dut (
                .clk(clk),
                .rstn(rstn),                
                `GET_CHANNELS
                `include "axi_full_write_bindings.svh"
            );
        end
    endgenerate
        
    // Clock
    always #5 clk = ~clk;
    
    real a_values [NUM_CHANNELS][VECTOR_LEN];
    real b_values [VECTOR_LEN];
    
    reg done [NUM_CHANNELS-1:0][NUM_TRANSFERS-1:0];
    
    integer num_full_bursts, final_burst_len, base_offset, burst_offset;
    
    // Initialization
    initial begin
    
        rstn = 0;
        #45 rstn = 1;
        
        repeat (3) @(posedge clk);
    
        for (int i = 0; i < NUM_CHANNELS; i = i + 1) begin
            m_axis_tready[i] = 1;
        
            for (int j = 0; j < VECTOR_LEN; j = j + 1) begin
                a_values[i][j] = (j+1) / ((i+1) * 1000.0);
                b_values[j] = (j+1) / 10000.0;
            end
                        
            for (int j = 0; j < NUM_TRANSFERS; j = j + 1) begin
                done[i][j] = 0;
            end
        end
        
        for (int w = 0; w < WORDS_PER_TRANSFER; w++) begin
            bram[w] = '0;
            for (int j = 0; j < ELEMENTS_PER_WORD; j++) begin
                bram[w][j*ELEMENT_WIDTH +: ELEMENT_WIDTH] = $realtobits(b_values[w * ELEMENTS_PER_WORD + j]);
                $display("bram[%0d][%0d] = %h (real = %f)", 
                         w, j, bram[w][j*ELEMENT_WIDTH +: ELEMENT_WIDTH], b_values[w * ELEMENTS_PER_WORD + j]);
            end
        end
        
        for (int i = 0; i < NUM_ACCEL_INST; i = i + 1) begin
            for (int j = 0; j < NUM_RAM_PARTITIONS; j = j + 1) begin
                repeat (10) @(posedge clk);
                
                num_full_bursts = WORDS_PER_PARTITION / MAX_BURST_LEN;
                final_burst_len = WORDS_PER_PARTITION % MAX_BURST_LEN;
                
                base_offset = j * WORDS_PER_PARTITION;
                
                for (int k = 0; k < num_full_bursts; k = k + 1) begin
                    burst_offset = base_offset + k * MAX_BURST_LEN;
                    axi_write_burst(
                        32'h1000_0000 * i + burst_offset * STRB_WIDTH,
                        MAX_BURST_LEN,
                        burst_offset,
                        i
                    );
                end
                
                if (final_burst_len > 0) begin
                    burst_offset = base_offset + num_full_bursts * MAX_BURST_LEN;
                    axi_write_burst(
                        32'h1000_0000*i + burst_offset * STRB_WIDTH,
                        final_burst_len,
                        burst_offset,
                        i
                    );
                end
            end
        end
        
        $display("Initialization complete\n");
        start = 1;
    end
        
    real expected [NUM_CHANNELS-1:0][NUM_TRANSFERS-1:0];    
    int partition_offset, local_word_offset, rotated_partition;
    
    // Channel drivers
    genvar ch;
    generate
        for (ch = 0; ch < NUM_CHANNELS; ch++) begin : channel_driver
            initial begin
                wait(start);
                
                for (int j = 0; j < NUM_TRANSFERS; j++) begin  
                    expected[ch][j] = 0;
                       
                    // Send inputs
                    for (int word_idx = 0; word_idx < WORDS_PER_TRANSFER; word_idx++) begin
                        s_axis_a_tdata[ch] = '0;
                        
                        partition_offset = word_idx / WORDS_PER_PARTITION;
                        local_word_offset = word_idx % WORDS_PER_PARTITION;
                        rotated_partition = (ch + partition_offset) % NUM_RAM_PARTITIONS;
                        
                        for (int k = 0; k < ELEMENTS_PER_WORD; k++) begin
                            automatic int rotated_idx = rotated_partition * WORDS_PER_PARTITION * ELEMENTS_PER_WORD
                                                      + local_word_offset * ELEMENTS_PER_WORD + k;

                            s_axis_a_tdata[ch][k*ELEMENT_WIDTH +: ELEMENT_WIDTH] = $realtobits(a_values[ch][rotated_idx]);
                            expected[ch][j] += a_values[ch][rotated_idx] * b_values[rotated_idx];
                        end
                        
                        s_axis_a_tvalid[ch] = 1;
                        wait (s_axis_a_tready[ch]);
                        @(posedge clk);
                        s_axis_a_tvalid[ch] = 0;
                    end
    
                    // Wait for output
                    wait (m_axis_tvalid[ch] && m_axis_tready[ch] && m_axis_tlast[ch]);
                    @(posedge clk);
    
                    done[ch][j] = 1;
    
                    $display("%0d: Channel %0d: Result = %f | Expected = %f",
                             j, ch, $bitstoreal(m_axis_tdata[ch]), expected[ch][j]);
                end
            end
        end
    endgenerate
    
    integer all_done = 0;

    // Wait for all transfers to complete
    initial begin
        wait(start);
    
        forever begin
            all_done = 1;
            for (int ch = 0; ch < NUM_CHANNELS; ch++) begin
                for (int j = 0; j < NUM_TRANSFERS; j++) begin
                    if (!done[ch][j])
                        all_done = 0;
                end
            end
            if (all_done) begin
                $display("All transfers complete.");
                break;
            end
            @(posedge clk);
        end
    
        repeat (10) @(posedge clk);
        
        $finish;
    end

endmodule