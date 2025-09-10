`timescale 1ns / 1ps

module tb_mvm_accelerator;

    `include "axi_a_channel_bindings.svh"
    `define GET_CHANNELS `CHANNELS_2 // <------------ `CHANNELS_{CHANNELS_PER_INST} (must match the parameter)
                                     // Note: Also run ./Vivado/scripts/update_channels.py when this 
                                     // is changed to update all the relevant header files

    parameter ARCH_TYPE = 0; // Select accelerator type (0=split)

    parameter int DATA_WIDTH = 64;
    parameter int ADDR_WIDTH = 64;
    parameter int ID_WIDTH   = 8;
    parameter int STRB_WIDTH = DATA_WIDTH/8;
    
    parameter int ELEMENT_WIDTH = 64;
    
    parameter int NUM_ACCEL_INST     = 1;
    parameter int CHANNELS_PER_INST  = 2;
    parameter int NUM_CHANNELS       = NUM_ACCEL_INST * CHANNELS_PER_INST;
    parameter int NUM_RAM_PARTITIONS = CHANNELS_PER_INST;
    
    parameter int ELEMENTS_PER_ROW = 16384;
    parameter int NUM_ROWS         = 4;
    parameter int ROWS_PER_CHANNEL = NUM_ROWS / NUM_CHANNELS;
    
    localparam ELEMENTS_PER_WORD      = DATA_WIDTH / ELEMENT_WIDTH;
    localparam WORDS_PER_ROW          = ELEMENTS_PER_ROW / ELEMENTS_PER_WORD;
    localparam WORDS_PER_PARTITION    = WORDS_PER_ROW / NUM_RAM_PARTITIONS;
    
    localparam MAX_BURST_LEN = 256;
    localparam AXI_RAM_ID_WIDTH = ID_WIDTH + $clog2(NUM_CHANNELS);
    
    reg s_clk = 0, m_clk = 0;
    reg s_rstn = 1, m_rstn = 1;
    
    reg start = 0;
    
    // Inputs
    logic [DATA_WIDTH-1:0] s_axis_a_tdata   [NUM_CHANNELS] = '{default:'0};
    logic                  s_axis_a_tvalid  [NUM_CHANNELS] = '{default:1'b0};
    logic                  s_axis_a_tready  [NUM_CHANNELS] = '{default:1'b0};
    logic                  s_axis_a_tlast   [NUM_CHANNELS] = '{default:1'b0};
    
    // Outputs
    logic [ELEMENT_WIDTH-1:0] m_axis_tdata     [NUM_CHANNELS] = '{default:'0};
    logic                     m_axis_tvalid    [NUM_CHANNELS] = '{default:1'b0};
    logic                     m_axis_tready    [NUM_CHANNELS] = '{default:1'b0};
    logic                     m_axis_tlast     [NUM_CHANNELS] = '{default:1'b0};

    // AXI Full write interface for vector b
    reg  [AXI_RAM_ID_WIDTH-1:0] s_axi_b_awid      [NUM_ACCEL_INST];
    reg  [ADDR_WIDTH-1:0]       s_axi_b_awaddr    [NUM_ACCEL_INST];
    reg  [7:0]                  s_axi_b_awlen     [NUM_ACCEL_INST];
    reg  [2:0]                  s_axi_b_awsize    [NUM_ACCEL_INST];
    reg  [1:0]                  s_axi_b_awburst   [NUM_ACCEL_INST];
    reg                         s_axi_b_awlock    [NUM_ACCEL_INST];
    reg  [3:0]                  s_axi_b_awcache   [NUM_ACCEL_INST];
    reg  [2:0]                  s_axi_b_awprot    [NUM_ACCEL_INST];
    reg                         s_axi_b_awvalid   [NUM_ACCEL_INST];
    wire                        s_axi_b_awready   [NUM_ACCEL_INST];
    reg  [DATA_WIDTH-1:0]       s_axi_b_wdata     [NUM_ACCEL_INST];
    reg  [STRB_WIDTH-1:0]       s_axi_b_wstrb     [NUM_ACCEL_INST];
    reg                         s_axi_b_wlast     [NUM_ACCEL_INST];
    reg                         s_axi_b_wvalid    [NUM_ACCEL_INST];
    wire                        s_axi_b_wready    [NUM_ACCEL_INST];
    wire [AXI_RAM_ID_WIDTH-1:0] s_axi_b_bid       [NUM_ACCEL_INST];
    wire [1:0]                  s_axi_b_bresp     [NUM_ACCEL_INST];
    wire                        s_axi_b_bvalid    [NUM_ACCEL_INST];
    reg                         s_axi_b_bready    [NUM_ACCEL_INST];
             
    reg [DATA_WIDTH-1:0] bram [WORDS_PER_ROW-1:0];
    
    // AXI full write task
    task axi_write_burst(
        input logic [ADDR_WIDTH-1:0] addr, 
        input int len, 
        input int bram_offset, 
        input int glob_inst
    );
        integer k, idx;
        begin
            automatic int inst = glob_inst;

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
            @(posedge s_clk);
            s_axi_b_awvalid[inst] = 0;
            $display("[AXI WRITE] Instance %0d: AW handshake done", inst);
                
            // Write data
            for (k = 0; k < len; k++) begin
                idx = k + bram_offset;
                $display("[AXI WRITE] Instance %0d: Writing beat %0d: data = %h (bram[%0d])", inst, k, bram[idx], idx);
                s_axi_b_wdata[inst] = bram[idx];
                s_axi_b_wstrb[inst] = {STRB_WIDTH{1'b1}};
                s_axi_b_wvalid[inst] = 1;
                s_axi_b_wlast[inst] = (k == len-1);
                
                wait (s_axi_b_wready[inst] && s_axi_b_wvalid[inst]);
                @(posedge s_clk);
                s_axi_b_wvalid[inst] = 0;
            end
            s_axi_b_wvalid[inst] = 0;
            s_axi_b_wlast[inst] = 0;
            $display("[AXI WRITE] Instance %0d: Data phase complete", inst);
                    
            // Write response
            s_axi_b_bready[inst] = 1;
            wait (s_axi_b_bvalid[inst] && s_axi_b_bready[inst]);
            @(posedge s_clk);
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
    
    localparam [ADDR_WIDTH-1:0] BASE_ADDR = { {(ADDR_WIDTH-32){1'b0}}, 32'h8000_0000 };
    localparam [ADDR_WIDTH-1:0] STRIDE    = { {(ADDR_WIDTH-32){1'b0}}, 32'h1000_0000 };

    // Instantiate DUT
    generate
        for (genvar inst = 0; inst < NUM_ACCEL_INST; inst++) begin : gen_accel
            localparam int base_idx = inst * CHANNELS_PER_INST;
        
            mvm_accelerator #(
                .ARCH_TYPE(ARCH_TYPE),
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH),
                .ID_WIDTH(ID_WIDTH),
                .ELEMENT_WIDTH(ELEMENT_WIDTH),
                .ELEMENTS_PER_ROW(ELEMENTS_PER_ROW),
                .NUM_ROWS(NUM_ROWS),
                .NUM_CHANNELS(CHANNELS_PER_INST),
                .AXI_RAM_BASE_ADDR(BASE_ADDR + STRIDE * inst),
                .AXI_RAM_ID_WIDTH(AXI_RAM_ID_WIDTH)
            ) dut (
                .s_axis_a_0_clk(s_clk), .m_axis_0_clk(m_clk),
                .s_axis_a_1_clk(s_clk), .m_axis_1_clk(m_clk),
                .s_axis_a_2_clk(s_clk), .m_axis_2_clk(m_clk),
                .s_axis_a_3_clk(s_clk), .m_axis_3_clk(m_clk),
                                
                .s_axis_a_0_rstn(s_rstn), .m_axis_0_rstn(m_rstn),
                .s_axis_a_1_rstn(s_rstn), .m_axis_1_rstn(m_rstn),
                .s_axis_a_2_rstn(s_rstn), .m_axis_2_rstn(m_rstn),
                .s_axis_a_3_rstn(s_rstn), .m_axis_3_rstn(m_rstn),
                
                .s_axi_b_clk(s_clk), .s_axi_b_rstn(s_rstn),
                                
                `GET_CHANNELS
                `include "axi_full_write_bindings.svh"
            );
        end
    endgenerate
        
    // Clock generation
    always #1.667 s_clk = ~s_clk; // (pclk0: 300 MHz)
    always #1.667 m_clk = ~m_clk; // (pclk0: 300 MHz)
    
    real a_values [NUM_CHANNELS][ELEMENTS_PER_ROW];
    real b_values [ELEMENTS_PER_ROW];
    
    reg inputs_sent      [NUM_CHANNELS-1:0];
    reg outputs_received [NUM_CHANNELS-1:0];

    real expected [NUM_CHANNELS-1:0][ROWS_PER_CHANNEL-1:0];    
    
    logic [ADDR_WIDTH-1:0] base_addr; 
    logic [ADDR_WIDTH-1:0] base_offset;
    integer num_full_bursts = WORDS_PER_PARTITION / MAX_BURST_LEN;
    integer final_burst_len = WORDS_PER_PARTITION % MAX_BURST_LEN;

    // Initialization
    initial begin
    
        // Reset
        s_rstn = 0; m_rstn = 0;
        repeat (16) @(posedge m_clk); 
        s_rstn = 1; m_rstn = 1;
        
        repeat (4) @(posedge s_clk);
    
        for (int i = 0; i < NUM_CHANNELS; i++) begin
            inputs_sent[i] = 0;
            outputs_received[i] = 0;
            
            m_axis_tready[i] = 1;
        
            for (int j = 0; j < ELEMENTS_PER_ROW; j++) begin
                a_values[i][j] = (j+1) / ((i+1) * 1000.0);
                b_values[j] = (j+1) / 10000.0;
                //$display("Channel %0d : a_values[%0d] = %h (real=%f)", i, j, $realtobits(a_values[i][j]), a_values[i][j]);
            end
        end
        
        for (int w = 0; w < WORDS_PER_ROW; w++) begin
            bram[w] = '0;
            for (int j = 0; j < ELEMENTS_PER_WORD; j++) begin
                bram[w][j*ELEMENT_WIDTH +: ELEMENT_WIDTH] = $realtobits(b_values[w * ELEMENTS_PER_WORD + j]);
                //$display("bram[%0d][%0d] = %h (real = %f)", 
                //         w, j, bram[w][j*ELEMENT_WIDTH +: ELEMENT_WIDTH], b_values[w * ELEMENTS_PER_WORD + j]);
            end
        end
        
        // Write vector to dut.axi_ram
        for (int i = 0; i < NUM_ACCEL_INST; i++) begin
            base_addr = BASE_ADDR + STRIDE * i;
                      
            for (int j = 0; j < NUM_RAM_PARTITIONS; j++) begin
                repeat (10) @(posedge s_clk);
                                
                base_offset = j * WORDS_PER_PARTITION;
                
                for (int k = 0; k < num_full_bursts; k++) begin
                    automatic int burst_offset = base_offset + k * MAX_BURST_LEN;
                    axi_write_burst(
                        base_addr + burst_offset * STRB_WIDTH,
                        MAX_BURST_LEN,
                        burst_offset,
                        i
                    );
                end
                
                if (final_burst_len > 0) begin
                    automatic int burst_offset = base_offset + num_full_bursts * MAX_BURST_LEN;
                    axi_write_burst(
                        base_addr + burst_offset * STRB_WIDTH,
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
            
    // Parallel channel drivers
    generate
        for (genvar ch = 0; ch < NUM_CHANNELS; ch++) begin : channel_driver
            initial begin
                wait(start);
                
                for (int j = 0; j < ROWS_PER_CHANNEL; j++) begin  
                    expected[ch][j] = 0;
                    
                    // Send inputs
                    for (int word_idx = 0; word_idx < WORDS_PER_ROW; word_idx++) begin
                        s_axis_a_tdata[ch] = '0;
                        
                        for (int k = 0; k < ELEMENTS_PER_WORD; k++) begin
                            automatic int abs_idx = word_idx * ELEMENTS_PER_WORD + k;
                            s_axis_a_tdata[ch][k*ELEMENT_WIDTH +: ELEMENT_WIDTH] = $realtobits(a_values[ch][abs_idx]);
                            expected[ch][j] += a_values[ch][abs_idx] * b_values[abs_idx];
                        end
                        
                        s_axis_a_tvalid[ch] = 1;
                        s_axis_a_tlast[ch]  = (word_idx == WORDS_PER_ROW-1);

                        do begin
                            @(posedge s_clk);
                        end while (!(s_axis_a_tvalid[ch] && s_axis_a_tready[ch]));
                        
                        s_axis_a_tvalid[ch] = 0;
                        s_axis_a_tlast[ch]  = 0;
                    end
                    $display("%0d: Channel %0d: All inputs sent.", j, ch);
                end
                
                inputs_sent[ch] = 1;
            end
        end
    endgenerate
        
    // Capture outputs
    generate
      for (genvar ch = 0; ch < NUM_CHANNELS; ch++) begin : capture_output
        initial begin
          for (int j = 0; j < ROWS_PER_CHANNEL; j++) begin
            @(posedge m_clk iff (m_axis_tvalid[ch] && m_axis_tready[ch]));
            $display("%0d: Ch%0d: Result=%f | Expected=%f",
                     j, ch, $bitstoreal(m_axis_tdata[ch]), expected[ch][j]);
          end
          outputs_received[ch] = 1;
        end
      end
    endgenerate
    
    // Finish once all outputs are received
    initial begin
        wait(start);
    
        forever begin
            automatic int finished = 1;
            for (int ch = 0; ch < NUM_CHANNELS; ch++) begin
                if (!inputs_sent[ch] || !outputs_received[ch])
                    finished = 0;
            end
            if (finished) begin
                $display("All outputs received.");
                break;
            end
            @(posedge s_clk);
        end
    
        repeat (10) @(posedge s_clk);
        
        $finish;
    end

endmodule
