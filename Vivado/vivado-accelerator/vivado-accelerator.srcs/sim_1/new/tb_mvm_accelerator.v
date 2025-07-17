`timescale 1ns / 1ps

module tb_mvm_accelerator;

    parameter DATA_WIDTH = 64;
    parameter ADDR_WIDTH = 32;
    parameter ID_WIDTH = 8;
    parameter S_INT_ID_WIDTH = ID_WIDTH - 4;
    parameter VECTOR_LEN = 64;
    parameter NUM_TRANSFERS = 4;

    reg clk = 0;
    reg rstn = 1;

    // Inputs
    reg  [DATA_WIDTH-1:0] s_axis_a_0_tdata;
    reg                   s_axis_a_0_tvalid;
    wire                  s_axis_a_0_tready;
    
    reg  [DATA_WIDTH-1:0] s_axis_a_1_tdata;
    reg                   s_axis_a_1_tvalid;
    wire                  s_axis_a_1_tready;
    
    reg  [DATA_WIDTH-1:0] s_axis_a_2_tdata;
    reg                   s_axis_a_2_tvalid;
    wire                  s_axis_a_2_tready;
    
    reg  [DATA_WIDTH-1:0] s_axis_a_3_tdata;
    reg                   s_axis_a_3_tvalid;
    wire                  s_axis_a_3_tready;
    
    // Outputs
    wire [DATA_WIDTH-1:0] m_axis_0_tdata;
    wire                  m_axis_0_tvalid;
    reg                   m_axis_0_tready;
    wire                  m_axis_0_tlast;
    
    wire [DATA_WIDTH-1:0] m_axis_1_tdata;
    wire                  m_axis_1_tvalid;
    reg                   m_axis_1_tready;
    wire                  m_axis_1_tlast;    
    
    wire [DATA_WIDTH-1:0] m_axis_2_tdata;
    wire                  m_axis_2_tvalid;
    reg                   m_axis_2_tready;
    wire                  m_axis_2_tlast;
    
    wire [DATA_WIDTH-1:0] m_axis_3_tdata;
    wire                  m_axis_3_tvalid;
    reg                   m_axis_3_tready;
    wire                  m_axis_3_tlast;

    // AXI Full write interface for vector b
    reg  [ID_WIDTH-1:0]   s_axi_b_awid;
    reg  [ADDR_WIDTH-1:0] s_axi_b_awaddr;
    reg  [7:0]            s_axi_b_awlen;
    reg  [2:0]            s_axi_b_awsize;
    reg  [1:0]            s_axi_b_awburst;
    reg                   s_axi_b_awlock;
    reg  [3:0]            s_axi_b_awcache;
    reg  [2:0]            s_axi_b_awprot;
    reg                   s_axi_b_awvalid;
    wire                  s_axi_b_awready;

    reg  [DATA_WIDTH-1:0] s_axi_b_wdata;
    reg  [7:0]            s_axi_b_wstrb;
    reg                   s_axi_b_wlast;
    reg                   s_axi_b_wvalid;
    wire                  s_axi_b_wready;

    wire [ID_WIDTH-1:0]   s_axi_b_bid;
    wire [1:0]            s_axi_b_bresp;
    wire                  s_axi_b_bvalid;
    reg                   s_axi_b_bready;
    
    reg s_axi_b_sel;
    
    wire [ID_WIDTH-1:0]       s0_axi_awid;
    wire [ADDR_WIDTH-1:0]     s0_axi_awaddr;
    wire [7:0]                s0_axi_awlen;
    wire [2:0]                s0_axi_awsize;
    wire [1:0]                s0_axi_awburst;
    wire                      s0_axi_awlock;
    wire [3:0]                s0_axi_awcache;
    wire [2:0]                s0_axi_awprot;
    wire                      s0_axi_awvalid;
    wire                      s0_axi_awready;
    wire [DATA_WIDTH-1:0]     s0_axi_wdata;
    wire [(DATA_WIDTH/8)-1:0] s0_axi_wstrb;
    wire                      s0_axi_wlast;
    wire                      s0_axi_wvalid;
    wire                      s0_axi_wready;
    wire [ID_WIDTH-1:0]       s0_axi_bid;
    wire [1:0]                s0_axi_bresp;
    wire                      s0_axi_bvalid;
    wire                      s0_axi_bready;
    
    wire [ID_WIDTH-1:0]       s1_axi_awid;
    wire [ADDR_WIDTH-1:0]     s1_axi_awaddr;
    wire [7:0]                s1_axi_awlen;
    wire [2:0]                s1_axi_awsize;
    wire [1:0]                s1_axi_awburst;
    wire                      s1_axi_awlock;
    wire [3:0]                s1_axi_awcache;
    wire [2:0]                s1_axi_awprot;
    wire                      s1_axi_awvalid;
    wire                      s1_axi_awready;
    wire [DATA_WIDTH-1:0]     s1_axi_wdata;
    wire [(DATA_WIDTH/8)-1:0] s1_axi_wstrb;
    wire                      s1_axi_wlast;
    wire                      s1_axi_wvalid;
    wire                      s1_axi_wready;
    wire [ID_WIDTH-1:0]       s1_axi_bid;
    wire [1:0]                s1_axi_bresp;
    wire                      s1_axi_bvalid;
    wire                      s1_axi_bready;
    
    // Write address channel
    assign s0_axi_awid    = (s_axi_b_sel == 0) ? s_axi_b_awid    : {ID_WIDTH{1'b0}};
    assign s0_axi_awaddr  = (s_axi_b_sel == 0) ? s_axi_b_awaddr  : {ADDR_WIDTH{1'b0}};
    assign s0_axi_awlen   = (s_axi_b_sel == 0) ? s_axi_b_awlen   : 8'd0;
    assign s0_axi_awsize  = (s_axi_b_sel == 0) ? s_axi_b_awsize  : 3'd0;
    assign s0_axi_awburst = (s_axi_b_sel == 0) ? s_axi_b_awburst : 2'd0;
    assign s0_axi_awlock  = (s_axi_b_sel == 0) ? s_axi_b_awlock  : 1'b0;
    assign s0_axi_awcache = (s_axi_b_sel == 0) ? s_axi_b_awcache : 4'd0;
    assign s0_axi_awprot  = (s_axi_b_sel == 0) ? s_axi_b_awprot  : 3'd0;
    assign s0_axi_awvalid = (s_axi_b_sel == 0) ? s_axi_b_awvalid : 1'b0;
    
    assign s1_axi_awid    = (s_axi_b_sel == 1) ? s_axi_b_awid    : {ID_WIDTH{1'b0}};
    assign s1_axi_awaddr  = (s_axi_b_sel == 1) ? s_axi_b_awaddr  : {ADDR_WIDTH{1'b0}};
    assign s1_axi_awlen   = (s_axi_b_sel == 1) ? s_axi_b_awlen   : 8'd0;
    assign s1_axi_awsize  = (s_axi_b_sel == 1) ? s_axi_b_awsize  : 3'd0;
    assign s1_axi_awburst = (s_axi_b_sel == 1) ? s_axi_b_awburst : 2'd0;
    assign s1_axi_awlock  = (s_axi_b_sel == 1) ? s_axi_b_awlock  : 1'b0;
    assign s1_axi_awcache = (s_axi_b_sel == 1) ? s_axi_b_awcache : 4'd0;
    assign s1_axi_awprot  = (s_axi_b_sel == 1) ? s_axi_b_awprot  : 3'd0;
    assign s1_axi_awvalid = (s_axi_b_sel == 1) ? s_axi_b_awvalid : 1'b0;
    
    // Write data channel
    assign s0_axi_wdata  = (s_axi_b_sel == 0) ? s_axi_b_wdata : {DATA_WIDTH{1'b0}};
    assign s0_axi_wstrb  = (s_axi_b_sel == 0) ? s_axi_b_wstrb : 8'd0;
    assign s0_axi_wlast  = (s_axi_b_sel == 0) ? s_axi_b_wlast : 1'b0;
    assign s0_axi_wvalid = (s_axi_b_sel == 0) ? s_axi_b_wvalid : 1'b0;
    
    assign s1_axi_wdata  = (s_axi_b_sel == 1) ? s_axi_b_wdata : {DATA_WIDTH{1'b0}};
    assign s1_axi_wstrb  = (s_axi_b_sel == 1) ? s_axi_b_wstrb : 8'd0;
    assign s1_axi_wlast  = (s_axi_b_sel == 1) ? s_axi_b_wlast : 1'b0;
    assign s1_axi_wvalid = (s_axi_b_sel == 1) ? s_axi_b_wvalid : 1'b0;
    
    // Write response ready
    assign s0_axi_bready = (s_axi_b_sel == 0) ? s_axi_b_bready : 1'b0;
    assign s1_axi_bready = (s_axi_b_sel == 1) ? s_axi_b_bready : 1'b0;
    
    // ready/valid/resp
    assign s_axi_b_awready = (s_axi_b_sel == 0) ? s0_axi_awready : s1_axi_awready;
    assign s_axi_b_wready  = (s_axi_b_sel == 0) ? s0_axi_wready  : s1_axi_wready;
    assign s_axi_b_bid     = (s_axi_b_sel == 0) ? s0_axi_bid     : s1_axi_bid;
    assign s_axi_b_bresp   = (s_axi_b_sel == 0) ? s0_axi_bresp   : s1_axi_bresp;
    assign s_axi_b_bvalid  = (s_axi_b_sel == 0) ? s0_axi_bvalid  : s1_axi_bvalid;
         
    reg [DATA_WIDTH-1:0] bram [VECTOR_LEN-1:0]; // Virtual BRAM
    
    // AXI write task for writing B vector
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

            wait (s_axi_b_awready && s_axi_b_awvalid);
            @(posedge clk);
            s_axi_b_awvalid = 0;
                
            // Write data
            for (k = 0; k < VECTOR_LEN; k = k + 1) begin
                s_axi_b_wdata = bram[k];
                s_axi_b_wstrb = 8'hFF;
                s_axi_b_wvalid = 1;
                s_axi_b_wlast = (k == VECTOR_LEN-1);
                
                wait (s_axi_b_wready && s_axi_b_wvalid);
                @(posedge clk);
                s_axi_b_wvalid = 0;
            end
            s_axi_b_wvalid = 0;
            s_axi_b_wlast = 0;
                    
            // Write response
            s_axi_b_bready = 1;
            wait (s_axi_b_bvalid && s_axi_b_bready);
            @(posedge clk);
            s_axi_b_bready = 0;
            
            // Reset
            s_axi_b_awvalid = 0;
            s_axi_b_wvalid  = 0;
            s_axi_b_bready  = 0;
            s_axi_b_awid    = 0;
            s_axi_b_awlock  = 0;
            s_axi_b_awcache = 0;
            s_axi_b_awprot  = 0;
            s_axi_b_wlast   = 0;
            s_axi_b_wstrb   = 8'hFF;
        end
    endtask
   
    /*
    axi_splitter axi_split_inst (
        .ACLK(clk),
        .ARESETN(rstn),
        
        .S_AXI_AWID(s_axi_b_awid),
        .S_AXI_AWADDR(s_axi_b_awaddr),
        .S_AXI_AWLEN(s_axi_b_awlen),
        .S_AXI_AWSIZE(s_axi_b_awsize),
        .S_AXI_AWBURST(s_axi_b_awburst),
        .S_AXI_AWVALID(s_axi_b_awvalid),
        .S_AXI_AWREADY(s_axi_b_awready),
        
        .S_AXI_WDATA(s_axi_b_wdata),
        .S_AXI_WSTRB(s_axi_b_wstrb),
        .S_AXI_WLAST(s_axi_b_wlast),
        .S_AXI_WVALID(s_axi_b_wvalid),
        .S_AXI_WREADY(s_axi_b_wready),
        
        .S_AXI_BID(s_axi_b_bid),
        .S_AXI_BRESP(s_axi_b_bresp),
        .S_AXI_BVALID(s_axi_b_bvalid),
        .S_AXI_BREADY(s_axi_b_bready),
        
        .M0_AXI_AWID(s0_axi_awid),
        .M0_AXI_AWADDR(s0_axi_awaddr),
        .M0_AXI_AWLEN(s0_axi_awlen),
        .M0_AXI_AWSIZE(s0_axi_awsize),
        .M0_AXI_AWBURST(s0_axi_awburst),
        .M0_AXI_AWVALID(s0_axi_awvalid),
        .M0_AXI_AWREADY(s0_axi_awready),
        
        .M0_AXI_WDATA(s0_axi_wdata),
        .M0_AXI_WSTRB(s0_axi_wstrb),
        .M0_AXI_WLAST(s0_axi_wlast),
        .M0_AXI_WVALID(s0_axi_wvalid),
        .M0_AXI_WREADY(s0_axi_wready),
        
        .M0_AXI_BID(s0_axi_bid),
        .M0_AXI_BRESP(s_axi_bresp),
        .M0_AXI_BVALID(s0_axi_bvalid),
        .M0_AXI_BREADY(s0_axi_bready),
        
        .M1_AXI_AWID(s1_axi_awid),
        .M1_AXI_AWADDR(s1_axi_awaddr),
        .M1_AXI_AWLEN(s1_axi_awlen),
        .M1_AXI_AWSIZE(s1_axi_awsize),
        .M1_AXI_AWBURST(s1_axi_awburst),
        .M1_AXI_AWVALID(s1_axi_awvalid),
        .M1_AXI_AWREADY(s1_axi_awready),
        
        .M1_AXI_WDATA(s1_axi_wdata),
        .M1_AXI_WSTRB(s1_axi_wstrb),
        .M1_AXI_WLAST(s1_axi_wlast),
        .M1_AXI_WVALID(s1_axi_wvalid),
        .M1_AXI_WREADY(s1_axi_wready),
        
        .M1_AXI_BID(s0_axi_bid),
        .M1_AXI_BRESP(s_axi_bresp),
        .M1_AXI_BVALID(s0_axi_bvalid),
        .M1_AXI_BREADY(s0_axi_bready)
    );
    */

    // Instantiate DUTs
    mvm_accelerator #(
        .WORDS_PER_TRANSFER(VECTOR_LEN)
    ) dut0 (
        .clk(clk),
        .rstn(rstn),

        .s_axis_a_0_tdata(s_axis_a_0_tdata),
        .s_axis_a_0_tvalid(s_axis_a_0_tvalid),
        .s_axis_a_0_tready(s_axis_a_0_tready),

        .s_axis_a_1_tdata(s_axis_a_1_tdata),
        .s_axis_a_1_tvalid(s_axis_a_1_tvalid),
        .s_axis_a_1_tready(s_axis_a_1_tready),
        
        .s_axi_b_awid(s0_axi_awid),
        .s_axi_b_awaddr(s0_axi_awaddr),
        .s_axi_b_awlen(s0_axi_awlen),
        .s_axi_b_awsize(s0_axi_awsize),
        .s_axi_b_awburst(s0_axi_awburst),
        .s_axi_b_awlock(s0_axi_awlock),
        .s_axi_b_awcache(s0_axi_awcache),
        .s_axi_b_awprot(s0_axi_awprot),
        .s_axi_b_awvalid(s0_axi_awvalid),
        .s_axi_b_awready(s0_axi_awready),
        .s_axi_b_wdata(s0_axi_wdata),
        .s_axi_b_wstrb(s0_axi_wstrb),
        .s_axi_b_wlast(s0_axi_wlast),
        .s_axi_b_wvalid(s0_axi_wvalid),
        .s_axi_b_wready(s0_axi_wready),
        .s_axi_b_bid(s0_axi_bid),
        .s_axi_b_bresp(s0_axi_bresp),
        .s_axi_b_bvalid(s0_axi_bvalid),
        .s_axi_b_bready(s0_axi_bready),

        .m_axis_0_tdata(m_axis_0_tdata),
        .m_axis_0_tvalid(m_axis_0_tvalid),
        .m_axis_0_tready(m_axis_0_tready),
        .m_axis_0_tlast(m_axis_0_tlast),

        .m_axis_1_tdata(m_axis_1_tdata),
        .m_axis_1_tvalid(m_axis_1_tvalid),
        .m_axis_1_tready(m_axis_1_tready),
        .m_axis_1_tlast(m_axis_1_tlast)
    );
    
    mvm_accelerator #(
        .WORDS_PER_TRANSFER(VECTOR_LEN)
    ) dut1 (
        .clk(clk),
        .rstn(rstn),

        .s_axis_a_0_tdata(s_axis_a_2_tdata),
        .s_axis_a_0_tvalid(s_axis_a_2_tvalid),
        .s_axis_a_0_tready(s_axis_a_2_tready),

        .s_axis_a_1_tdata(s_axis_a_3_tdata),
        .s_axis_a_1_tvalid(s_axis_a_3_tvalid),
        .s_axis_a_1_tready(s_axis_a_3_tready),
        
        .s_axi_b_awid(s1_axi_awid),
        .s_axi_b_awaddr(s1_axi_awaddr),
        .s_axi_b_awlen(s1_axi_awlen),
        .s_axi_b_awsize(s1_axi_awsize),
        .s_axi_b_awburst(s1_axi_awburst),
        .s_axi_b_awlock(s1_axi_awlock),
        .s_axi_b_awcache(s1_axi_awcache),
        .s_axi_b_awprot(s1_axi_awprot),
        .s_axi_b_awvalid(s1_axi_awvalid),
        .s_axi_b_awready(s1_axi_awready),
        .s_axi_b_wdata(s1_axi_wdata),
        .s_axi_b_wstrb(s1_axi_wstrb),
        .s_axi_b_wlast(s1_axi_wlast),
        .s_axi_b_wvalid(s1_axi_wvalid),
        .s_axi_b_wready(s1_axi_wready),
        .s_axi_b_bid(s1_axi_bid),
        .s_axi_b_bresp(s1_axi_bresp),
        .s_axi_b_bvalid(s1_axi_bvalid),
        .s_axi_b_bready(s1_axi_bready),

        .m_axis_0_tdata(m_axis_2_tdata),
        .m_axis_0_tvalid(m_axis_2_tvalid),
        .m_axis_0_tready(m_axis_2_tready),
        .m_axis_0_tlast(m_axis_2_tlast),

        .m_axis_1_tdata(m_axis_3_tdata),
        .m_axis_1_tvalid(m_axis_3_tvalid),
        .m_axis_1_tready(m_axis_3_tready),
        .m_axis_1_tlast(m_axis_3_tlast)
    );

    // Clock
    always #5 clk = ~clk;

    integer i, j, i_0, i_1, i_2, i_3;
    real a0_values [0:VECTOR_LEN-1];
    real a1_values [0:VECTOR_LEN-1];
    real a2_values [0:VECTOR_LEN-1];
    real a3_values [0:VECTOR_LEN-1];
    real b_values  [0:VECTOR_LEN-1];
    
    real expected_0, expected_1, expected_2, expected_3;

    initial begin
        for (i = 0; i < VECTOR_LEN; i = i + 1) begin
            a0_values[i] = (i+1) / 100.0;
            a1_values[i] = (i+1) / 200.0;
            a2_values[i] = (i+1) / 300.0;
            a3_values[i] = (i+1) / 400.0;
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
        m_axis_2_tready <= 1;
        m_axis_3_tready <= 1;
        
        for (i = 0; i < VECTOR_LEN; i = i + 1) begin
            bram[i] = $realtobits(b_values[i]);
            $display("bram[%0d] = %h  (real = %f)", i, bram[i], b_values[i]);
        end
        
        s_axi_b_sel = 0;
        repeat (10) @(posedge clk);
        axi_write_burst(32'h8000_0000);
        $display("Axi write 0 complete.");
                
        s_axi_b_sel = 1;
        repeat (10) @(posedge clk);
        axi_write_burst(32'h9000_0000);
        $display("Axi write 1 complete.");
        
        repeat (10) @(posedge clk);

        for (j = 0; j < NUM_TRANSFERS; j = j + 1) begin
            
            expected_0 = 0;
            expected_1 = 0;
            expected_2 = 0;
            expected_3 = 0;
         
            fork
                begin : send_a0
                    for (i_0 = 0; i_0 < VECTOR_LEN; i_0 = i_0 + 1) begin
                        s_axis_a_0_tdata  = $realtobits(a0_values[i_0] + j);
                        s_axis_a_0_tvalid = 1;

                        wait (s_axis_a_0_tready && s_axis_a_0_tvalid);
                        
                        @(posedge clk);
                        s_axis_a_0_tvalid = 0;
                        expected_0 = expected_0 + (a0_values[i_0] + j) * b_values[i_0];
                    end
                    
                    wait(m_axis_0_tready && m_axis_0_tvalid && m_axis_0_tlast);
                    
                    @(posedge clk);
                    $display("%d: Result 0: %f | Expected: %f", j, $bitstoreal(m_axis_0_tdata), expected_0);
                end
                begin : send_a1
                    for (i_1 = 0; i_1 < VECTOR_LEN; i_1 = i_1 + 1) begin
                        s_axis_a_1_tdata  = $realtobits(a1_values[i_1] + j);
                        s_axis_a_1_tvalid = 1;
                        
                        wait (s_axis_a_1_tready && s_axis_a_1_tvalid);
                        
                        @(posedge clk);
                        s_axis_a_1_tvalid = 0;
                        expected_1 = expected_1 + (a1_values[i_1] + j) * b_values[i_1];
                    end
                    
                    wait(m_axis_1_tready && m_axis_1_tvalid && m_axis_1_tlast);
                    
                    @(posedge clk);
                    $display("%d: Result 1: %f | Expected: %f", j, $bitstoreal(m_axis_1_tdata), expected_1);
                end
                begin : send_a2
                    for (i_2 = 0; i_2 < VECTOR_LEN; i_2 = i_2 + 1) begin
                        s_axis_a_2_tdata  = $realtobits(a2_values[i_2] + j);
                        s_axis_a_2_tvalid = 1;

                        wait (s_axis_a_2_tready && s_axis_a_2_tvalid);

                        @(posedge clk);
                        s_axis_a_2_tvalid = 0;
                        expected_2 = expected_2 + (a2_values[i_2] + j) * b_values[i_2];
                    end
                    
                    wait(m_axis_2_tready && m_axis_2_tvalid && m_axis_2_tlast);
                    
                    @(posedge clk);
                    $display("%d: Result 2: %f | Expected: %f", j, $bitstoreal(m_axis_2_tdata), expected_2);
                end
                begin : send_a3
                    for (i_3 = 0; i_3 < VECTOR_LEN; i_3 = i_3 + 1) begin
                        s_axis_a_3_tdata  = $realtobits(a3_values[i_3] + j);
                        s_axis_a_3_tvalid = 1;

                        wait (s_axis_a_3_tready && s_axis_a_3_tvalid);
                        
                        @(posedge clk);
                        s_axis_a_3_tvalid = 0;
                        expected_3 = expected_3 + (a3_values[i_3] + j) * b_values[i_3];
                    end
                    
                    wait(m_axis_3_tready && m_axis_3_tvalid && m_axis_3_tlast);
                    
                    @(posedge clk);
                    $display("%d: Result 3: %f | Expected: %f", j, $bitstoreal(m_axis_3_tdata), expected_3);
                end
           join
        end

        #100;

        $finish;
    end

endmodule