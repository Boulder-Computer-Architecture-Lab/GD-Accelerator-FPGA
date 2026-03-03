`timescale 1ns / 1ps

module ile_iter #(
    parameter MAX_CH = 4,

    parameter DATA_WIDTH         = 128,
    parameter ADDR_WIDTH         = 64,
    parameter STRB_WIDTH         = DATA_WIDTH / 8,
    parameter ID_WIDTH           = 8,
    
    parameter ELEMENT_WIDTH      = 16,

    parameter NUM_ROWS           = 17048,
    parameter ELEMENTS_PER_ROW   = 17048,

    parameter NUM_CHANNELS       = 4,
    parameter NUM_RAM_PARTITIONS = NUM_CHANNELS,

    parameter ELEMENTS_PER_WORD  = DATA_WIDTH / ELEMENT_WIDTH,
    parameter WORDS_PER_ROW      = ELEMENTS_PER_ROW / ELEMENTS_PER_WORD,
    parameter ROWS_PER_CHANNEL   = NUM_ROWS / NUM_CHANNELS,
    
    parameter AXI_RAM_DATA_WIDTH = 256,
    parameter AXI_RAM_BASE_ADDR  = 64'h8000_0000,
    parameter AXI_RAM_STRB_WIDTH = AXI_RAM_DATA_WIDTH / 8
)(
    input wire clk,
    input wire rstn,
    
    // Input stream arrays
    input  wire [DATA_WIDTH*MAX_CH-1:0] s_axis_a_tdata,
    input  wire [MAX_CH-1:0]            s_axis_a_tvalid,
    output wire [MAX_CH-1:0]            s_axis_a_tready,
    input  wire [MAX_CH-1:0]            s_axis_a_tlast,
    
    // Output stream arrays
    output wire [ELEMENT_WIDTH*MAX_CH-1:0] m_axis_tdata,
    output wire [MAX_CH-1:0]               m_axis_tvalid,
    input  wire [MAX_CH-1:0]               m_axis_tready,
    output wire [MAX_CH-1:0]               m_axis_tlast,
    
    // S-AXI interface
    input  wire [ID_WIDTH-1:0]           s_axi_b_awid,
    input  wire [ADDR_WIDTH-1:0]         s_axi_b_awaddr,
    input  wire [7:0]                    s_axi_b_awlen,
    input  wire [2:0]                    s_axi_b_awsize,
    input  wire [1:0]                    s_axi_b_awburst,
    input  wire                          s_axi_b_awlock,
    input  wire [3:0]                    s_axi_b_awcache,
    input  wire [2:0]                    s_axi_b_awprot,
    input  wire                          s_axi_b_awvalid,
    output wire                          s_axi_b_awready,
    input  wire [AXI_RAM_DATA_WIDTH-1:0] s_axi_b_wdata,
    input  wire [AXI_RAM_STRB_WIDTH-1:0] s_axi_b_wstrb,
    input  wire                          s_axi_b_wlast,
    input  wire                          s_axi_b_wvalid,
    output wire                          s_axi_b_wready,
    output wire [ID_WIDTH-1:0]           s_axi_b_bid,
    output wire [1:0]                    s_axi_b_bresp,
    output wire                          s_axi_b_bvalid,
    input  wire                          s_axi_b_bready
);  

/*

    // ========================================
    //            MATRIX BUFFER
    // ========================================

    genvar k;
    generate
        for (k = 0; k < NUM_RAM_PARTITIONS; k = k + 1) begin : ram_gen
            
            axi_ram #(
                .DATA_WIDTH(AXI_RAM_DATA_WIDTH),
                .ADDR_WIDTH(AXI_RAM_ADDR_WIDTH),
                .STRB_WIDTH(AXI_RAM_STRB_WIDTH),
                .ID_WIDTH  (AXI_RAM_ID_WIDTH),
                .NUM_WORDS (AXI_RAM_WORDS_PER_PARTITION)
            ) axi_ram_inst (
                .clk(clk), .rstn(rstn),
        
                .s_axi_awid   (ram_m_axi_awid   [k]),
                .s_axi_awaddr (ram_m_axi_awaddr [k][AXI_RAM_ADDR_WIDTH-1:0]),
                .s_axi_awlen  (ram_m_axi_awlen  [k]),
                .s_axi_awsize (ram_m_axi_awsize [k]),
                .s_axi_awburst(ram_m_axi_awburst[k]),
                .s_axi_awlock (ram_m_axi_awlock [k]),
                .s_axi_awcache(ram_m_axi_awcache[k]),
                .s_axi_awprot (ram_m_axi_awprot [k]),
                .s_axi_awvalid(ram_m_axi_awvalid[k]),
                .s_axi_awready(ram_m_axi_awready[k]),
                
                .s_axi_wdata  (ram_m_axi_wdata  [k]),
                .s_axi_wstrb  (ram_m_axi_wstrb  [k]),
                .s_axi_wlast  (ram_m_axi_wlast  [k]),
                .s_axi_wvalid (ram_m_axi_wvalid [k]),
                .s_axi_wready (ram_m_axi_wready [k]),
                
                .s_axi_bid    (ram_m_axi_bid    [k]),
                .s_axi_bresp  (ram_m_axi_bresp  [k]),
                .s_axi_bvalid (ram_m_axi_bvalid [k]),
                .s_axi_bready (ram_m_axi_bready [k]),
        
                .s_axi_arid   (ram_m_axi_arid   [k]),
                .s_axi_araddr (ram_m_axi_araddr [k][AXI_RAM_ADDR_WIDTH-1:0]),
                .s_axi_arlen  (ram_m_axi_arlen  [k]),
                .s_axi_arsize (ram_m_axi_arsize [k]),
                .s_axi_arburst(ram_m_axi_arburst[k]),
                .s_axi_arlock (ram_m_axi_arlock [k]),
                .s_axi_arcache(ram_m_axi_arcache[k]),
                .s_axi_arprot (ram_m_axi_arprot [k]),
                .s_axi_arvalid(ram_m_axi_arvalid[k]),
                .s_axi_arready(ram_m_axi_arready[k]),
            
                .s_axi_rid    (ram_m_axi_rid    [k]),
                .s_axi_rdata  (ram_m_axi_rdata  [k]),
                .s_axi_rresp  (ram_m_axi_rresp  [k]),
                .s_axi_rlast  (ram_m_axi_rlast  [k]),
                .s_axi_rvalid (ram_m_axi_rvalid [k]),
                .s_axi_rready (ram_m_axi_rready [k])
            );
        end
    endgenerate

    // ========================================
    //       DMA (RD/WR MATRIX BUFFER)
    // ========================================
    
    localparam DMA_LEN_WIDTH = $clog2(BYTES_PER_PARTITION+1);
    localparam DMA_BURST_LEN = 128;
    localparam DMA_TAG_WIDTH = 8;

    localparam AXI_RAM_ADDR_WIDTH  = $clog2(AXI_RAM_WORDS_PER_PARTITION * AXI_RAM_STRB_WIDTH);
    localparam [ADDR_WIDTH-1:0] PARTITION_ALIGN = (1 << AXI_RAM_ADDR_WIDTH);

    wire [ADDR_WIDTH-1:0] dma_desc_addr = AXI_RAM_BASE_ADDR + (partition_index * PARTITION_ALIGN);
    wire [DMA_LEN_WIDTH-1:0] dma_desc_len = BYTES_PER_PARTITION;

    reg  dma_desc_valid;
    wire dma_desc_ready;
    
    wire [7:0] dma_desc_tag  = TAG;
    wire [7:0] dma_desc_id   = TAG;
    wire [7:0] dma_desc_dest = 8'd0;
    wire       dma_desc_user = 1'b0;
        
    wire [7:0] dma_status_tag;
    wire [3:0] dma_status_error;
    wire       dma_status_valid;

    always @(posedge clk) begin
        if (!rstn || !done_rstn)
            dma_desc_valid <= 1'b0;
        else if (!dma_desc_valid)
            dma_desc_valid <= start;
        else if (dma_desc_ready)
            dma_desc_valid <= 1'b0;
    end
        
    axi_dma #(
        .AXI_DATA_WIDTH(AXI_RAM_DATA_WIDTH),
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_STRB_WIDTH(AXI_RAM_STRB_WIDTH),
        .AXI_ID_WIDTH(ID_WIDTH),
        .AXI_MAX_BURST_LEN(DMA_BURST_LEN),
        .AXIS_USER_ENABLE(0),
        .LEN_WIDTH(DMA_LEN_WIDTH),
        .TAG_WIDTH(DMA_TAG_WIDTH)
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
    
        .m_axis_read_data_tdata(m_axis_dmaout_tdata),
        .m_axis_read_data_tkeep(),
        .m_axis_read_data_tvalid(m_axis_dmaout_tvalid),
        .m_axis_read_data_tready(m_axis_dmaout_tready),
        .m_axis_read_data_tlast(m_axis_dmaout_tlast),
        .m_axis_read_data_tid(),
        .m_axis_read_data_tdest(),
        .m_axis_read_data_tuser(),
    
        .m_axi_arid(m_axi_arid),
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arlen(m_axi_arlen),
        .m_axi_arsize(m_axi_arsize),
        .m_axi_arburst(m_axi_arburst),
        .m_axi_arlock(m_axi_arlock),
        .m_axi_arcache(m_axi_arcache),
        .m_axi_arprot(m_axi_arprot),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_arready(m_axi_arready),
        .m_axi_rid(m_axi_rid),
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rresp(m_axi_rresp),
        .m_axi_rlast(m_axi_rlast),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rready(m_axi_rready),
    
        .enable(1'b1)
    );

    // ========================================
    //                  MVM
    // ========================================

    mvm_split #(
        .DATA_WIDTH         (DATA_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .STRB_WIDTH         (STRB_WIDTH),
        .ID_WIDTH           (ID_WIDTH),
        .ELEMENT_WIDTH      (ELEMENT_WIDTH),
        .ELEMENTS_PER_WORD  (ELEMENTS_PER_WORD),
        .ELEMENTS_PER_ROW   (ELEMENTS_PER_ROW),
        .WORDS_PER_ROW      (WORDS_PER_ROW),
        .NUM_ROWS           (NUM_ROWS),
        .NUM_CHANNELS       (NUM_CHANNELS),
        .NUM_RAM_PARTITIONS (NUM_RAM_PARTITIONS),
        .ROWS_PER_CHANNEL   (ROWS_PER_CHANNEL),
        .AXI_RAM_DATA_WIDTH (AXI_RAM_DATA_WIDTH),
        .AXI_RAM_BASE_ADDR  (AXI_RAM_BASE_ADDR)
    ) mvm (
        .clk(clk),
        .rstn(rstn),
        
        // Input channels
        .s_axis_a_tdata (s_axis_a_tdata),
        .s_axis_a_tvalid(s_axis_a_tvalid),
        .s_axis_a_tready(s_axis_a_tready),
        .s_axis_a_tlast (s_axis_a_tlast),
    
        // Output channels
        .m_axis_tdata (m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast (m_axis_tlast),
    
        // AXI slave interface
        .s_axi_b_awid   (s_axi_b_awid),
        .s_axi_b_awaddr (s_axi_b_awaddr),
        .s_axi_b_awlen  (s_axi_b_awlen),
        .s_axi_b_awsize (s_axi_b_awsize),
        .s_axi_b_awburst(s_axi_b_awburst),
        .s_axi_b_awlock (s_axi_b_awlock),
        .s_axi_b_awcache(s_axi_b_awcache),
        .s_axi_b_awprot (s_axi_b_awprot),
        .s_axi_b_awvalid(s_axi_b_awvalid),
        .s_axi_b_awready(s_axi_b_awready),
        .s_axi_b_wdata  (s_axi_b_wdata),
        .s_axi_b_wstrb  (s_axi_b_wstrb),
        .s_axi_b_wlast  (s_axi_b_wlast),
        .s_axi_b_wvalid (s_axi_b_wvalid),
        .s_axi_b_wready (s_axi_b_wready),
        .s_axi_b_bid    (s_axi_b_bid),
        .s_axi_b_bresp  (s_axi_b_bresp),
        .s_axi_b_bvalid (s_axi_b_bvalid),
        .s_axi_b_bready (s_axi_b_bready)
    );

    // ========================================
    //       RD (OLD) VECTOR FROM MVM
    // ========================================
    
    localparam DMA_LEN_WIDTH = $clog2(BYTES_PER_PARTITION+1);
    localparam DMA_BURST_LEN = 128;
    localparam DMA_TAG_WIDTH = 8;

    localparam AXI_RAM_ADDR_WIDTH  = $clog2(AXI_RAM_WORDS_PER_PARTITION * AXI_RAM_STRB_WIDTH);
    localparam [ADDR_WIDTH-1:0] PARTITION_ALIGN = (1 << AXI_RAM_ADDR_WIDTH);

    wire [ADDR_WIDTH-1:0] dma_desc_addr = AXI_RAM_BASE_ADDR + (partition_index * PARTITION_ALIGN);
    wire [DMA_LEN_WIDTH-1:0] dma_desc_len = BYTES_PER_PARTITION;

    reg  dma_desc_valid;
    wire dma_desc_ready;
    
    wire [7:0] dma_desc_tag  = TAG;
    wire [7:0] dma_desc_id   = TAG;
    wire [7:0] dma_desc_dest = 8'd0;
    wire       dma_desc_user = 1'b0;
        
    wire [7:0] dma_status_tag;
    wire [3:0] dma_status_error;
    wire       dma_status_valid;

    always @(posedge clk) begin
        if (!rstn || !done_rstn)
            dma_desc_valid <= 1'b0;
        else if (!dma_desc_valid)
            dma_desc_valid <= start;
        else if (dma_desc_ready)
            dma_desc_valid <= 1'b0;
    end
        
    axi_dma_rd #(
        .AXI_DATA_WIDTH(AXI_RAM_DATA_WIDTH),
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_STRB_WIDTH(AXI_RAM_STRB_WIDTH),
        .AXI_ID_WIDTH(ID_WIDTH),
        .AXI_MAX_BURST_LEN(DMA_BURST_LEN),
        .AXIS_USER_ENABLE(0),
        .LEN_WIDTH(DMA_LEN_WIDTH),
        .TAG_WIDTH(DMA_TAG_WIDTH)
    ) dma_rd (
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
    
        .m_axis_read_data_tdata(m_axis_dmaout_tdata),
        .m_axis_read_data_tkeep(),
        .m_axis_read_data_tvalid(m_axis_dmaout_tvalid),
        .m_axis_read_data_tready(m_axis_dmaout_tready),
        .m_axis_read_data_tlast(m_axis_dmaout_tlast),
        .m_axis_read_data_tid(),
        .m_axis_read_data_tdest(),
        .m_axis_read_data_tuser(),
    
        .m_axi_arid(m_axi_arid),
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arlen(m_axi_arlen),
        .m_axi_arsize(m_axi_arsize),
        .m_axi_arburst(m_axi_arburst),
        .m_axi_arlock(m_axi_arlock),
        .m_axi_arcache(m_axi_arcache),
        .m_axi_arprot(m_axi_arprot),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_arready(m_axi_arready),
        .m_axi_rid(m_axi_rid),
        .m_axi_rdata(m_axi_rdata),
        .m_axi_rresp(m_axi_rresp),
        .m_axi_rlast(m_axi_rlast),
        .m_axi_rvalid(m_axi_rvalid),
        .m_axi_rready(m_axi_rready),
    
        .enable(1'b1)
    );

    // Also need: pow, mult, bram, err, check

*/

endmodule
