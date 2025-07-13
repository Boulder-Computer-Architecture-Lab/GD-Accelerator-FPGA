`timescale 1ns / 1ps

module tb_mvm_accelerator;

    parameter DATA_WIDTH = 64;
    parameter ADDR_WIDTH = 32;
    parameter VECTOR_LEN = 64;
    parameter NUM_TRANSFERS = 8;

    reg clk = 0;
    reg rstn = 1;

    // Inputs
    reg  [DATA_WIDTH-1:0] s_axis_a_0_tdata;
    reg                   s_axis_a_0_tvalid;
    wire                  s_axis_a_0_tready;
    
    reg  [DATA_WIDTH-1:0] s_axis_a_1_tdata;
    reg                   s_axis_a_1_tvalid;
    wire                  s_axis_a_1_tready;

    // Outputs
    wire [DATA_WIDTH-1:0] m_axis_0_tdata;
    wire                  m_axis_0_tvalid;
    reg                   m_axis_0_tready;
    wire                  m_axis_0_tlast;
    
    wire [DATA_WIDTH-1:0] m_axis_1_tdata;
    wire                  m_axis_1_tvalid;
    reg                   m_axis_1_tready;
    wire                  m_axis_1_tlast;

    // AXI Full interface for writing vector b
    reg  [7:0]  s_axi_b_awid;
    reg  [ADDR_WIDTH-1:0] s_axi_b_awaddr;
    reg  [7:0]  s_axi_b_awlen;
    reg  [2:0]  s_axi_b_awsize;
    reg  [1:0]  s_axi_b_awburst;
    reg         s_axi_b_awlock;
    reg  [3:0]  s_axi_b_awcache;
    reg  [2:0]  s_axi_b_awprot;
    reg         s_axi_b_awvalid;
    wire        s_axi_b_awready;

    reg  [DATA_WIDTH-1:0] s_axi_b_wdata;
    reg  [7:0]  s_axi_b_wstrb;
    reg         s_axi_b_wlast;
    reg         s_axi_b_wvalid;
    wire        s_axi_b_wready;

    wire [7:0]  s_axi_b_bid;
    wire [1:0]  s_axi_b_bresp;
    wire        s_axi_b_bvalid;
    reg         s_axi_b_bready;

    wire [3:0]  s_axi_b_rid;
    wire [DATA_WIDTH-1:0] s_axi_b_rdata;
    wire [1:0]  s_axi_b_rresp;
    wire        s_axi_b_rlast;
    wire        s_axi_b_rvalid;
    wire        s_axi_b_arready;
    
    wire [3:0]  s_axi_b_arid;
    wire [ADDR_WIDTH-1:0] s_axi_b_araddr;
    wire [7:0] s_axi_b_arlen;
    wire [2:0] s_axi_b_arsize;
    wire [1:0] s_axi_b_arburst;
    wire       s_axi_b_arlock;
    wire [3:0] s_axi_b_arcache;
    wire [2:0] s_axi_b_arprot;
    wire       s_axi_b_arvalid;
    wire       s_axi_b_rready;
        
    reg [DATA_WIDTH-1:0] bram [VECTOR_LEN-1:0];
    
    task axi_write_burst;
        input [31:0] addr;
        integer k;
        begin
            // Write address
            s_axi_b_awaddr  = addr;
            s_axi_b_awlen   = VECTOR_LEN - 1;
            s_axi_b_awsize  = 3; // 8 bytes = 64 bits
            s_axi_b_awburst = 1; // INCR
            s_axi_b_awvalid = 1;

            @(posedge clk);
            $display("T=%0t: Waiting for AWREADY...", $time);
            while (!s_axi_b_awready) @(posedge clk);
            $display("T=%0t: AWREADY asserted", $time);
            s_axi_b_awvalid = 0;
        
            // Write data
            for (k = 0; k < VECTOR_LEN; k = k + 1) begin
                @(posedge clk);
                s_axi_b_wdata = bram[k];
                s_axi_b_wstrb = 8'hFF;
                s_axi_b_wvalid = 1;
                s_axi_b_wlast = (k == VECTOR_LEN-1);
                @(posedge clk);
                $display("T=%0t: Waiting for WREADY...", $time);
                while (!s_axi_b_wready) @(posedge clk);
                $display("T=%0t: WREADY asserted", $time);
                s_axi_b_wvalid = 0;
            end
            s_axi_b_wvalid = 0;
            s_axi_b_wlast = 0;
        
            // Write response
            s_axi_b_bready = 1;
            @(posedge clk);
            $display("T=%0t: Waiting for BVALID...", $time);
            while (!s_axi_b_bvalid) @(posedge clk);
            $display("T=%0t: BVALID asserted", $time);
            s_axi_b_bready = 0;

        end
    endtask

    // Instantiate DUT
    mvm_accelerator #(
        .WORDS_PER_TRANSFER(VECTOR_LEN)
    ) uut (
        .clk(clk),
        .rstn(rstn),

        .s_axis_a_0_tdata(s_axis_a_0_tdata),
        .s_axis_a_0_tvalid(s_axis_a_0_tvalid),
        .s_axis_a_0_tready(s_axis_a_0_tready),

        .s_axis_a_1_tdata(s_axis_a_1_tdata),
        .s_axis_a_1_tvalid(s_axis_a_1_tvalid),
        .s_axis_a_1_tready(s_axis_a_1_tready),

        .s_axi_b_awid(s_axi_b_awid),
        .s_axi_b_awaddr(s_axi_b_awaddr),
        .s_axi_b_awlen(s_axi_b_awlen),
        .s_axi_b_awsize(s_axi_b_awsize),
        .s_axi_b_awburst(s_axi_b_awburst),
        .s_axi_b_awlock(s_axi_b_awlock),
        .s_axi_b_awcache(s_axi_b_awcache),
        .s_axi_b_awprot(s_axi_b_awprot),
        .s_axi_b_awvalid(s_axi_b_awvalid),
        .s_axi_b_awready(s_axi_b_awready),
        .s_axi_b_wdata(s_axi_b_wdata),
        .s_axi_b_wstrb(s_axi_b_wstrb),
        .s_axi_b_wlast(s_axi_b_wlast),
        .s_axi_b_wvalid(s_axi_b_wvalid),
        .s_axi_b_wready(s_axi_b_wready),
        .s_axi_b_bid(s_axi_b_bid),
        .s_axi_b_bresp(s_axi_b_bresp),
        .s_axi_b_bvalid(s_axi_b_bvalid),
        .s_axi_b_bready(s_axi_b_bready),
        .s_axi_b_arid(s_axi_b_arid),
        .s_axi_b_araddr(s_axi_b_araddr),
        .s_axi_b_arlen(s_axi_b_arlen),
        .s_axi_b_arsize(s_axi_b_arsize),
        .s_axi_b_arburst(s_axi_b_arburst),
        .s_axi_b_arlock(s_axi_b_arlock),
        .s_axi_b_arcache(s_axi_b_arcache),
        .s_axi_b_arprot(s_axi_b_arprot),
        .s_axi_b_arvalid(s_axi_b_arvalid),
        .s_axi_b_arready(s_axi_b_arready),
        .s_axi_b_rid(s_axi_b_rid),
        .s_axi_b_rdata(s_axi_b_rdata),
        .s_axi_b_rresp(s_axi_b_rresp),
        .s_axi_b_rlast(s_axi_b_rlast),
        .s_axi_b_rvalid(s_axi_b_rvalid),
        .s_axi_b_rready(s_axi_b_rready),

        .m_axis_0_tdata(m_axis_0_tdata),
        .m_axis_0_tvalid(m_axis_0_tvalid),
        .m_axis_0_tready(m_axis_0_tready),
        .m_axis_0_tlast(m_axis_0_tlast),

        .m_axis_1_tdata(m_axis_1_tdata),
        .m_axis_1_tvalid(m_axis_1_tvalid),
        .m_axis_1_tready(m_axis_1_tready),
        .m_axis_1_tlast(m_axis_1_tlast)
    );

    // Clock and backpressure
    always #5 clk = ~clk;

    integer i, j, i_0, i_1;
    real a0_values [0:VECTOR_LEN-1];
    real a1_values [0:VECTOR_LEN-1];
    real b_values  [0:VECTOR_LEN-1];
    real expected_0, expected_1;

    initial begin
        for (i = 0; i < VECTOR_LEN; i = i + 1) begin
            a0_values[i] = (i+1) / 100.0;
            a1_values[i] = (i+1) / 200.0;
            b_values[i] = (i+1)  / 1000.0;
        end

        rstn = 0;
        #45 rstn = 1;
        repeat (3) @(posedge clk);
        
        s_axi_b_awvalid = 0;
        s_axi_b_wvalid  = 0;
        s_axi_b_bready  = 0;
        s_axi_b_awid    = 0;
        s_axi_b_awlock  = 0;
        s_axi_b_awcache = 0;
        s_axi_b_awprot  = 0;
        s_axi_b_wlast   = 0;
        s_axi_b_wstrb   = 8'hFF;
        
        m_axis_0_tready <= 1;
        m_axis_1_tready <= 1;
        
        for (i = 0; i < VECTOR_LEN; i = i + 1) begin
            bram[i] = $realtobits(b_values[i]);
            $display("bram[%0d] = %h  (real = %f)", i, bram[i], b_values[i]);
        end
        axi_write_burst(32'h8000_0000);
        $display("Axi write complete.");

        for (j = 0; j < NUM_TRANSFERS; j = j + 1) begin
            
            expected_0 = 0;
            expected_1 = 0;
            
            fork
                begin : send_a0
                    for (i_0 = 0; i_0 < VECTOR_LEN; i_0 = i_0 + 1) begin
                        s_axis_a_0_tdata  = $realtobits(a0_values[i_0] + j);
                        s_axis_a_0_tvalid = 1;
                        @(posedge clk);
                        while (!s_axis_a_0_tready) @(posedge clk);
                        s_axis_a_0_tvalid = 0;
                        expected_0 = expected_0 + (a0_values[i_0] + j) * b_values[i_0];
                    end
                    wait(m_axis_0_tready && m_axis_0_tvalid && m_axis_0_tlast);
                    
                    @(posedge clk);
                    $display("%d: Result 0 (real): %f | Expected: %f", j, $bitstoreal(m_axis_0_tdata), expected_0);
                end
                begin : send_a1
                    for (i_1 = 0; i_1 < VECTOR_LEN; i_1 = i_1 + 1) begin
                        s_axis_a_1_tdata  = $realtobits(a1_values[i_1] + j);
                        s_axis_a_1_tvalid = 1;
                        @(posedge clk);
                        while (!s_axis_a_1_tready) @(posedge clk);
                        s_axis_a_1_tvalid = 0;
                        expected_1 = expected_1 + (a1_values[i_1] + j) * b_values[i_1];
                    end
                    wait(m_axis_1_tready && m_axis_1_tvalid && m_axis_1_tlast);
                    
                    @(posedge clk);
                    $display("%d: Result 1 (real): %f | Expected: %f", j, $bitstoreal(m_axis_1_tdata), expected_1);
                end
           join
        end
        $finish;
    end

endmodule