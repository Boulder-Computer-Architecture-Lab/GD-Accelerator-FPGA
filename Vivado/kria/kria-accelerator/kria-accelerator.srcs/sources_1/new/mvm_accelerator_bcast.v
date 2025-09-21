`timescale 1ns / 1ps

module mvm_accelerator_bcast #(
    parameter DATA_WIDTH         = 128,
    parameter ADDR_WIDTH         = 64,
    parameter STRB_WIDTH         = DATA_WIDTH / 8,
    parameter ID_WIDTH           = 8,
    
    parameter ELEMENT_WIDTH      = 64,
    parameter ELEMENTS_PER_WORD  = DATA_WIDTH / ELEMENT_WIDTH, // MUST BE A POWER OF 2!
    
    parameter ELEMENTS_PER_ROW   = 17048,
    parameter WORDS_PER_ROW      = ELEMENTS_PER_ROW / ELEMENTS_PER_WORD,
    parameter NUM_ROWS           = 1024,
    
    parameter NUM_CHANNELS       = 4,
    parameter ROWS_PER_CHANNEL   = NUM_ROWS / NUM_CHANNELS,
    
    parameter AXI_RAM_BASE_ADDR  = 64'h8000_0000,
    parameter AXI_RAM_ID_WIDTH = ID_WIDTH + $clog2(NUM_CHANNELS)
)(
    // Fast clock
    input wire s_clk,
    input wire s_rstn,
    
    // Slow clocks
    input wire m_clk,
    input wire m_rstn,
    
    // Input streams
    input  wire [DATA_WIDTH-1:0] s_axis_a_0_tdata,
    input  wire                  s_axis_a_0_tvalid,
    output wire                  s_axis_a_0_tready,
    input  wire                  s_axis_a_0_tlast,
    
    input  wire [DATA_WIDTH-1:0] s_axis_a_1_tdata,
    input  wire                  s_axis_a_1_tvalid,
    output wire                  s_axis_a_1_tready,
    input  wire                  s_axis_a_1_tlast,

    input  wire [DATA_WIDTH-1:0] s_axis_a_2_tdata,
    input  wire                  s_axis_a_2_tvalid,
    output wire                  s_axis_a_2_tready,
    input  wire                  s_axis_a_2_tlast,
    
    input  wire [DATA_WIDTH-1:0] s_axis_a_3_tdata,
    input  wire                  s_axis_a_3_tvalid,
    output wire                  s_axis_a_3_tready,
    input  wire                  s_axis_a_3_tlast,
    
    // Output streams
    output wire [ELEMENT_WIDTH-1:0] m_axis_0_tdata,
    output wire                     m_axis_0_tvalid,
    input  wire                     m_axis_0_tready,
    output wire                     m_axis_0_tlast,
    
    output wire [ELEMENT_WIDTH-1:0] m_axis_1_tdata,
    output wire                     m_axis_1_tvalid,
    input  wire                     m_axis_1_tready,
    output wire                     m_axis_1_tlast,
    
    output wire [ELEMENT_WIDTH-1:0] m_axis_2_tdata,
    output wire                     m_axis_2_tvalid,
    input  wire                     m_axis_2_tready,
    output wire                     m_axis_2_tlast,

    output wire [ELEMENT_WIDTH-1:0] m_axis_3_tdata,
    output wire                     m_axis_3_tvalid,
    input  wire                     m_axis_3_tready,
    output wire                     m_axis_3_tlast,

    // S-AXI interface
    input  wire [AXI_RAM_ID_WIDTH-1:0] s_axi_b_awid,
    input  wire [ADDR_WIDTH-1:0]       s_axi_b_awaddr,
    input  wire [7:0]                  s_axi_b_awlen,
    input  wire [2:0]                  s_axi_b_awsize,
    input  wire [1:0]                  s_axi_b_awburst,
    input  wire                        s_axi_b_awlock,
    input  wire [3:0]                  s_axi_b_awcache,
    input  wire [2:0]                  s_axi_b_awprot,
    input  wire                        s_axi_b_awvalid,
    output wire                        s_axi_b_awready,
    
    input  wire [DATA_WIDTH-1:0]       s_axi_b_wdata,
    input  wire [STRB_WIDTH-1:0]       s_axi_b_wstrb,
    input  wire                        s_axi_b_wlast,
    input  wire                        s_axi_b_wvalid,
    output wire                        s_axi_b_wready,
    
    output wire [AXI_RAM_ID_WIDTH-1:0] s_axi_b_bid,
    output wire [1:0]                  s_axi_b_bresp,
    output wire                        s_axi_b_bvalid,
    input  wire                        s_axi_b_bready
);  

    // =============================================================
    //                      PACK CHANNELS
    // =============================================================
    
    localparam MAX_CH = 4;
    
    // Input stream arrays
    wire [DATA_WIDTH-1:0] s_axis_a_tdata  [MAX_CH-1:0];
    wire                  s_axis_a_tvalid [MAX_CH-1:0];
    wire                  s_axis_a_tready [MAX_CH-1:0];
    wire                  s_axis_a_tlast  [MAX_CH-1:0];
    
    wire [DATA_WIDTH-1:0] s_axis_b_tdata  [MAX_CH-1:0];
    wire                  s_axis_b_tvalid [MAX_CH-1:0];
    wire                  s_axis_b_tready [MAX_CH-1:0];
    wire                  s_axis_b_tlast  [MAX_CH-1:0];

    // Output stream arrays
    wire [ELEMENT_WIDTH-1:0] m_axis_tdata  [MAX_CH-1:0];
    wire                     m_axis_tvalid [MAX_CH-1:0];
    wire                     m_axis_tready [MAX_CH-1:0];
    wire                     m_axis_tlast  [MAX_CH-1:0];
    
    assign s_axis_a_tdata[0]  = s_axis_a_0_tdata;
    assign s_axis_a_tvalid[0] = s_axis_a_0_tvalid;
    assign s_axis_a_0_tready  = s_axis_a_tready[0];
    assign s_axis_a_tlast[0]  = s_axis_a_0_tlast;
    
    assign m_axis_0_tdata   = m_axis_tdata[0];
    assign m_axis_0_tvalid  = m_axis_tvalid[0];
    assign m_axis_tready[0] = m_axis_0_tready;
    assign m_axis_0_tlast   = m_axis_tlast[0];
    
    assign s_axis_a_tdata[1]  = s_axis_a_1_tdata;
    assign s_axis_a_tvalid[1] = s_axis_a_1_tvalid;
    assign s_axis_a_1_tready  = s_axis_a_tready[1];
    assign s_axis_a_tlast[1]  = s_axis_a_1_tlast;
    
    assign m_axis_1_tdata   = m_axis_tdata[1];
    assign m_axis_1_tvalid  = m_axis_tvalid[1];
    assign m_axis_tready[1] = m_axis_1_tready;
    assign m_axis_1_tlast   = m_axis_tlast[1];
    
    assign s_axis_a_tdata[2]  = s_axis_a_2_tdata;
    assign s_axis_a_tvalid[2] = s_axis_a_2_tvalid;
    assign s_axis_a_2_tready  = s_axis_a_tready[2];
    assign s_axis_a_tlast[2]  = s_axis_a_2_tlast;
    
    assign m_axis_2_tdata   = m_axis_tdata[2];
    assign m_axis_2_tvalid  = m_axis_tvalid[2];
    assign m_axis_tready[2] = m_axis_2_tready;
    assign m_axis_2_tlast   = m_axis_tlast[2];
    
    assign s_axis_a_tdata[3]  = s_axis_a_3_tdata;
    assign s_axis_a_tvalid[3] = s_axis_a_3_tvalid;
    assign s_axis_a_3_tready  = s_axis_a_tready[3];
    assign s_axis_a_tlast[3]  = s_axis_a_3_tlast;
    
    assign m_axis_3_tdata   = m_axis_tdata[3];
    assign m_axis_3_tvalid  = m_axis_tvalid[3];
    assign m_axis_tready[3] = m_axis_3_tready;
    assign m_axis_3_tlast   = m_axis_tlast[3];

    // =============================================================
    //                          RAM VALID 
    // =============================================================
    
    //localparam WORDS_PER_BURST = 256;
    //localparam BURSTS_PER_ROW = WORDS_PER_ROW / WORDS_PER_BURST; // must divide evenly
    //localparam BURST_COUNT_WIDTH = $clog2(BURSTS_PER_ROW+1);

    //reg  [BURST_COUNT_WIDTH-1:0] burst_count;
    //wire                         ram_valid;

    //always @(posedge s_clk) begin
    //    if (!s_rstn) begin
    //        burst_count <= 0;
    //    end else if (s_axi_b_bvalid && s_axi_b_bready) begin
    //        burst_count <= burst_count + 1;
    //    end
    //end

    //assign ram_valid = (burst_count >= BURSTS_PER_ROW-1);
    
    localparam WORD_COUNT_WIDTH = $clog2(WORDS_PER_ROW+1);
    
    reg  [WORD_COUNT_WIDTH-1:0] ram_word_count;
    wire                        ram_valid;

    always @(posedge s_clk) begin
        if (!s_rstn) begin
            ram_word_count <= 0;
        end else if (s_axi_b_wvalid && s_axi_b_wready) begin
            ram_word_count <= ram_word_count + 1;
        end
    end

    assign ram_valid = (ram_word_count >= WORDS_PER_ROW-1);

    // =============================================================
    //                  GENERATE CHANNELS
    // =============================================================

    genvar ch;
    generate
        for (ch = 0; ch < NUM_CHANNELS; ch = ch + 1) begin : channel_gen
        
            mvm_channel_bcast #(
              .DATA_WIDTH(DATA_WIDTH),
              .ADDR_WIDTH(ADDR_WIDTH),
              .STRB_WIDTH(STRB_WIDTH),
              .ID_WIDTH(ID_WIDTH),

              .ELEMENT_WIDTH(ELEMENT_WIDTH),
              .ELEMENTS_PER_WORD(ELEMENTS_PER_WORD),
              .ELEMENTS_PER_ROW(ELEMENTS_PER_ROW),
              .WORDS_PER_ROW(WORDS_PER_ROW),
              .NUM_ROWS(NUM_ROWS),

              .NUM_CHANNELS(NUM_CHANNELS),
              .ROWS_PER_CHANNEL(ROWS_PER_CHANNEL)

            ) channel_inst (
              .s_clk(s_clk), .m_clk(m_clk),
              .s_rstn(s_rstn), .m_rstn(m_rstn),
                      
              .s_axis_a_tdata (s_axis_a_tdata[ch]),
              .s_axis_a_tvalid(s_axis_a_tvalid[ch]),
              .s_axis_a_tready(s_axis_a_tready[ch]),
              .s_axis_a_tlast (s_axis_a_tlast[ch]),
              
              .s_axis_b_tdata (s_axis_b_tdata[ch]),
              .s_axis_b_tvalid(s_axis_b_tvalid[ch]),
              .s_axis_b_tready(s_axis_b_tready[ch]),
              .s_axis_b_tlast (s_axis_b_tlast[ch]),

              .m_axis_tdata (m_axis_tdata[ch]),
              .m_axis_tvalid(m_axis_tvalid[ch]),
              .m_axis_tready(m_axis_tready[ch]),
              .m_axis_tlast (m_axis_tlast[ch])
            );
        end
    endgenerate

    // =============================================================
    //                          AXI RAM
    // =============================================================
    
    localparam AXI_RAM_ADDR_WIDTH = $clog2(WORDS_PER_ROW * STRB_WIDTH);
    
    wire [AXI_RAM_ID_WIDTH-1:0] ram_m_axi_arid;
    wire [ADDR_WIDTH-1:0]       ram_m_axi_araddr;
    wire [7:0]                  ram_m_axi_arlen;  
    wire [2:0]                  ram_m_axi_arsize;
    wire [1:0]                  ram_m_axi_arburst;
    wire                        ram_m_axi_arlock;
    wire [3:0]                  ram_m_axi_arcache;
    wire [2:0]                  ram_m_axi_arprot;
    wire                        ram_m_axi_arvalid;
    wire                        ram_m_axi_arready;
    wire [AXI_RAM_ID_WIDTH-1:0] ram_m_axi_rid;
    wire [DATA_WIDTH-1:0]       ram_m_axi_rdata; 
    wire [1:0]                  ram_m_axi_rresp;
    wire                        ram_m_axi_rlast;
    wire                        ram_m_axi_rvalid;
    wire                        ram_m_axi_rready;
    
    axi_ram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(AXI_RAM_ADDR_WIDTH),
        .STRB_WIDTH(STRB_WIDTH),
        .ID_WIDTH(AXI_RAM_ID_WIDTH),
        .RAM_TYPE(0), // BRAM
        .NUM_WORDS(WORDS_PER_ROW)
    ) axi_ram_inst (
        .clk(s_clk),
        .rstn(s_rstn),

        // AXI Full Slave
        .s_axi_awid(s_axi_b_awid),
        .s_axi_awaddr(s_axi_b_awaddr[AXI_RAM_ADDR_WIDTH-1:0]),
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

        // AXI Master Read
        .s_axi_arid(ram_m_axi_arid),
        .s_axi_araddr(ram_m_axi_araddr[AXI_RAM_ADDR_WIDTH-1:0]),
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

    // ========================================
    //               BROADCASTER   
    // ========================================
    
    wire [DATA_WIDTH-1:0] s_axis_bcast_tdata;
    wire                  s_axis_bcast_tvalid;
    wire                  s_axis_bcast_tready;
    wire                  s_axis_bcast_tlast;
    
    axis_broadcast #(
        .M_COUNT(NUM_CHANNELS),
        .DATA_WIDTH(DATA_WIDTH)
    ) bcast (
        .clk(s_clk), .rstn(s_rstn),

        .s_axis_tdata(s_axis_bcast_tdata),
        .s_axis_tvalid(s_axis_bcast_tvalid),
        .s_axis_tready(s_axis_bcast_tready),
        .s_axis_tlast(s_axis_bcast_tlast),

        `include "broadcast_channels.vh"
    );
    
    // ========================================
    //        MM2S DMA (RAM -> BCAST)
    // ========================================
    
    localparam BYTES_PER_ROW = WORDS_PER_ROW * STRB_WIDTH;
    localparam DMA_LEN_WIDTH = $clog2(BYTES_PER_ROW+1);
    localparam DMA_BURST_LEN = 256;
    localparam DMA_TAG_WIDTH = 8;
            
    wire [ADDR_WIDTH-1:0] dma_desc_addr = AXI_RAM_BASE_ADDR;
    wire [DMA_LEN_WIDTH-1:0] dma_desc_len = BYTES_PER_ROW;

    reg  dma_desc_valid;
    wire dma_desc_ready;
    
    wire [7:0] dma_desc_tag  = 8'd0;
    wire [7:0] dma_desc_id   = 8'd0;
    wire [7:0] dma_desc_dest = 8'd0;
    wire       dma_desc_user = 1'b0;
        
    wire [7:0] dma_status_tag;
    wire [3:0] dma_status_error;
    wire       dma_status_valid;

    reg dma_desc_sent;
    
    always @(posedge s_clk) begin
        if (!s_rstn) begin
           dma_desc_sent <= 1'b0;
            dma_desc_valid <= 1'b0;
        end else if (!dma_desc_sent && ram_valid) begin
            dma_desc_valid <= 1'b1;
            if (dma_desc_valid && dma_desc_ready) begin
                dma_desc_sent <= 1'b1;
                dma_desc_valid <= 1'b0;
            end
        end else if (dma_status_valid) begin
            dma_desc_sent <= 1'b0; 
        end
    end
        
    axi_dma_rd #(
        .AXI_DATA_WIDTH(DATA_WIDTH),
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_STRB_WIDTH(STRB_WIDTH),
        .AXI_ID_WIDTH(ID_WIDTH),
        .AXI_MAX_BURST_LEN(DMA_BURST_LEN),
        .AXIS_USER_ENABLE(0),
        .LEN_WIDTH(DMA_LEN_WIDTH),
        .TAG_WIDTH(DMA_TAG_WIDTH)
    ) dma (
        .clk(s_clk),
        .rstn(s_rstn),
    
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
        .m_axis_read_data_tlast(s_axis_bcast_tlast),
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
