`timescale 1ns / 1ps

module mvm_accelerator #(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 32,
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    parameter ID_WIDTH = 4,
    parameter WORDS_PER_TRANSFER = 17048,
    parameter NUM_CHANNELS = 4
)(
    input wire clk,
    input wire rstn,

    // Input streams
    input  wire [DATA_WIDTH-1:0] s_axis_a_0_tdata,
    input  wire                  s_axis_a_0_tvalid,
    output wire                  s_axis_a_0_tready,
    
    input  wire [DATA_WIDTH-1:0] s_axis_a_1_tdata,
    input  wire                  s_axis_a_1_tvalid,
    output wire                  s_axis_a_1_tready,
        
    input  wire [DATA_WIDTH-1:0] s_axis_a_2_tdata,
    input  wire                  s_axis_a_2_tvalid,
    output wire                  s_axis_a_2_tready,
    
    input  wire [DATA_WIDTH-1:0] s_axis_a_3_tdata,
    input  wire                  s_axis_a_3_tvalid,
    output wire                  s_axis_a_3_tready,
    
    // Output streams
    output wire [DATA_WIDTH-1:0] m_axis_0_tdata,
    output wire                  m_axis_0_tvalid,
    input  wire                  m_axis_0_tready,
    output wire                  m_axis_0_tlast,
    
    output wire [DATA_WIDTH-1:0] m_axis_1_tdata,
    output wire                  m_axis_1_tvalid,
    input  wire                  m_axis_1_tready,
    output wire                  m_axis_1_tlast,
    
    output wire [DATA_WIDTH-1:0] m_axis_2_tdata,
    output wire                  m_axis_2_tvalid,
    input  wire                  m_axis_2_tready,
    output wire                  m_axis_2_tlast,
    
    output wire [DATA_WIDTH-1:0] m_axis_3_tdata,
    output wire                  m_axis_3_tvalid,
    input  wire                  m_axis_3_tready,
    output wire                  m_axis_3_tlast,

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
    //                  PACK & GENERATE CHANNELS
    // =============================================================
    
    // Input stream arrays
    wire [DATA_WIDTH-1:0] s_axis_a_tdata  [NUM_CHANNELS-1:0];
    wire                  s_axis_a_tvalid [NUM_CHANNELS-1:0];
    wire                  s_axis_a_tready [NUM_CHANNELS-1:0];
    
    // Output stream arrays
    wire [DATA_WIDTH-1:0] m_axis_tdata  [NUM_CHANNELS-1:0];
    wire                  m_axis_tvalid [NUM_CHANNELS-1:0];
    wire                  m_axis_tready [NUM_CHANNELS-1:0];
    wire                  m_axis_tlast  [NUM_CHANNELS-1:0];
    
    // AXI master interface arrays
    wire [ID_WIDTH-1:0]     m_axi_arid    [NUM_CHANNELS-1:0];
    wire [ADDR_WIDTH-1:0]   m_axi_araddr  [NUM_CHANNELS-1:0];
    wire [7:0]              m_axi_arlen   [NUM_CHANNELS-1:0];
    wire [2:0]              m_axi_arsize  [NUM_CHANNELS-1:0];
    wire [1:0]              m_axi_arburst [NUM_CHANNELS-1:0];
    wire                    m_axi_arlock  [NUM_CHANNELS-1:0];
    wire [3:0]              m_axi_arcache [NUM_CHANNELS-1:0];
    wire [2:0]              m_axi_arprot  [NUM_CHANNELS-1:0];
    wire                    m_axi_arvalid [NUM_CHANNELS-1:0];
    wire                    m_axi_arready [NUM_CHANNELS-1:0];
    wire [ID_WIDTH-1:0]     m_axi_rid     [NUM_CHANNELS-1:0];
    wire [DATA_WIDTH-1:0]   m_axi_rdata   [NUM_CHANNELS-1:0];
    wire [1:0]              m_axi_rresp   [NUM_CHANNELS-1:0];
    wire                    m_axi_rlast   [NUM_CHANNELS-1:0];
    wire                    m_axi_rvalid  [NUM_CHANNELS-1:0];
    wire                    m_axi_rready  [NUM_CHANNELS-1:0];
    
    assign s_axis_a_tdata[0]  = s_axis_a_0_tdata;
    assign s_axis_a_tvalid[0] = s_axis_a_0_tvalid;
    
    assign s_axis_a_tdata[1]  = s_axis_a_1_tdata;
    assign s_axis_a_tvalid[1] = s_axis_a_1_tvalid;
    
    assign s_axis_a_tdata[2]  = s_axis_a_2_tdata;
    assign s_axis_a_tvalid[2] = s_axis_a_2_tvalid;
    
    assign s_axis_a_tdata[3]  = s_axis_a_3_tdata;
    assign s_axis_a_tvalid[3] = s_axis_a_3_tvalid;

    assign s_axis_a_0_tready = s_axis_a_tready[0];
    assign s_axis_a_1_tready = s_axis_a_tready[1];
    assign s_axis_a_2_tready = s_axis_a_tready[2];
    assign s_axis_a_3_tready = s_axis_a_tready[3];

    assign m_axis_0_tdata = m_axis_tdata[0];
    assign m_axis_0_tvalid = m_axis_tvalid[0];
    assign m_axis_tready[0] = m_axis_0_tready;
    assign m_axis_0_tlast = m_axis_tlast[0];

    assign m_axis_1_tdata = m_axis_tdata[1];
    assign m_axis_1_tvalid = m_axis_tvalid[1];
    assign m_axis_tready[1] = m_axis_1_tready;
    assign m_axis_1_tlast = m_axis_tlast[1];

    assign m_axis_2_tdata = m_axis_tdata[2];
    assign m_axis_2_tvalid = m_axis_tvalid[2];
    assign m_axis_tready[2] = m_axis_2_tready;
    assign m_axis_2_tlast = m_axis_tlast[2];

    assign m_axis_3_tdata = m_axis_tdata[3];
    assign m_axis_3_tvalid = m_axis_tvalid[3];
    assign m_axis_tready[3] = m_axis_3_tready;
    assign m_axis_3_tlast = m_axis_tlast[3];
    
    genvar i;
    generate
      for (i = 0; i < NUM_CHANNELS; i = i + 1) begin : mvm_channel_gen
        mvm_channel #(
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH),
          .STRB_WIDTH(STRB_WIDTH),
          .ID_WIDTH(ID_WIDTH),
          .WORDS_PER_TRANSFER(WORDS_PER_TRANSFER),
          .TAG(i[7:0])
        ) channel_inst (
          .clk(clk),
          .rstn(rstn),
    
          .s_axis_a_tdata (s_axis_a_tdata[i]),
          .s_axis_a_tvalid(s_axis_a_tvalid[i]),
          .s_axis_a_tready(s_axis_a_tready[i]),
    
          .m_axis_tdata (m_axis_tdata[i]),
          .m_axis_tvalid(m_axis_tvalid[i]),
          .m_axis_tready(m_axis_tready[i]),
          .m_axis_tlast (m_axis_tlast[i]),
    
          // AXI master
          .m_axi_arid    (m_axi_arid[i]),
          .m_axi_araddr  (m_axi_araddr[i]),
          .m_axi_arlen   (m_axi_arlen[i]),
          .m_axi_arsize  (m_axi_arsize[i]),
          .m_axi_arburst (m_axi_arburst[i]),
          .m_axi_arlock  (m_axi_arlock[i]),
          .m_axi_arcache (m_axi_arcache[i]),
          .m_axi_arprot  (m_axi_arprot[i]),
          .m_axi_arvalid (m_axi_arvalid[i]),
          .m_axi_arready (m_axi_arready[i]),
          .m_axi_rid     (m_axi_rid[i]),
          .m_axi_rdata   (m_axi_rdata[i]),
          .m_axi_rresp   (m_axi_rresp[i]),
          .m_axi_rlast   (m_axi_rlast[i]),
          .m_axi_rvalid  (m_axi_rvalid[i]),
          .m_axi_rready  (m_axi_rready[i])
        );
      end
    endgenerate
    
    // =============================================================
    //                   AXI INTERCONNECT
    // =============================================================
    
    localparam M_ID_WIDTH = ID_WIDTH + 4;
    localparam ARQOS = 4'b0000;

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
        .S02_AXI_ACLK(clk), .S02_AXI_ARESET_OUT_N(),
        .S03_AXI_ACLK(clk), .S03_AXI_ARESET_OUT_N(),
    
        // Slave Interface (DMA0 -> Interconnect)
        .S00_AXI_ARID     (m_axi_arid[0]),
        .S00_AXI_ARADDR   (m_axi_araddr[0]),
        .S00_AXI_ARLEN    (m_axi_arlen[0]),
        .S00_AXI_ARSIZE   (m_axi_arsize[0]),
        .S00_AXI_ARBURST  (m_axi_arburst[0]),
        .S00_AXI_ARLOCK   (m_axi_arlock[0]),
        .S00_AXI_ARCACHE  (m_axi_arcache[0]),
        .S00_AXI_ARPROT   (m_axi_arprot[0]),
        .S00_AXI_ARQOS    (ARQOS),
        .S00_AXI_ARVALID  (m_axi_arvalid[0]),
        .S00_AXI_ARREADY  (m_axi_arready[0]),
        .S00_AXI_RID      (m_axi_rid[0]),
        .S00_AXI_RDATA    (m_axi_rdata[0]),
        .S00_AXI_RRESP    (m_axi_rresp[0]),
        .S00_AXI_RLAST    (m_axi_rlast[0]),
        .S00_AXI_RVALID   (m_axi_rvalid[0]),
        .S00_AXI_RREADY   (m_axi_rready[0]),
        
        // Slave Interface (DMA1 -> Interconnect)
        .S01_AXI_ARID     (m_axi_arid[1]),
        .S01_AXI_ARADDR   (m_axi_araddr[1]),
        .S01_AXI_ARLEN    (m_axi_arlen[1]),
        .S01_AXI_ARSIZE   (m_axi_arsize[1]),
        .S01_AXI_ARBURST  (m_axi_arburst[1]),
        .S01_AXI_ARLOCK   (m_axi_arlock[1]),
        .S01_AXI_ARCACHE  (m_axi_arcache[1]),
        .S01_AXI_ARPROT   (m_axi_arprot[1]),
        .S01_AXI_ARQOS    (ARQOS),
        .S01_AXI_ARVALID  (m_axi_arvalid[1]),
        .S01_AXI_ARREADY  (m_axi_arready[1]),
        .S01_AXI_RID      (m_axi_rid[1]),
        .S01_AXI_RDATA    (m_axi_rdata[1]),
        .S01_AXI_RRESP    (m_axi_rresp[1]),
        .S01_AXI_RLAST    (m_axi_rlast[1]),
        .S01_AXI_RVALID   (m_axi_rvalid[1]),
        .S01_AXI_RREADY   (m_axi_rready[1]),
        
        // Slave Interface (DMA2 -> Interconnect)
        .S02_AXI_ARID     (m_axi_arid[2]),
        .S02_AXI_ARADDR   (m_axi_araddr[2]),
        .S02_AXI_ARLEN    (m_axi_arlen[2]),
        .S02_AXI_ARSIZE   (m_axi_arsize[2]),
        .S02_AXI_ARBURST  (m_axi_arburst[2]),
        .S02_AXI_ARLOCK   (m_axi_arlock[2]),
        .S02_AXI_ARCACHE  (m_axi_arcache[2]),
        .S02_AXI_ARPROT   (m_axi_arprot[2]),
        .S02_AXI_ARQOS    (ARQOS),
        .S02_AXI_ARVALID  (m_axi_arvalid[2]),
        .S02_AXI_ARREADY  (m_axi_arready[2]),
        .S02_AXI_RID      (m_axi_rid[2]),
        .S02_AXI_RDATA    (m_axi_rdata[2]),
        .S02_AXI_RRESP    (m_axi_rresp[2]),
        .S02_AXI_RLAST    (m_axi_rlast[2]),
        .S02_AXI_RVALID   (m_axi_rvalid[2]),
        .S02_AXI_RREADY   (m_axi_rready[2]),
        
        // Slave Interface (DMA3 -> Interconnect)
        .S03_AXI_ARID     (m_axi_arid[3]),
        .S03_AXI_ARADDR   (m_axi_araddr[3]),
        .S03_AXI_ARLEN    (m_axi_arlen[3]),
        .S03_AXI_ARSIZE   (m_axi_arsize[3]),
        .S03_AXI_ARBURST  (m_axi_arburst[3]),
        .S03_AXI_ARLOCK   (m_axi_arlock[3]),
        .S03_AXI_ARCACHE  (m_axi_arcache[3]),
        .S03_AXI_ARPROT   (m_axi_arprot[3]),
        .S03_AXI_ARQOS    (ARQOS),
        .S03_AXI_ARVALID  (m_axi_arvalid[3]),
        .S03_AXI_ARREADY  (m_axi_arready[3]),
        .S03_AXI_RID      (m_axi_rid[3]),
        .S03_AXI_RDATA    (m_axi_rdata[3]),
        .S03_AXI_RRESP    (m_axi_rresp[3]),
        .S03_AXI_RLAST    (m_axi_rlast[3]),
        .S03_AXI_RVALID   (m_axi_rvalid[3]),
        .S03_AXI_RREADY   (m_axi_rready[3]),
    
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
        
        .S02_AXI_AWID(4'b0),    .S02_AXI_AWADDR(32'b0),   .S02_AXI_AWLEN(8'b0),
        .S02_AXI_AWSIZE(3'b0),  .S02_AXI_AWBURST(2'b0),   .S02_AXI_AWLOCK(1'b0),
        .S02_AXI_AWCACHE(4'b0), .S02_AXI_AWPROT(3'b0),    .S02_AXI_AWQOS(4'b0),
        .S02_AXI_AWVALID(1'b0), .S02_AXI_AWREADY(),
        .S02_AXI_WDATA(64'b0),  .S02_AXI_WSTRB(8'b0),     .S02_AXI_WLAST(1'b0),
        .S02_AXI_WVALID(1'b0),  .S02_AXI_WREADY(),
        .S02_AXI_BID(),         .S02_AXI_BRESP(),         .S02_AXI_BVALID(),
        .S02_AXI_BREADY(1'b0),
        
        .S03_AXI_AWID(4'b0),    .S03_AXI_AWADDR(32'b0),   .S03_AXI_AWLEN(8'b0),
        .S03_AXI_AWSIZE(3'b0),  .S03_AXI_AWBURST(2'b0),   .S03_AXI_AWLOCK(1'b0),
        .S03_AXI_AWCACHE(4'b0), .S03_AXI_AWPROT(3'b0),    .S03_AXI_AWQOS(4'b0),
        .S03_AXI_AWVALID(1'b0), .S03_AXI_AWREADY(),
        .S03_AXI_WDATA(64'b0),  .S03_AXI_WSTRB(8'b0),     .S03_AXI_WLAST(1'b0),
        .S03_AXI_WVALID(1'b0),  .S03_AXI_WREADY(),
        .S03_AXI_BID(),         .S03_AXI_BRESP(),         .S03_AXI_BVALID(),
        .S03_AXI_BREADY(1'b0),
    
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
