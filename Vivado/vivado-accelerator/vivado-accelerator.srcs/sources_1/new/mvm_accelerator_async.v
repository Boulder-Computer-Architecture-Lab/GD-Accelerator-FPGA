`timescale 1ns / 1ps

module mvm_accelerator_async #(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 32,
    parameter STRB_WIDTH = (DATA_WIDTH/8),
    parameter ID_WIDTH = 4,
    parameter AXI_RAM_BASE_ADDR  = 32'h8000_0000,
    parameter WORDS_PER_TRANSFER = 17048,
    parameter NUM_CHANNELS = 2
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
    
    input  wire [DATA_WIDTH-1:0] s_axis_a_4_tdata,
    input  wire                  s_axis_a_4_tvalid,
    output wire                  s_axis_a_4_tready,
    
    input  wire [DATA_WIDTH-1:0] s_axis_a_5_tdata,
    input  wire                  s_axis_a_5_tvalid,
    output wire                  s_axis_a_5_tready,
    
    input  wire [DATA_WIDTH-1:0] s_axis_a_6_tdata,
    input  wire                  s_axis_a_6_tvalid,
    output wire                  s_axis_a_6_tready,
    
    input  wire [DATA_WIDTH-1:0] s_axis_a_7_tdata,
    input  wire                  s_axis_a_7_tvalid,
    output wire                  s_axis_a_7_tready,
    
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
    
    output wire [DATA_WIDTH-1:0] m_axis_4_tdata,
    output wire                  m_axis_4_tvalid,
    input  wire                  m_axis_4_tready,
    output wire                  m_axis_4_tlast,
    
    output wire [DATA_WIDTH-1:0] m_axis_5_tdata,
    output wire                  m_axis_5_tvalid,
    input  wire                  m_axis_5_tready,
    output wire                  m_axis_5_tlast,
    
    output wire [DATA_WIDTH-1:0] m_axis_6_tdata,
    output wire                  m_axis_6_tvalid,
    input  wire                  m_axis_6_tready,
    output wire                  m_axis_6_tlast,

    output wire [DATA_WIDTH-1:0] m_axis_7_tdata,
    output wire                  m_axis_7_tvalid,
    input  wire                  m_axis_7_tready,
    output wire                  m_axis_7_tlast,

    // S-AXI interface (for writing vector b)
    input  wire [(ID_WIDTH+4)-1:0] s_axi_b_awid,
    input  wire [ADDR_WIDTH-1:0]   s_axi_b_awaddr,
    input  wire [7:0]              s_axi_b_awlen,
    input  wire [2:0]              s_axi_b_awsize,
    input  wire [1:0]              s_axi_b_awburst,
    input  wire                    s_axi_b_awlock,
    input  wire [3:0]              s_axi_b_awcache,
    input  wire [2:0]              s_axi_b_awprot,
    input  wire                    s_axi_b_awvalid,
    output wire                    s_axi_b_awready,
    
    input  wire [DATA_WIDTH-1:0]   s_axi_b_wdata,
    input  wire [STRB_WIDTH-1:0]   s_axi_b_wstrb,
    input  wire                    s_axi_b_wlast,
    input  wire                    s_axi_b_wvalid,
    output wire                    s_axi_b_wready,
    
    output wire [(ID_WIDTH+4)-1:0] s_axi_b_bid,
    output wire [1:0]              s_axi_b_bresp,
    output wire                    s_axi_b_bvalid,
    input  wire                    s_axi_b_bready
);

    // =============================================================
    //                  PACK & GENERATE CHANNELS
    // =============================================================
    
    // Input stream arrays
    wire [DATA_WIDTH-1:0] s_axis_a_tdata  [NUM_CHANNELS-1:0];
    wire                  s_axis_a_tvalid [NUM_CHANNELS-1:0];
    wire                  s_axis_a_tready [NUM_CHANNELS-1:0];
    
    wire [DATA_WIDTH-1:0] s_axis_b_tdata  [NUM_CHANNELS-1:0];
    wire                  s_axis_b_tvalid [NUM_CHANNELS-1:0];
    wire                  s_axis_b_tready [NUM_CHANNELS-1:0];
    
    // Output stream arrays
    wire [DATA_WIDTH-1:0] m_axis_tdata  [NUM_CHANNELS-1:0];
    wire                  m_axis_tvalid [NUM_CHANNELS-1:0];
    wire                  m_axis_tready [NUM_CHANNELS-1:0];
    wire                  m_axis_tlast  [NUM_CHANNELS-1:0];
    
    // AXI master interface arrays
    wire [ID_WIDTH-1:0]              m_axi_arid    [NUM_CHANNELS-1:0];
    wire [ADDR_WIDTH-1:0]            m_axi_araddr  [NUM_CHANNELS-1:0];
    wire [7:0]                       m_axi_arlen   [NUM_CHANNELS-1:0];
    wire [2:0]                       m_axi_arsize  [NUM_CHANNELS-1:0];
    wire [1:0]                       m_axi_arburst [NUM_CHANNELS-1:0];
    wire                             m_axi_arlock  [NUM_CHANNELS-1:0];
    wire [3:0]                       m_axi_arcache [NUM_CHANNELS-1:0];
    wire [2:0]                       m_axi_arprot  [NUM_CHANNELS-1:0];
    wire                             m_axi_arvalid [NUM_CHANNELS-1:0];
    wire                             m_axi_arready [NUM_CHANNELS-1:0];
    wire [ID_WIDTH-1:0]              m_axi_rid     [NUM_CHANNELS-1:0];
    wire [DATA_WIDTH-1:0]            m_axi_rdata   [NUM_CHANNELS-1:0];
    wire [1:0]                       m_axi_rresp   [NUM_CHANNELS-1:0];
    wire                             m_axi_rlast   [NUM_CHANNELS-1:0];
    wire                             m_axi_rvalid  [NUM_CHANNELS-1:0];
    wire                             m_axi_rready  [NUM_CHANNELS-1:0];
    
    `include "bind_channels.vh"

    genvar i;
    generate
      for (i = 0; i < NUM_CHANNELS; i = i + 1) begin : mvm_channel_gen
        mvm_channel_async #(
          .DATA_WIDTH(DATA_WIDTH),
          .ADDR_WIDTH(ADDR_WIDTH),
          .STRB_WIDTH(STRB_WIDTH),
          .ID_WIDTH(ID_WIDTH),
          .WORDS_PER_TRANSFER(WORDS_PER_TRANSFER),
          .AXI_RAM_BASE_ADDR(AXI_RAM_BASE_ADDR),
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
    //                          AXI RAM
    // =============================================================
    
    localparam AXI_RAM_ADDR_WIDTH = $clog2(STRB_WIDTH*WORDS_PER_TRANSFER);
    localparam ARQOS = 4'b0000;

    wire [(ID_WIDTH+4)-1:0]  ram_m_axi_arid;
    wire [ADDR_WIDTH-1:0]  ram_m_axi_araddr;
    wire [7:0]             ram_m_axi_arlen;
    wire [2:0]             ram_m_axi_arsize;
    wire [1:0]             ram_m_axi_arburst;
    wire                   ram_m_axi_arlock;
    wire [3:0]             ram_m_axi_arcache;
    wire [2:0]             ram_m_axi_arprot;
    wire                   ram_m_axi_arvalid;
    wire                   ram_m_axi_arready;
    wire [(ID_WIDTH+4)-1:0]  ram_m_axi_rid;
    wire [DATA_WIDTH-1:0]  ram_m_axi_rdata;
    wire [1:0]             ram_m_axi_rresp;
    wire                   ram_m_axi_rlast;
    wire                   ram_m_axi_rvalid;
    wire                   ram_m_axi_rready;
    
    axi_ram #(
        .NUM_WORDS(WORDS_PER_TRANSFER),
        .ADDR_WIDTH(AXI_RAM_ADDR_WIDTH),
        .ID_WIDTH(ID_WIDTH+4)
    ) axi_ram_inst (
        .clk(clk),
        .rstn(rstn),

        // AXI Full Slave (write vector b)
        .s_axi_awid(s_axi_b_awid),
        .s_axi_awaddr(s_axi_b_awaddr[AXI_RAM_ADDR_WIDTH-1:0]), // truncate 32 bit address
        .s_axi_awlen(s_axi_b_awlen),
        .s_axi_awsize(s_axi_b_awsize),
        .s_axi_awburst(s_axi_b_awburst),
        .s_axi_awlock(s_axi_b_awlock),
        .s_axi_awcache(s_axi_b_awcache),
        .s_axi_awprot(s_axi_b_awprot),
        .s_axi_awvalid(s_axi_b_awvalid),
        .s_axi_awready(s_axi_b_awready),
        
        .s_axi_wdata(s_axi_b_wdata),
        .s_axi_wstrb(s_axi_b_wstrb),
        .s_axi_wlast(s_axi_b_wlast),
        .s_axi_wvalid(s_axi_b_wvalid),
        .s_axi_wready(s_axi_b_wready),
        
        .s_axi_bid(s_axi_b_bid),
        .s_axi_bresp(s_axi_b_bresp),
        .s_axi_bvalid(s_axi_b_bvalid),
        .s_axi_bready(s_axi_b_bready),

        // AXI Master read for DMA (from interconnect)
        .s_axi_arid(ram_m_axi_arid),
        .s_axi_araddr(ram_m_axi_araddr[AXI_RAM_ADDR_WIDTH-1:0]), // truncate 32 bit address
        .s_axi_arlen(ram_m_axi_arlen),
        .s_axi_arsize(ram_m_axi_arsize),
        .s_axi_arburst(ram_m_axi_arburst),
        .s_axi_arlock(ram_m_axi_arlock),
        .s_axi_arcache(ram_m_axi_arcache),
        .s_axi_arprot(ram_m_axi_arprot),
        .s_axi_arvalid(ram_m_axi_arvalid),
        .s_axi_arready(ram_m_axi_arready),
    
        .s_axi_rid(ram_m_axi_rid),
        .s_axi_rdata(ram_m_axi_rdata),
        .s_axi_rresp(ram_m_axi_rresp),
        .s_axi_rlast(ram_m_axi_rlast),
        .s_axi_rvalid(ram_m_axi_rvalid),
        .s_axi_rready(ram_m_axi_rready)
    );
    
    // =============================================================
    //                      AXI INTERCONNECT
    // =============================================================
    
    // Reads from AXI_RAM and sends to DMA -> FIFO_b -> FMA
    axi_interconnect_0 axi_interconnect_inst (
        .INTERCONNECT_ACLK(clk),
        .INTERCONNECT_ARESETN(rstn),
    
        `include "interconnect_channels.vh"
    
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
        .M00_AXI_RREADY   (ram_m_axi_rready)
    );

endmodule
