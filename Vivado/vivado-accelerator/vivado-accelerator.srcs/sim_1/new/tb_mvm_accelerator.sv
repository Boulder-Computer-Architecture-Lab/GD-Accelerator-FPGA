`timescale 1ns / 1ps

module tb_mvm_accelerator;

    parameter DATA_WIDTH = 64;
    parameter ADDR_WIDTH = 32;
    parameter ID_WIDTH = 4;
    
    parameter int NUM_ACCEL_INST     = 2;
    parameter int CHANNELS_PER_INST  = 2;
    parameter int NUM_CHANNELS       = NUM_ACCEL_INST * CHANNELS_PER_INST;
    
    parameter int VECTOR_LEN = 64;
    parameter int NUM_TRANSFERS = 4;

    reg clk = 0;
    reg rstn = 1;
    
    // Inputs
    logic [DATA_WIDTH-1:0] s_axis_a_tdata   [NUM_CHANNELS];
    logic                  s_axis_a_tvalid  [NUM_CHANNELS];
    logic                  s_axis_a_tready  [NUM_CHANNELS];
    
    // Outputs
    logic [DATA_WIDTH-1:0] m_axis_tdata     [NUM_CHANNELS];
    logic                  m_axis_tvalid    [NUM_CHANNELS];
    logic                  m_axis_tready    [NUM_CHANNELS];
    logic                  m_axis_tlast     [NUM_CHANNELS];

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
    reg  [(DATA_WIDTH/8)-1:0] s_axi_b_wstrb     [NUM_ACCEL_INST];
    reg                       s_axi_b_wlast     [NUM_ACCEL_INST];
    reg                       s_axi_b_wvalid    [NUM_ACCEL_INST];
    wire                      s_axi_b_wready    [NUM_ACCEL_INST];
    wire [(ID_WIDTH+4)-1:0]   s_axi_b_bid       [NUM_ACCEL_INST];
    wire [1:0]                s_axi_b_bresp     [NUM_ACCEL_INST];
    wire                      s_axi_b_bvalid    [NUM_ACCEL_INST];
    reg                       s_axi_b_bready    [NUM_ACCEL_INST];
         
    reg [DATA_WIDTH-1:0] bram [VECTOR_LEN-1:0]; // Virtual BRAM
    
    // AXI write task for writing B vector
    task axi_write_burst;
        input [31:0] addr;
        input integer i;
        integer k;
        begin
            // Write address
            s_axi_b_awaddr[i]  = addr;
            s_axi_b_awlen[i]   = VECTOR_LEN - 1;
            s_axi_b_awsize[i]  = 3;
            s_axi_b_awburst[i] = 1;
            s_axi_b_awvalid[i] = 1;

            wait (s_axi_b_awready[i] && s_axi_b_awvalid[i]);
            @(posedge clk);
            s_axi_b_awvalid[i] = 0;
                
            // Write data
            for (k = 0; k < VECTOR_LEN; k = k + 1) begin
                s_axi_b_wdata[i] = bram[k];
                s_axi_b_wstrb[i] = 8'hFF;
                s_axi_b_wvalid[i] = 1;
                s_axi_b_wlast[i] = (k == VECTOR_LEN-1);
                
                wait (s_axi_b_wready[i] && s_axi_b_wvalid[i]);
                @(posedge clk);
                s_axi_b_wvalid[i] = 0;
            end
            s_axi_b_wvalid[i] = 0;
            s_axi_b_wlast[i] = 0;
                    
            // Write response
            s_axi_b_bready[i] = 1;
            wait (s_axi_b_bvalid[i] && s_axi_b_bready[i]);
            @(posedge clk);
            s_axi_b_bready[i] = 0;
            
            // Reset
            s_axi_b_awvalid[i] = 0;
            s_axi_b_wvalid[i]  = 0;
            s_axi_b_bready[i]  = 0;
            s_axi_b_awid[i]    = 0;
            s_axi_b_awlock[i]  = 0;
            s_axi_b_awcache[i] = 0;
            s_axi_b_awprot[i]  = 0;
            s_axi_b_wlast[i]   = 0;
            s_axi_b_wstrb[i]   = 8'hFF;
        end
    endtask

    // Instantiate DUTs
    generate
        for (genvar inst = 0; inst < NUM_ACCEL_INST; inst++) begin : gen_accel
            case (CHANNELS_PER_INST)
                1: begin
                    mvm_accelerator #(
                        .WORDS_PER_TRANSFER(VECTOR_LEN),
                        .AXI_RAM_BASE_ADDR(32'h1000_0000 << inst)
                    ) dut (
                        .clk(clk),
                        .rstn(rstn),
                        `include "channels_0.svh"
                        `include "axi_full_write_bindings.svh"
                    );
                end
                2: begin
                    mvm_accelerator #(
                        .WORDS_PER_TRANSFER(VECTOR_LEN),
                        .AXI_RAM_BASE_ADDR(32'h1000_0000 << inst)
                    ) dut (
                        .clk(clk),
                        .rstn(rstn),
                        `include "channels_0.svh"
                        `include "channels_1.svh"
                        `include "axi_full_write_bindings.svh"
                    );
                end
                3: begin
                    mvm_accelerator #(
                        .WORDS_PER_TRANSFER(VECTOR_LEN),
                        .AXI_RAM_BASE_ADDR(32'h1000_0000 << inst)
                    ) dut (
                        .clk(clk),
                        .rstn(rstn),
                        `include "channels_0.svh"
                        `include "channels_1.svh"
                        `include "channels_2.svh"
                        `include "axi_full_write_bindings.svh"
                    );
                end
                4: begin
                    mvm_accelerator #(
                        .WORDS_PER_TRANSFER(VECTOR_LEN),
                        .AXI_RAM_BASE_ADDR(32'h1000_0000 << inst)
                    ) dut (
                        .clk(clk),
                        .rstn(rstn),
                        `include "channels_0.svh"
                        `include "channels_1.svh"
                        `include "channels_2.svh"
                        `include "channels_3.svh"
                        `include "axi_full_write_bindings.svh"
                    );
                end
                5: begin
                    mvm_accelerator #(
                        .WORDS_PER_TRANSFER(VECTOR_LEN),
                        .AXI_RAM_BASE_ADDR(32'h1000_0000 << inst)
                    ) dut (
                        .clk(clk),
                        .rstn(rstn),
                        `include "channels_0.svh"
                        `include "channels_1.svh"
                        `include "channels_2.svh"
                        `include "channels_3.svh"
                        `include "channels_4.svh"
                        `include "axi_full_write_bindings.svh"
                    );
                end
                6: begin
                    mvm_accelerator #(
                        .WORDS_PER_TRANSFER(VECTOR_LEN),
                        .AXI_RAM_BASE_ADDR(32'h1000_0000 << inst)
                    ) dut (
                        .clk(clk),
                        .rstn(rstn),
                        `include "channels_0.svh"
                        `include "channels_1.svh"
                        `include "channels_2.svh"
                        `include "channels_3.svh"
                        `include "channels_4.svh"
                        `include "channels_5.svh"
                        `include "axi_full_write_bindings.svh"
                    );
                end
                7: begin
                    mvm_accelerator #(
                        .WORDS_PER_TRANSFER(VECTOR_LEN),
                        .AXI_RAM_BASE_ADDR(32'h1000_0000 << inst)
                    ) dut (
                        .clk(clk),
                        .rstn(rstn),
                        `include "channels_0.svh"
                        `include "channels_1.svh"
                        `include "channels_2.svh"
                        `include "channels_3.svh"
                        `include "channels_4.svh"
                        `include "channels_5.svh"
                        `include "channels_6.svh"
                        `include "axi_full_write_bindings.svh"
                    );
                end
                8: begin
                    mvm_accelerator #(
                        .WORDS_PER_TRANSFER(VECTOR_LEN),
                        .AXI_RAM_BASE_ADDR(32'h1000_0000 << inst)
                    ) dut (
                        .clk(clk),
                        .rstn(rstn),
                        `include "channels_0.svh"
                        `include "channels_1.svh"
                        `include "channels_2.svh"
                        `include "channels_3.svh"
                        `include "channels_4.svh"
                        `include "channels_5.svh"
                        `include "channels_6.svh"
                        `include "channels_7.svh"
                        `include "axi_full_write_bindings.svh"
                    );
                end                default: begin
                    initial $fatal("Unsupported CHANNELS_PER_INST = %0d", CHANNELS_PER_INST);
                end
            endcase
        end
    endgenerate

    // Clock
    always #5 clk = ~clk;
    
    real a_values [NUM_CHANNELS][VECTOR_LEN];
    real b_values [VECTOR_LEN];
    
    integer i, j;

    initial begin
        for (i = 0; i < NUM_CHANNELS; i = i + 1) begin
            for (j = 0; j < VECTOR_LEN; j = j + 1) begin
                a_values[i][j] = (j+1) / ((i+1) * 100.0);
                b_values[j] = (j+1) / 1000.0;
            end
        end

        rstn = 0;
        #45 rstn = 1;
        repeat (3) @(posedge clk);
        
        for (i = 0; i< NUM_CHANNELS; i = i + 1) begin
            m_axis_tready[i] <= 1;
        end
        
        for (i = 0; i < VECTOR_LEN; i = i + 1) begin
            bram[i] = $realtobits(b_values[i]);
            $display("bram[%0d] = %h  (real = %f)", i, bram[i], b_values[i]);
        end
        
        for (i = 0; i < NUM_ACCEL_INST; i = i + 1) begin
            repeat (10) @(posedge clk);
            axi_write_burst(32'h1000_0000 << i, i);
            $display("Axi write %0d complete.", i);
        end
        
        repeat (10) @(posedge clk);

        for (int j = 0; j < NUM_TRANSFERS; j++) begin
            fork
                for (int ch = 0; ch < NUM_CHANNELS; ch++) begin
                    automatic int channel = ch;
                    automatic int transfer_id = j;
                    automatic real expected = 0;
        
                    fork
                        begin
                            // Send vector data
                            for (int i = 0; i < VECTOR_LEN; i++) begin
                                s_axis_a_tdata[channel]  = $realtobits(a_values[channel][i] + transfer_id);
                                s_axis_a_tvalid[channel] = 1;
        
                                wait (s_axis_a_tready[channel] && s_axis_a_tvalid[channel]);
                                @(posedge clk);
                                s_axis_a_tvalid[channel] = 0;
        
                                expected += (a_values[channel][i] + transfer_id) * b_values[i];
                            end
        
                            // Wait for output
                            wait (m_axis_tvalid[channel] && m_axis_tready[channel] && m_axis_tlast[channel]);
                            @(posedge clk);
        
                            $display("%0d: Channel %0d: Result = %f | Expected = %f",
                                     transfer_id, channel, $bitstoreal(m_axis_tdata[channel]), expected);
                        end
                    join
                end
            join
        end

        #100;

        $finish;
    end

endmodule