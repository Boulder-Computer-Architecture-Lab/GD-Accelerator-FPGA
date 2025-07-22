`timescale 1ns / 1ps

module mvm_accelerator_sync #(
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
    //                      START SIGNAL
    // =============================================================
    
    reg start; // goes high once any valid data is seen (for dma)
    
    always @* begin
        if (!rstn) begin
            start <= 0;
        end else begin
            if (!start &&
                s_axis_a_0_tvalid || s_axis_a_1_tvalid || s_axis_a_2_tvalid || s_axis_a_3_tvalid ||
                s_axis_a_4_tvalid || s_axis_a_5_tvalid || s_axis_a_6_tvalid || s_axis_a_7_tvalid)
                start <= 1;
        end
    end

    // =============================================================
    //                  PACK & GENERATE CHANNELS
    // =============================================================
    
    localparam MAX_CHANNELS = 8;
    
    // Input stream arrays
    wire [DATA_WIDTH-1:0] s_axis_a_tdata  [NUM_CHANNELS-1:0];
    wire                  s_axis_a_tvalid [NUM_CHANNELS-1:0];
    wire                  s_axis_a_tready [NUM_CHANNELS-1:0];
    
    wire [DATA_WIDTH-1:0] s_axis_b_tdata  [MAX_CHANNELS-1:0]; // need all 8 channels for consuming broadcaster outputs
    wire                  s_axis_b_tvalid [MAX_CHANNELS-1:0]; // need all 8 channels for consuming broadcaster outputs
    wire                  s_axis_b_tready [NUM_CHANNELS-1:0];
    
    // Output stream arrays
    wire [DATA_WIDTH-1:0] m_axis_tdata  [NUM_CHANNELS-1:0];
    wire                  m_axis_tvalid [NUM_CHANNELS-1:0];
    wire                  m_axis_tready [NUM_CHANNELS-1:0];
    wire                  m_axis_tlast  [NUM_CHANNELS-1:0];
    
    `include "bind_channels.vh"

    genvar i;
    generate
      for (i = 0; i < NUM_CHANNELS; i = i + 1) begin : mvm_channel_gen
        mvm_channel_sync #(
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
          
          .s_axis_b_tdata (s_axis_b_tdata[i]),
          .s_axis_b_tvalid(s_axis_b_tvalid[i]),
          .s_axis_b_tready(s_axis_b_tready[i]),
          
          .m_axis_tdata (m_axis_tdata[i]),
          .m_axis_tvalid(m_axis_tvalid[i]),
          .m_axis_tready(m_axis_tready[i]),
          .m_axis_tlast (m_axis_tlast[i])
        );
      end
    endgenerate

    // =============================================================
    //                          AXI RAM
    // =============================================================
    
    localparam AXI_RAM_ADDR_WIDTH = $clog2(STRB_WIDTH*WORDS_PER_TRANSFER);
    localparam ARQOS = 4'b0000;

    wire [(ID_WIDTH+4)-1:0] ram_m_axi_arid;
    wire [ADDR_WIDTH-1:0]   ram_m_axi_araddr;
    wire [7:0]              ram_m_axi_arlen;
    wire [2:0]              ram_m_axi_arsize;
    wire [1:0]              ram_m_axi_arburst;
    wire                    ram_m_axi_arlock;
    wire [3:0]              ram_m_axi_arcache;
    wire [2:0]              ram_m_axi_arprot;
    wire                    ram_m_axi_arvalid;
    wire                    ram_m_axi_arready;
    wire [(ID_WIDTH+4)-1:0] ram_m_axi_rid;
    wire [DATA_WIDTH-1:0]   ram_m_axi_rdata;
    wire [1:0]              ram_m_axi_rresp;
    wire                    ram_m_axi_rlast;
    wire                    ram_m_axi_rvalid;
    wire                    ram_m_axi_rready;
    
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

        // AXI Master read (by DMA)
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
    //                      AXI BROADCASTER
    // =============================================================
    
    wire [DATA_WIDTH-1:0] s_axis_bcast_tdata;
    wire                  s_axis_bcast_tready;
    wire                  s_axis_bcast_tvalid;
        
    axis_broadcaster_0 axis_broadcast_inst (
        .aclk      (clk),
        .aresetn   (rstn),
    
        // Input AXI Stream (from DMA MM2S)
        .s_axis_tdata  (s_axis_bcast_tdata),
        .s_axis_tvalid (s_axis_bcast_tvalid),
        .s_axis_tready (s_axis_bcast_tready),

        `include "broadcast_channels.vh"
    );
    
    // =============================================================
    //                 AXI DMA (RAM -> BROADCASTER)
    // =============================================================
    
    localparam                  DMA_BURST_LEN = 256;
    localparam [ADDR_WIDTH-1:0] dma_desc_addr = AXI_RAM_BASE_ADDR;
    localparam [19:0]           dma_desc_len  = WORDS_PER_TRANSFER * STRB_WIDTH;

    reg  dma_desc_valid;
    wire dma_desc_ready;
    
    wire [7:0] dma_desc_tag  = 8'd0;
    wire [7:0] dma_desc_id   = 8'd0;
    wire [7:0] dma_desc_dest = 8'd0;
    wire       dma_desc_user = 1'b0;
        
    wire [7:0] dma_status_tag;
    wire [3:0] dma_status_error;
    wire       dma_status_valid;
    
    reg desc_sent;
    
    always @(posedge clk) begin
        if (!rstn) begin
            desc_sent <= 1'b0;
            dma_desc_valid <= 1'b0;
        end else if (!desc_sent && start) begin
            if (dma_desc_ready) begin
                dma_desc_valid <= 1'b1;
                desc_sent <= 1'b1;
            end else begin
                dma_desc_valid <= 1'b1;
            end
        end else if (dma_status_valid) begin
            desc_sent <= 0; // Reset after row is consumed
        end else begin
            dma_desc_valid <= 1'b0;
        end
    end
        
    axi_dma_rd #(
        .AXI_DATA_WIDTH(DATA_WIDTH),
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_STRB_WIDTH(STRB_WIDTH),
        .AXI_ID_WIDTH(ID_WIDTH+4),
        .AXI_MAX_BURST_LEN(DMA_BURST_LEN),
        .AXIS_DATA_WIDTH(DATA_WIDTH),
        .AXIS_KEEP_ENABLE(1),
        .AXIS_LAST_ENABLE(0),
        .AXIS_USER_ENABLE(0),
        .LEN_WIDTH(20),
        .TAG_WIDTH(8),
        .ENABLE_SG(0),
        .ENABLE_UNALIGNED(1)
    ) dma (
        .clk(clk),
        .rstn(rstn),
    
        .s_axis_read_desc_addr(dma_desc_addr),
        .s_axis_read_desc_len(dma_desc_len),
        .s_axis_read_desc_tag(dma_desc_tag),
        .s_axis_read_desc_id(dma_desc_id),
        .s_axis_read_desc_dest(dma_desc_dest),
        .s_axis_read_desc_user(dma_desc_user),
        .s_axis_read_desc_valid(dma_desc_valid),
        .s_axis_read_desc_ready(dma_desc_ready),
    
        .m_axis_read_desc_status_tag(dma_status_tag),
        .m_axis_read_desc_status_error(dma_status_error),
        .m_axis_read_desc_status_valid(dma_status_valid),
    
        .m_axis_read_data_tdata(s_axis_bcast_tdata),
        .m_axis_read_data_tkeep(),
        .m_axis_read_data_tvalid(s_axis_bcast_tvalid),
        .m_axis_read_data_tready(s_axis_bcast_tready),
        .m_axis_read_data_tlast(),
        .m_axis_read_data_tid(),
        .m_axis_read_data_tdest(),
        .m_axis_read_data_tuser(),
    
        .m_axi_arid(ram_m_axi_arid),
        .m_axi_araddr(ram_m_axi_araddr),
        .m_axi_arlen(ram_m_axi_arlen),
        .m_axi_arsize(ram_m_axi_arsize),
        .m_axi_arburst(ram_m_axi_arburst),
        .m_axi_arlock(ram_m_axi_arlock),
        .m_axi_arcache(ram_m_axi_arcache),
        .m_axi_arprot(ram_m_axi_arprot),
        .m_axi_arvalid(ram_m_axi_arvalid),
        .m_axi_arready(ram_m_axi_arready),
        .m_axi_rid(ram_m_axi_rid),
        .m_axi_rdata(ram_m_axi_rdata),
        .m_axi_rresp(ram_m_axi_rresp),
        .m_axi_rlast(ram_m_axi_rlast),
        .m_axi_rvalid(ram_m_axi_rvalid),
        .m_axi_rready(ram_m_axi_rready),
    
        .enable(1'b1)
    );

endmodule
