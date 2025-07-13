`timescale 1ns / 1ps

module mvm_accelerator #(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 32,
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    parameter ID_WIDTH = 4,
    parameter WORDS_PER_TRANSFER = 17048,
    parameter NUM_CHANNELS = 2
)(
    input wire clk,
    input wire rstn,

    // Input stream 0
    input  wire [DATA_WIDTH-1:0]  s_axis_a_0_tdata,
    input  wire                   s_axis_a_0_tvalid,
    output wire                   s_axis_a_0_tready,    
    
    // Output stream 0
    output wire [DATA_WIDTH-1:0]  m_axis_0_tdata,
    output wire                   m_axis_0_tvalid,
    input  wire                   m_axis_0_tready,
    output wire                   m_axis_0_tlast,
    
    // Input stream 1
    input  wire [DATA_WIDTH-1:0]  s_axis_a_1_tdata,
    input  wire                   s_axis_a_1_tvalid,
    output wire                   s_axis_a_1_tready,
      
    // Output stream 1
    output wire [DATA_WIDTH-1:0]  m_axis_1_tdata,
    output wire                   m_axis_1_tvalid,
    input  wire                   m_axis_1_tready,
    output wire                   m_axis_1_tlast,

    // S-AXI interface (for writing vector b)
    input  wire [7:0]             s_axi_b_awid,
    input  wire [ADDR_WIDTH-1:0]  s_axi_b_awaddr,
    input  wire [7:0]             s_axi_b_awlen,
    input  wire [2:0]             s_axi_b_awsize,
    input  wire [1:0]             s_axi_b_awburst,
    input  wire                   s_axi_b_awlock,
    input  wire [3:0]             s_axi_b_awcache,
    input  wire [2:0]             s_axi_b_awprot,
    input  wire                   s_axi_b_awvalid,
    output wire                   s_axi_b_awready,
    input  wire [DATA_WIDTH-1:0]  s_axi_b_wdata,
    input  wire [STRB_WIDTH-1:0]  s_axi_b_wstrb,
    input  wire                   s_axi_b_wlast,
    input  wire                   s_axi_b_wvalid,
    output wire                   s_axi_b_wready,
    output wire [7:0]             s_axi_b_bid,
    output wire [1:0]             s_axi_b_bresp,
    output wire                   s_axi_b_bvalid,
    input  wire                   s_axi_b_bready,
    input  wire [ID_WIDTH-1:0]    s_axi_b_arid,
    input  wire [ADDR_WIDTH-1:0]  s_axi_b_araddr,
    input  wire [7:0]             s_axi_b_arlen,
    input  wire [2:0]             s_axi_b_arsize,
    input  wire [1:0]             s_axi_b_arburst,
    input  wire                   s_axi_b_arlock,
    input  wire [3:0]             s_axi_b_arcache,
    input  wire [2:0]             s_axi_b_arprot,
    input  wire                   s_axi_b_arvalid,
    output wire                   s_axi_b_arready,
    output wire [ID_WIDTH-1:0]    s_axi_b_rid,
    output wire [DATA_WIDTH-1:0]  s_axi_b_rdata,
    output wire [1:0]             s_axi_b_rresp,
    output wire                   s_axi_b_rlast,
    output wire                   s_axi_b_rvalid,
    input  wire                   s_axi_b_rready
);

    // =============================================================
    //                         CHANNEL 0
    // =============================================================
    
    wire [ID_WIDTH-1:0]   dma0_m_axi_arid;
    wire [ADDR_WIDTH-1:0] dma0_m_axi_araddr;
    wire [7:0]            dma0_m_axi_arlen;
    wire [2:0]            dma0_m_axi_arsize;
    wire [1:0]            dma0_m_axi_arburst;
    wire                  dma0_m_axi_arlock;
    wire [3:0]            dma0_m_axi_arcache;
    wire [2:0]            dma0_m_axi_arprot;
    wire                  dma0_m_axi_arvalid;
    wire                  dma0_m_axi_arready;
    wire [ID_WIDTH-1:0]   dma0_m_axi_rid;
    wire [DATA_WIDTH-1:0] dma0_m_axi_rdata;
    wire [1:0]            dma0_m_axi_rresp;
    wire                  dma0_m_axi_rlast;
    wire                  dma0_m_axi_rvalid;
    wire                  dma0_m_axi_rready;
    
    mvm_channel #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .STRB_WIDTH(STRB_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .WORDS_PER_TRANSFER(WORDS_PER_TRANSFER),
        .TAG(8'h0)
    ) channel_0 (
        .clk(clk),
        .rstn(rstn),
        
        .s_axis_a_tdata(s_axis_a_0_tdata),
        .s_axis_a_tvalid(s_axis_a_0_tvalid),
        .s_axis_a_tready(s_axis_a_0_tready),
        
        .m_axis_tdata(m_axis_0_tdata),
        .m_axis_tvalid(m_axis_0_tvalid),
        .m_axis_tready(m_axis_0_tready),
        .m_axis_tlast(m_axis_0_tlast),
        
        // AXI Master Interface (to interconnect)
        .m_axi_arid    (dma0_m_axi_arid),
        .m_axi_araddr  (dma0_m_axi_araddr),
        .m_axi_arlen   (dma0_m_axi_arlen),
        .m_axi_arsize  (dma0_m_axi_arsize),
        .m_axi_arburst (dma0_m_axi_arburst),
        .m_axi_arlock  (dma0_m_axi_arlock),
        .m_axi_arcache (dma0_m_axi_arcache),
        .m_axi_arprot  (dma0_m_axi_arprot),
        .m_axi_arvalid (dma0_m_axi_arvalid),
        .m_axi_arready (dma0_m_axi_arready),
        .m_axi_rid     (dma0_m_axi_rid),
        .m_axi_rdata   (dma0_m_axi_rdata),
        .m_axi_rresp   (dma0_m_axi_rresp),
        .m_axi_rlast   (dma0_m_axi_rlast),
        .m_axi_rvalid  (dma0_m_axi_rvalid),
        .m_axi_rready  (dma0_m_axi_rready)
    );

    // =============================================================
    //                         CHANNEL 1
    // =============================================================
    
    wire [ID_WIDTH-1:0]   dma1_m_axi_arid;
    wire [ADDR_WIDTH-1:0] dma1_m_axi_araddr;
    wire [7:0]            dma1_m_axi_arlen;
    wire [2:0]            dma1_m_axi_arsize;
    wire [1:0]            dma1_m_axi_arburst;
    wire                  dma1_m_axi_arlock;
    wire [3:0]            dma1_m_axi_arcache;
    wire [2:0]            dma1_m_axi_arprot;
    wire                  dma1_m_axi_arvalid;
    wire                  dma1_m_axi_arready;
    wire [ID_WIDTH-1:0]   dma1_m_axi_rid;
    wire [DATA_WIDTH-1:0] dma1_m_axi_rdata;
    wire [1:0]            dma1_m_axi_rresp;
    wire                  dma1_m_axi_rlast;
    wire                  dma1_m_axi_rvalid;
    wire                  dma1_m_axi_rready;
    
    mvm_channel #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .STRB_WIDTH(STRB_WIDTH),
        .ID_WIDTH(ID_WIDTH),
        .WORDS_PER_TRANSFER(WORDS_PER_TRANSFER),
        .TAG(8'h1)
    ) channel_1 (
        .clk(clk),
        .rstn(rstn),
        
        .s_axis_a_tdata(s_axis_a_1_tdata),
        .s_axis_a_tvalid(s_axis_a_1_tvalid),
        .s_axis_a_tready(s_axis_a_1_tready),
        
        .m_axis_tdata(m_axis_1_tdata),
        .m_axis_tvalid(m_axis_1_tvalid),
        .m_axis_tready(m_axis_1_tready),
        .m_axis_tlast(m_axis_1_tlast),
        
        // AXI Master Interface (to interconnect)
        .m_axi_arid    (dma1_m_axi_arid),
        .m_axi_araddr  (dma1_m_axi_araddr),
        .m_axi_arlen   (dma1_m_axi_arlen),
        .m_axi_arsize  (dma1_m_axi_arsize),
        .m_axi_arburst (dma1_m_axi_arburst),
        .m_axi_arlock  (dma1_m_axi_arlock),
        .m_axi_arcache (dma1_m_axi_arcache),
        .m_axi_arprot  (dma1_m_axi_arprot),
        .m_axi_arvalid (dma1_m_axi_arvalid),
        .m_axi_arready (dma1_m_axi_arready),
        .m_axi_rid     (dma1_m_axi_rid),
        .m_axi_rdata   (dma1_m_axi_rdata),
        .m_axi_rresp   (dma1_m_axi_rresp),
        .m_axi_rlast   (dma1_m_axi_rlast),
        .m_axi_rvalid  (dma1_m_axi_rvalid),
        .m_axi_rready  (dma1_m_axi_rready)
    );
    
    // =============================================================
    //                   AXI INTERCONNECT
    // =============================================================
    
    localparam M_ID_WIDTH = NUM_CHANNELS * ID_WIDTH;

    wire [M_ID_WIDTH-1:0]  ram_m_axi_arid;
    wire [ADDR_WIDTH-1:0]  ram_m_axi_araddr;
    wire [7:0]             ram_m_axi_arlen;
    wire [2:0]             ram_m_axi_arsize;
    wire [1:0]             ram_m_axi_arburst;
    wire                   ram_m_axi_arlock;
    wire [3:0]             ram_m_axi_arcache;
    wire [2:0]             ram_m_axi_arprot;
    wire                   ram_m_axi_arvalid;
    wire                   ram_m_axi_arready;
    wire [M_ID_WIDTH-1:0]  ram_m_axi_rid;
    wire [DATA_WIDTH-1:0]  ram_m_axi_rdata;
    wire [1:0]             ram_m_axi_rresp;
    wire                   ram_m_axi_rlast;
    wire                   ram_m_axi_rvalid;
    wire                   ram_m_axi_rready;
    
    axi_interconnect_0 axi_interconnect_inst (
        .INTERCONNECT_ACLK(clk),
        .INTERCONNECT_ARESETN(rstn),
    
        .S00_AXI_ACLK(clk), .S00_AXI_ARESET_OUT_N(),
        .S01_AXI_ACLK(clk), .S01_AXI_ARESET_OUT_N(),
    
        // Slave Interface (DMA0 -> Interconnect)
        .S00_AXI_ARID     (dma0_m_axi_arid),
        .S00_AXI_ARADDR   (dma0_m_axi_araddr),
        .S00_AXI_ARLEN    (dma0_m_axi_arlen),
        .S00_AXI_ARSIZE   (dma0_m_axi_arsize),
        .S00_AXI_ARBURST  (dma0_m_axi_arburst),
        .S00_AXI_ARLOCK   (dma0_m_axi_arlock),
        .S00_AXI_ARCACHE  (dma0_m_axi_arcache),
        .S00_AXI_ARPROT   (dma0_m_axi_arprot),
        .S00_AXI_ARQOS    (4'b0000),
        .S00_AXI_ARVALID  (dma0_m_axi_arvalid),
        .S00_AXI_ARREADY  (dma0_m_axi_arready),
        .S00_AXI_RID      (dma0_m_axi_rid),
        .S00_AXI_RDATA    (dma0_m_axi_rdata),
        .S00_AXI_RRESP    (dma0_m_axi_rresp),
        .S00_AXI_RLAST    (dma0_m_axi_rlast),
        .S00_AXI_RVALID   (dma0_m_axi_rvalid),
        .S00_AXI_RREADY   (dma0_m_axi_rready),
        
        // Slave Interface (DMA1 -> Interconnect)
        .S01_AXI_ARID     (dma1_m_axi_arid),
        .S01_AXI_ARADDR   (dma1_m_axi_araddr),
        .S01_AXI_ARLEN    (dma1_m_axi_arlen),
        .S01_AXI_ARSIZE   (dma1_m_axi_arsize),
        .S01_AXI_ARBURST  (dma1_m_axi_arburst),
        .S01_AXI_ARLOCK   (dma1_m_axi_arlock),
        .S01_AXI_ARCACHE  (dma1_m_axi_arcache),
        .S01_AXI_ARPROT   (dma1_m_axi_arprot),
        .S01_AXI_ARQOS    (4'b0000),
        .S01_AXI_ARVALID  (dma1_m_axi_arvalid),
        .S01_AXI_ARREADY  (dma1_m_axi_arready),
        .S01_AXI_RID      (dma1_m_axi_rid),
        .S01_AXI_RDATA    (dma1_m_axi_rdata),
        .S01_AXI_RRESP    (dma1_m_axi_rresp),
        .S01_AXI_RLAST    (dma1_m_axi_rlast),
        .S01_AXI_RVALID   (dma1_m_axi_rvalid),
        .S01_AXI_RREADY   (dma1_m_axi_rready),
    
        // Master Interface (to BRAM)
        .M00_AXI_ACLK(clk),
        .M00_AXI_ARESET_OUT_N(),
        .M00_AXI_ARID     (ram_m_axi_arid),
        .M00_AXI_ARADDR   (ram_m_axi_araddr),
        .M00_AXI_ARLEN    (ram_m_axi_arlen),
        .M00_AXI_ARSIZE   (ram_m_axi_arsize),
        .M00_AXI_ARBURST  (ram_m_axi_arburst),
        .M00_AXI_ARLOCK   (ram_m_axi_arlock),
        .M00_AXI_ARCACHE  (ram_m_axi_arcache),
        .M00_AXI_ARPROT   (ram_m_axi_arprot),
        .M00_AXI_ARQOS    (),
        .M00_AXI_ARVALID  (ram_m_axi_arvalid),
        .M00_AXI_ARREADY  (ram_m_axi_arready),
        .M00_AXI_RID      (ram_m_axi_rid),
        .M00_AXI_RDATA    (ram_m_axi_rdata),
        .M00_AXI_RRESP    (ram_m_axi_rresp),
        .M00_AXI_RLAST    (ram_m_axi_rlast),
        .M00_AXI_RVALID   (ram_m_axi_rvalid),
        .M00_AXI_RREADY   (ram_m_axi_rready),
        
        // Unused write channels
        .S00_AXI_AWID(4'b0),    .S00_AXI_AWADDR(32'b0),   .S00_AXI_AWLEN(8'b0),
        .S00_AXI_AWSIZE(3'b0),  .S00_AXI_AWBURST(2'b0),   .S00_AXI_AWLOCK(1'b0),
        .S00_AXI_AWCACHE(4'b0), .S00_AXI_AWPROT(3'b0),    .S00_AXI_AWQOS(4'b0),
        .S00_AXI_AWVALID(1'b0), .S00_AXI_AWREADY(),
        .S00_AXI_WDATA(64'b0),  .S00_AXI_WSTRB(8'b0),     .S00_AXI_WLAST(1'b0),
        .S00_AXI_WVALID(1'b0),  .S00_AXI_WREADY(),
        .S00_AXI_BID(),         .S00_AXI_BRESP(),         .S00_AXI_BVALID(),
        .S00_AXI_BREADY(1'b0),
    
        .S01_AXI_AWID(4'b0),    .S01_AXI_AWADDR(32'b0),   .S01_AXI_AWLEN(8'b0),
        .S01_AXI_AWSIZE(3'b0),  .S01_AXI_AWBURST(2'b0),   .S01_AXI_AWLOCK(1'b0),
        .S01_AXI_AWCACHE(4'b0), .S01_AXI_AWPROT(3'b0),    .S01_AXI_AWQOS(4'b0),
        .S01_AXI_AWVALID(1'b0), .S01_AXI_AWREADY(),
        .S01_AXI_WDATA(64'b0),  .S01_AXI_WSTRB(8'b0),     .S01_AXI_WLAST(1'b0),
        .S01_AXI_WVALID(1'b0),  .S01_AXI_WREADY(),
        .S01_AXI_BID(),         .S01_AXI_BRESP(),         .S01_AXI_BVALID(),
        .S01_AXI_BREADY(1'b0),
    
        .M00_AXI_AWID(),        .M00_AXI_AWADDR(),        .M00_AXI_AWLEN(),
        .M00_AXI_AWSIZE(),      .M00_AXI_AWBURST(),       .M00_AXI_AWLOCK(),
        .M00_AXI_AWCACHE(),     .M00_AXI_AWPROT(),        .M00_AXI_AWQOS(),
        .M00_AXI_AWVALID(),     .M00_AXI_AWREADY(),
        .M00_AXI_WDATA(),       .M00_AXI_WSTRB(),         .M00_AXI_WLAST(),
        .M00_AXI_WVALID(),      .M00_AXI_WREADY(),
        .M00_AXI_BID(),         .M00_AXI_BRESP(),         .M00_AXI_BVALID(),
        .M00_AXI_BREADY()
    );
    
    // =============================================================
    //        BRAM CONTROLLER + INTERNAL MEMORY GENERATOR
    // =============================================================

    axi_bram_ctrl_0 axi_bram_ctrl_inst (
        .s_axi_aclk    (clk),
        .s_axi_aresetn (rstn),
    
        // Write address channel
        .s_axi_awid    (s_axi_b_awid),
        .s_axi_awaddr  (s_axi_b_awaddr[17:0]),
        .s_axi_awlen   (s_axi_b_awlen),
        .s_axi_awsize  (s_axi_b_awsize),
        .s_axi_awburst (s_axi_b_awburst),
        .s_axi_awlock  (s_axi_b_awlock),
        .s_axi_awcache (s_axi_b_awcache),
        .s_axi_awprot  (s_axi_b_awprot),
        .s_axi_awvalid (s_axi_b_awvalid),
        .s_axi_awready (s_axi_b_awready),
    
        // Write data channel
        .s_axi_wdata   (s_axi_b_wdata),
        .s_axi_wstrb   (s_axi_b_wstrb),
        .s_axi_wlast   (s_axi_b_wlast),
        .s_axi_wvalid  (s_axi_b_wvalid),
        .s_axi_wready  (s_axi_b_wready),
    
        // Write response channel
        .s_axi_bid     (s_axi_b_bid),
        .s_axi_bresp   (s_axi_b_bresp),
        .s_axi_bvalid  (s_axi_b_bvalid),
        .s_axi_bready  (s_axi_b_bready),
    
        // Read address channel
        .s_axi_arid    (ram_m_axi_arid),
        .s_axi_araddr  (ram_m_axi_araddr[17:0]),
        .s_axi_arlen   (ram_m_axi_arlen),
        .s_axi_arsize  (ram_m_axi_arsize),
        .s_axi_arburst (ram_m_axi_arburst),
        .s_axi_arlock  (ram_m_axi_arlock),
        .s_axi_arcache (ram_m_axi_arcache),
        .s_axi_arprot  (ram_m_axi_arprot),
        .s_axi_arvalid (ram_m_axi_arvalid),
        .s_axi_arready (ram_m_axi_arready),
    
        // Read data channel
        .s_axi_rid     (ram_m_axi_rid),
        .s_axi_rdata   (ram_m_axi_rdata),
        .s_axi_rresp   (ram_m_axi_rresp),
        .s_axi_rlast   (ram_m_axi_rlast),
        .s_axi_rvalid  (ram_m_axi_rvalid),
        .s_axi_rready  (ram_m_axi_rready)
    );

endmodule
