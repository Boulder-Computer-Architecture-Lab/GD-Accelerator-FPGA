`timescale 1ns / 1ps

module ile_iter #(
    parameter MAX_CH = 4,

    parameter DATA_WIDTH        = 128,
    parameter ADDR_WIDTH        = 64,
    parameter STRB_WIDTH        = DATA_WIDTH / 8,
    parameter ID_WIDTH          = 8,
    
    parameter ELEMENT_WIDTH     = 16,

    parameter NUM_ROWS          = 168, // 192 w/ padding
    parameter ELEMENTS_PER_ROW  = 168, // 192 w/ padding

    parameter NUM_CHANNELS      = 4,
    parameter NUM_PARTITIONS    = NUM_CHANNELS,

    parameter ELEMENTS_PER_WORD = DATA_WIDTH / ELEMENT_WIDTH,
    parameter WORDS_PER_ROW     = ELEMENTS_PER_ROW / ELEMENTS_PER_WORD,
    parameter ROWS_PER_CHANNEL  = NUM_ROWS / NUM_CHANNELS,
    
    parameter AXI_B_DATA_WIDTH = ELEMENT_WIDTH,
    parameter AXI_B_BASE_ADDR  = 64'h7000_0000,
    parameter AXI_B_STRB_WIDTH = AXI_B_DATA_WIDTH / 8,

    parameter MATRIX_DATA_WIDTH = DATA_WIDTH,
    parameter MATRIX_STRB_WIDTH = MATRIX_DATA_WIDTH / 8,

    parameter MVM_RAM_DATA_WIDTH = 256,
    parameter MVM_RAM_BASE_ADDR  = 64'h8000_0000,
    parameter MVM_RAM_STRB_WIDTH = MVM_RAM_DATA_WIDTH / 8
)(
    input wire clk,
    input wire rstn,
    
    // Input stream arrays
    input  wire [DATA_WIDTH*MAX_CH-1:0] s_axis_a_tdata,
    input  wire [MAX_CH-1:0]            s_axis_a_tvalid,
    output wire [MAX_CH-1:0]            s_axis_a_tready,
    input  wire [MAX_CH-1:0]            s_axis_a_tlast,
    
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
    input  wire [MVM_RAM_DATA_WIDTH-1:0] s_axi_b_wdata,
    input  wire [MVM_RAM_STRB_WIDTH-1:0] s_axi_b_wstrb,
    input  wire                          s_axi_b_wlast,
    input  wire                          s_axi_b_wvalid,
    output wire                          s_axi_b_wready,
    output wire [ID_WIDTH-1:0]           s_axi_b_bid,
    output wire [1:0]                    s_axi_b_bresp,
    output wire                          s_axi_b_bvalid,
    input  wire                          s_axi_b_bready,

    // Output stream arrays
    output wire [ELEMENT_WIDTH*MAX_CH-1:0] m_axis_tdata,
    output wire [MAX_CH-1:0]               m_axis_tvalid,
    input  wire [MAX_CH-1:0]               m_axis_tready,
    output wire [MAX_CH-1:0]               m_axis_tlast
);  

    // ========================================
    //                  MVM
    // ========================================

    wire [DATA_WIDTH*MAX_CH-1:0]    mvm_s_axis_tdata;
    wire [MAX_CH-1:0]               mvm_s_axis_tvalid;
    wire [MAX_CH-1:0]               mvm_s_axis_tready;
    wire [MAX_CH-1:0]               mvm_s_axis_tlast;

    wire [ELEMENT_WIDTH*MAX_CH-1:0] mvm_m_axis_tdata;
    wire [MAX_CH-1:0]               mvm_m_axis_tvalid;
    wire [MAX_CH-1:0]               mvm_m_axis_tready;
    wire [MAX_CH-1:0]               mvm_m_axis_tlast;

    wire [ID_WIDTH-1:0]             mvm_s_axi_awid;
    wire [ADDR_WIDTH-1:0]           mvm_s_axi_awaddr;
    wire [7:0]                      mvm_s_axi_awlen;
    wire [2:0]                      mvm_s_axi_awsize;
    wire [1:0]                      mvm_s_axi_awburst;
    wire                            mvm_s_axi_awlock;
    wire [3:0]                      mvm_s_axi_awcache;
    wire [2:0]                      mvm_s_axi_awprot;
    wire                            mvm_s_axi_awvalid;
    wire                            mvm_s_axi_awready;
    wire [MVM_RAM_DATA_WIDTH-1:0]   mvm_s_axi_wdata;
    wire [MVM_RAM_STRB_WIDTH-1:0]   mvm_s_axi_wstrb;
    wire                            mvm_s_axi_wlast;
    wire                            mvm_s_axi_wvalid;
    wire                            mvm_s_axi_wready;
    wire [ID_WIDTH-1:0]             mvm_s_axi_bid;
    wire [1:0]                      mvm_s_axi_bresp;
    wire                            mvm_s_axi_bvalid;
    wire                            mvm_s_axi_bready;

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
        .NUM_RAM_PARTITIONS (NUM_PARTITIONS),
        .ROWS_PER_CHANNEL   (ROWS_PER_CHANNEL),
        .AXI_RAM_DATA_WIDTH (MVM_RAM_DATA_WIDTH),
        .AXI_RAM_BASE_ADDR  (MVM_RAM_BASE_ADDR)
    ) mvm (
        .clk(clk), .rstn(rstn),
        
        // Input channels
        .s_axis_a_tdata (mvm_s_axis_tdata),
        .s_axis_a_tvalid(mvm_s_axis_tvalid),
        .s_axis_a_tready(mvm_s_axis_tready),
        .s_axis_a_tlast (mvm_s_axis_tlast),
    
        // Output channels
        .m_axis_tdata (mvm_m_axis_tdata),
        .m_axis_tvalid(mvm_m_axis_tvalid),
        .m_axis_tready(mvm_m_axis_tready),
        .m_axis_tlast (mvm_m_axis_tlast),
    
        // AXI slave interface
        .s_axi_b_awid   (mvm_s_axi_awid),
        .s_axi_b_awaddr (mvm_s_axi_awaddr),
        .s_axi_b_awlen  (mvm_s_axi_awlen),
        .s_axi_b_awsize (mvm_s_axi_awsize),
        .s_axi_b_awburst(mvm_s_axi_awburst),
        .s_axi_b_awlock (mvm_s_axi_awlock),
        .s_axi_b_awcache(mvm_s_axi_awcache),
        .s_axi_b_awprot (mvm_s_axi_awprot),
        .s_axi_b_awvalid(mvm_s_axi_awvalid),
        .s_axi_b_awready(mvm_s_axi_awready),
        .s_axi_b_wdata  (mvm_s_axi_wdata),
        .s_axi_b_wstrb  (mvm_s_axi_wstrb),
        .s_axi_b_wlast  (mvm_s_axi_wlast),
        .s_axi_b_wvalid (mvm_s_axi_wvalid),
        .s_axi_b_wready (mvm_s_axi_wready),
        .s_axi_b_bid    (mvm_s_axi_bid),
        .s_axi_b_bresp  (mvm_s_axi_bresp),
        .s_axi_b_bvalid (mvm_s_axi_bvalid),
        .s_axi_b_bready (mvm_s_axi_bready)
    );

    // ========================================
    //            MATRIX BUFFER
    // ========================================
    
    localparam MATRIX_WORDS_PER_ROW       = WORDS_PER_ROW;
    localparam MATRIX_WORDS_PER_PARTITION = MATRIX_WORDS_PER_ROW * ROWS_PER_CHANNEL;
    localparam MATRIX_BYTES_PER_PARTITION = MATRIX_WORDS_PER_PARTITION * MATRIX_STRB_WIDTH;
    localparam MATRIX_ADDR_WIDTH          = $clog2(MATRIX_BYTES_PER_PARTITION);
    localparam MATRIX_ID_WIDTH            = ID_WIDTH;

    localparam MATRIX_DMA_LEN_WIDTH = $clog2(MATRIX_BYTES_PER_PARTITION+1);
    localparam MATRIX_DMA_BURST_LEN = 256;
    localparam MATRIX_DMA_TAG_WIDTH = 8;

    // Indicates next iteration.
    // Generated when vec_in s2mm
    // transfer completes.
    wire start_mvm;

    // M-AXI interface for RAM
    wire [MATRIX_ID_WIDTH-1:0]   ram_m_axi_awid    [MAX_CH-1:0];
    wire [MATRIX_ADDR_WIDTH-1:0] ram_m_axi_awaddr  [MAX_CH-1:0];
    wire [7:0]                   ram_m_axi_awlen   [MAX_CH-1:0];
    wire [2:0]                   ram_m_axi_awsize  [MAX_CH-1:0];
    wire [1:0]                   ram_m_axi_awburst [MAX_CH-1:0];
    wire                         ram_m_axi_awlock  [MAX_CH-1:0];
    wire [3:0]                   ram_m_axi_awcache [MAX_CH-1:0];
    wire [2:0]                   ram_m_axi_awprot  [MAX_CH-1:0];
    wire                         ram_m_axi_awvalid [MAX_CH-1:0];
    wire                         ram_m_axi_awready [MAX_CH-1:0];

    wire [MATRIX_DATA_WIDTH-1:0] ram_m_axi_wdata   [MAX_CH-1:0];
    wire [MATRIX_STRB_WIDTH-1:0] ram_m_axi_wstrb   [MAX_CH-1:0];
    wire                         ram_m_axi_wlast   [MAX_CH-1:0];
    wire                         ram_m_axi_wvalid  [MAX_CH-1:0];
    wire                         ram_m_axi_wready  [MAX_CH-1:0];

    wire [MATRIX_ID_WIDTH-1:0]   ram_m_axi_bid     [MAX_CH-1:0];
    wire [1:0]                   ram_m_axi_bresp   [MAX_CH-1:0];
    wire                         ram_m_axi_bvalid  [MAX_CH-1:0];
    wire                         ram_m_axi_bready  [MAX_CH-1:0];
    
    wire [MATRIX_ID_WIDTH-1:0]   ram_m_axi_arid    [MAX_CH-1:0];
    wire [ADDR_WIDTH-1:0]        ram_m_axi_araddr  [MAX_CH-1:0];
    wire [7:0]                   ram_m_axi_arlen   [MAX_CH-1:0];
    wire [2:0]                   ram_m_axi_arsize  [MAX_CH-1:0];
    wire [1:0]                   ram_m_axi_arburst [MAX_CH-1:0];
    wire                         ram_m_axi_arlock  [MAX_CH-1:0];
    wire [3:0]                   ram_m_axi_arcache [MAX_CH-1:0];
    wire [2:0]                   ram_m_axi_arprot  [MAX_CH-1:0];
    wire                         ram_m_axi_arvalid [MAX_CH-1:0];
    wire                         ram_m_axi_arready [MAX_CH-1:0];

    wire [MATRIX_ID_WIDTH-1:0]   ram_m_axi_rid     [MAX_CH-1:0];
    wire [MATRIX_DATA_WIDTH-1:0] ram_m_axi_rdata   [MAX_CH-1:0];
    wire [1:0]                   ram_m_axi_rresp   [MAX_CH-1:0];
    wire                         ram_m_axi_rlast   [MAX_CH-1:0];
    wire                         ram_m_axi_rvalid  [MAX_CH-1:0];
    wire                         ram_m_axi_rready  [MAX_CH-1:0];

    // DMA desc
    reg  [MATRIX_ADDR_WIDTH-1:0]    dma_wr_desc_addr  [MAX_CH-1:0];
    reg  [MATRIX_DMA_LEN_WIDTH-1:0] dma_wr_desc_len   [MAX_CH-1:0];
    reg  [MATRIX_DMA_TAG_WIDTH-1:0] dma_wr_desc_tag   [MAX_CH-1:0];
    reg                             dma_wr_desc_valid [MAX_CH-1:0];
    wire                            dma_wr_desc_ready [MAX_CH-1:0];
    
    reg  [MATRIX_ADDR_WIDTH-1:0]    dma_rd_desc_addr  [MAX_CH-1:0];
    reg  [MATRIX_DMA_LEN_WIDTH-1:0] dma_rd_desc_len   [MAX_CH-1:0];
    reg  [MATRIX_DMA_TAG_WIDTH-1:0] dma_rd_desc_tag   [MAX_CH-1:0];
    reg                             dma_rd_desc_valid [MAX_CH-1:0];
    wire                            dma_rd_desc_ready [MAX_CH-1:0];
    
    wire dma_wr_status_valid [MAX_CH-1:0];
    wire dma_rd_status_valid [MAX_CH-1:0];

    integer i;
    always @(posedge clk) begin
        if (!rstn) begin
            for (i = 0; i < MAX_CH; i = i + 1) begin
                // Configure write descriptor
                dma_wr_desc_addr[i] <= {MATRIX_ADDR_WIDTH{1'b0}};
                dma_wr_desc_len [i] <= MATRIX_BYTES_PER_PARTITION;
                dma_wr_desc_tag [i] <= i[MATRIX_DMA_TAG_WIDTH-1:0];
    
                // Configure read descriptor
                dma_rd_desc_addr[i] <= {MATRIX_ADDR_WIDTH{1'b0}};
                dma_rd_desc_len [i] <= MATRIX_BYTES_PER_PARTITION;
                dma_rd_desc_tag [i] <= i[MATRIX_DMA_TAG_WIDTH-1:0];
            end
        end
    end

    genvar k;
    generate
        for (k = 0; k < MAX_CH; k = k + 1) begin : matrix_ram_gen
            
            axi_ram #(
                .DATA_WIDTH(MATRIX_DATA_WIDTH),
                .ADDR_WIDTH(MATRIX_ADDR_WIDTH),
                .STRB_WIDTH(MATRIX_STRB_WIDTH),
                .ID_WIDTH  (MATRIX_ID_WIDTH  ),
                .NUM_WORDS (MATRIX_WORDS_PER_PARTITION)
            ) axi_ram_inst (
                .clk(clk), .rstn(rstn),
        
                .s_axi_awid   (ram_m_axi_awid   [k]),
                .s_axi_awaddr (ram_m_axi_awaddr [k][MATRIX_ADDR_WIDTH-1:0]),
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
                .s_axi_araddr (ram_m_axi_araddr [k][MATRIX_ADDR_WIDTH-1:0]),
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
            
            always @(posedge clk) begin
                if (!rstn) begin
                    dma_wr_desc_valid[k] <= 1'b1;
                    dma_rd_desc_valid[k] <= 1'b0;
                end else begin
                    // Program write descriptor
                    if      ( dma_wr_desc_valid[k] && dma_wr_desc_ready  [k]) dma_wr_desc_valid[k] <= 1'b0;
                    else if (!dma_wr_desc_valid[k] && dma_wr_status_valid[k]) dma_wr_desc_valid[k] <= 1'b1;

                    // Program read descriptor
                    if      (!dma_rd_desc_valid[k]) dma_rd_desc_valid[k] <= start_mvm;
                    else if ( dma_rd_desc_ready[k]) dma_rd_desc_valid[k] <= 1'b0;
                end
            end

            axi_dma #(
                .AXI_DATA_WIDTH   (MATRIX_DATA_WIDTH),
                .AXI_ADDR_WIDTH   (MATRIX_ADDR_WIDTH),
                .AXI_STRB_WIDTH   (MATRIX_STRB_WIDTH),
                .AXI_ID_WIDTH     (MATRIX_ID_WIDTH),
                .AXI_MAX_BURST_LEN(MATRIX_DMA_BURST_LEN),
                .LEN_WIDTH        (MATRIX_DMA_LEN_WIDTH),
                .TAG_WIDTH        (MATRIX_DMA_TAG_WIDTH),
                .AXIS_USER_ENABLE (0),
                .AXIS_ID_WIDTH    (MATRIX_ID_WIDTH)
            ) dma (
                .clk(clk), .rstn(rstn),

                // Write port: s_axis -> uram
                .s_axis_write_desc_addr (dma_wr_desc_addr [k]),
                .s_axis_write_desc_len  (dma_wr_desc_len  [k]),
                .s_axis_write_desc_tag  (dma_wr_desc_tag  [k]),
                .s_axis_write_desc_valid(dma_wr_desc_valid[k]),
                .s_axis_write_desc_ready(dma_wr_desc_ready[k]),

                .m_axis_write_desc_status_len  (),
                .m_axis_write_desc_status_tag  (),
                .m_axis_write_desc_status_id   (),
                .m_axis_write_desc_status_dest (),
                .m_axis_write_desc_status_user (),
                .m_axis_write_desc_status_error(),
                .m_axis_write_desc_status_valid(dma_wr_status_valid[k]),

                .s_axis_write_data_tdata (s_axis_a_tdata [k*DATA_WIDTH +: DATA_WIDTH]),
                .s_axis_write_data_tkeep ({MATRIX_STRB_WIDTH{1'b1}}),
                .s_axis_write_data_tvalid(s_axis_a_tvalid[k]),
                .s_axis_write_data_tready(s_axis_a_tready[k]),
                .s_axis_write_data_tlast (s_axis_a_tlast [k]),
                .s_axis_write_data_tid   (),
                .s_axis_write_data_tdest (),
                .s_axis_write_data_tuser (),

                .m_axi_awid   (ram_m_axi_awid   [k]),
                .m_axi_awaddr (ram_m_axi_awaddr [k]),
                .m_axi_awlen  (ram_m_axi_awlen  [k]),
                .m_axi_awsize (ram_m_axi_awsize [k]),
                .m_axi_awburst(ram_m_axi_awburst[k]),
                .m_axi_awlock (ram_m_axi_awlock [k]),
                .m_axi_awcache(ram_m_axi_awcache[k]),
                .m_axi_awprot (ram_m_axi_awprot [k]),
                .m_axi_awvalid(ram_m_axi_awvalid[k]),
                .m_axi_awready(ram_m_axi_awready[k]),
                .m_axi_wdata  (ram_m_axi_wdata  [k]),
                .m_axi_wstrb  (ram_m_axi_wstrb  [k]),
                .m_axi_wlast  (ram_m_axi_wlast  [k]),
                .m_axi_wvalid (ram_m_axi_wvalid [k]),
                .m_axi_wready (ram_m_axi_wready [k]),
                .m_axi_bid    (ram_m_axi_bid    [k]),
                .m_axi_bresp  (ram_m_axi_bresp  [k]),
                .m_axi_bvalid (ram_m_axi_bvalid [k]),
                .m_axi_bready (ram_m_axi_bready [k]),
            
                // Read port: uram -> mvm 
                .m_axi_arid   (ram_m_axi_arid   [k]),
                .m_axi_araddr (ram_m_axi_araddr [k]),
                .m_axi_arlen  (ram_m_axi_arlen  [k]),
                .m_axi_arsize (ram_m_axi_arsize [k]),
                .m_axi_arburst(ram_m_axi_arburst[k]),
                .m_axi_arlock (ram_m_axi_arlock [k]),
                .m_axi_arcache(ram_m_axi_arcache[k]),
                .m_axi_arprot (ram_m_axi_arprot [k]),
                .m_axi_arvalid(ram_m_axi_arvalid[k]),
                .m_axi_arready(ram_m_axi_arready[k]),
                .m_axi_rid    (ram_m_axi_rid    [k]),
                .m_axi_rdata  (ram_m_axi_rdata  [k]),
                .m_axi_rresp  (ram_m_axi_rresp  [k]),
                .m_axi_rlast  (ram_m_axi_rlast  [k]),
                .m_axi_rvalid (ram_m_axi_rvalid [k]),
                .m_axi_rready (ram_m_axi_rready [k]),

                .s_axis_read_desc_addr (dma_rd_desc_addr [k]),
                .s_axis_read_desc_len  (dma_rd_desc_len  [k]),
                .s_axis_read_desc_tag  (dma_rd_desc_tag  [k]),
                .s_axis_read_desc_id   ({MATRIX_ID_WIDTH{1'b0}}),
                .s_axis_read_desc_dest (8'b0),
                .s_axis_read_desc_user (1'b0),
                .s_axis_read_desc_valid(dma_rd_desc_valid[k]),
                .s_axis_read_desc_ready(dma_rd_desc_ready[k]),
            
                .m_axis_read_desc_status_tag  (),
                .m_axis_read_desc_status_error(),
                .m_axis_read_desc_status_valid(dma_rd_status_valid[k]),
            
                .m_axis_read_data_tdata (mvm_s_axis_tdata [k*DATA_WIDTH +: DATA_WIDTH]),
                .m_axis_read_data_tkeep (),
                .m_axis_read_data_tvalid(mvm_s_axis_tvalid[k]),
                .m_axis_read_data_tready(mvm_s_axis_tready[k]),
                .m_axis_read_data_tlast (mvm_s_axis_tlast [k]),
                .m_axis_read_data_tid   (),
                .m_axis_read_data_tdest (),
                .m_axis_read_data_tuser (),

                // Ctrl
                .read_enable(1'b1),
                .write_enable(1'b1),
                .write_abort(1'b0)
            );

        end
    endgenerate

    // ========================================
    //          AXI_B SHARED BUFFER
    // ========================================

    localparam AXI_B_NUM_REGIONS      = 3;
    localparam AXI_B_WORDS_PER_REGION = ELEMENTS_PER_ROW;
    localparam AXI_B_BYTES_PER_REGION = AXI_B_WORDS_PER_REGION * AXI_B_STRB_WIDTH;
    localparam AXI_B_TOTAL_WORDS      = AXI_B_WORDS_PER_REGION * AXI_B_NUM_REGIONS;
    localparam AXI_B_TOTAL_BYTES      = AXI_B_BYTES_PER_REGION * AXI_B_NUM_REGIONS;
    localparam AXI_B_ADDR_WIDTH       = $clog2(AXI_B_TOTAL_BYTES);

    wire [ADDR_WIDTH-1:0]       axi_b_ram_awaddr;
    wire [7:0]                  axi_b_ram_awlen;
    wire [2:0]                  axi_b_ram_awsize;
    wire [1:0]                  axi_b_ram_awburst;
    wire                        axi_b_ram_awlock;
    wire [3:0]                  axi_b_ram_awregion;
    wire [3:0]                  axi_b_ram_awqos;
    wire [3:0]                  axi_b_ram_awcache;
    wire [2:0]                  axi_b_ram_awprot;
    wire                        axi_b_ram_awvalid;
    wire                        axi_b_ram_awready;

    wire [AXI_B_DATA_WIDTH-1:0] axi_b_ram_wdata;
    wire [AXI_B_STRB_WIDTH-1:0] axi_b_ram_wstrb;
    wire                        axi_b_ram_wlast;
    wire                        axi_b_ram_wvalid;
    wire                        axi_b_ram_wready;

    wire [1:0]                  axi_b_ram_bresp;
    wire                        axi_b_ram_bvalid;
    wire                        axi_b_ram_bready;

    wire [ID_WIDTH-1:0]         axi_b_ram_arid;
    wire [AXI_B_ADDR_WIDTH-1:0] axi_b_ram_araddr;
    wire [7:0]                  axi_b_ram_arlen;
    wire [2:0]                  axi_b_ram_arsize;
    wire [1:0]                  axi_b_ram_arburst;
    wire                        axi_b_ram_arlock;
    wire [3:0]                  axi_b_ram_arcache;
    wire [2:0]                  axi_b_ram_arprot;
    wire                        axi_b_ram_arvalid;
    wire                        axi_b_ram_arready;

    wire [ID_WIDTH-1:0]         axi_b_ram_rid;
    wire [AXI_B_DATA_WIDTH-1:0] axi_b_ram_rdata;
    wire [1:0]                  axi_b_ram_rresp;
    wire                        axi_b_ram_rlast;
    wire                        axi_b_ram_rvalid;
    wire                        axi_b_ram_rready;

    generate
        if (ELEMENT_WIDTH == 64) begin : axi_wconv64_gen
            axi_wconv256to64 axi_wconv_inst (
                .s_axi_aclk   (clk),
                .s_axi_aresetn(rstn),

                .s_axi_awid    (s_axi_b_awid   ),
                .s_axi_awaddr  (s_axi_b_awaddr ),
                .s_axi_awlen   (s_axi_b_awlen  ),
                .s_axi_awsize  (s_axi_b_awsize ),
                .s_axi_awburst (s_axi_b_awburst),
                .s_axi_awlock  (s_axi_b_awlock ),
                .s_axi_awcache (s_axi_b_awcache),
                .s_axi_awprot  (s_axi_b_awprot ),
                .s_axi_awregion(4'b0),
                .s_axi_awqos   (4'b0),
                .s_axi_awvalid (s_axi_b_awvalid),
                .s_axi_awready (s_axi_b_awready),

                .s_axi_wdata   (s_axi_b_wdata ),
                .s_axi_wstrb   (s_axi_b_wstrb ),
                .s_axi_wlast   (s_axi_b_wlast ),
                .s_axi_wvalid  (s_axi_b_wvalid),
                .s_axi_wready  (s_axi_b_wready),

                .s_axi_bid     (s_axi_b_bid   ),
                .s_axi_bresp   (s_axi_b_bresp ),
                .s_axi_bvalid  (s_axi_b_bvalid),
                .s_axi_bready  (s_axi_b_bready),

                .m_axi_awaddr  (axi_b_ram_awaddr  ),
                .m_axi_awlen   (axi_b_ram_awlen   ),
                .m_axi_awsize  (axi_b_ram_awsize  ),
                .m_axi_awburst (axi_b_ram_awburst ),
                .m_axi_awlock  (axi_b_ram_awlock  ),
                .m_axi_awcache (axi_b_ram_awcache ),
                .m_axi_awprot  (axi_b_ram_awprot  ),
                .m_axi_awregion(axi_b_ram_awregion),
                .m_axi_awqos   (axi_b_ram_awqos   ),
                .m_axi_awvalid (axi_b_ram_awvalid ),
                .m_axi_awready (axi_b_ram_awready ),

                .m_axi_wdata   (axi_b_ram_wdata ),
                .m_axi_wstrb   (axi_b_ram_wstrb ),
                .m_axi_wlast   (axi_b_ram_wlast ),
                .m_axi_wvalid  (axi_b_ram_wvalid),
                .m_axi_wready  (axi_b_ram_wready),

                .m_axi_bresp   (axi_b_ram_bresp ),
                .m_axi_bvalid  (axi_b_ram_bvalid),
                .m_axi_bready  (axi_b_ram_bready)
            );
        end else if (ELEMENT_WIDTH == 32) begin : axi_wconv32_gen
            axi_wconv256to32 wconv_inst (
                .s_axi_aclk   (clk),
                .s_axi_aresetn(rstn),

                .s_axi_awid    (s_axi_b_awid   ),
                .s_axi_awaddr  (s_axi_b_awaddr ),
                .s_axi_awlen   (s_axi_b_awlen  ),
                .s_axi_awsize  (s_axi_b_awsize ),
                .s_axi_awburst (s_axi_b_awburst),
                .s_axi_awlock  (s_axi_b_awlock ),
                .s_axi_awcache (s_axi_b_awcache),
                .s_axi_awprot  (s_axi_b_awprot ),
                .s_axi_awregion(4'b0),
                .s_axi_awqos   (4'b0),
                .s_axi_awvalid (s_axi_b_awvalid),
                .s_axi_awready (s_axi_b_awready),

                .s_axi_wdata   (s_axi_b_wdata ),
                .s_axi_wstrb   (s_axi_b_wstrb ),
                .s_axi_wlast   (s_axi_b_wlast ),
                .s_axi_wvalid  (s_axi_b_wvalid),
                .s_axi_wready  (s_axi_b_wready),

                .s_axi_bid     (s_axi_b_bid   ),
                .s_axi_bresp   (s_axi_b_bresp ),
                .s_axi_bvalid  (s_axi_b_bvalid),
                .s_axi_bready  (s_axi_b_bready),

                .m_axi_awaddr  (axi_b_ram_awaddr  ),
                .m_axi_awlen   (axi_b_ram_awlen   ),
                .m_axi_awsize  (axi_b_ram_awsize  ),
                .m_axi_awburst (axi_b_ram_awburst ),
                .m_axi_awlock  (axi_b_ram_awlock  ),
                .m_axi_awcache (axi_b_ram_awcache ),
                .m_axi_awprot  (axi_b_ram_awprot  ),
                .m_axi_awregion(axi_b_ram_awregion),
                .m_axi_awqos   (axi_b_ram_awqos   ),
                .m_axi_awvalid (axi_b_ram_awvalid ),
                .m_axi_awready (axi_b_ram_awready ),

                .m_axi_wdata   (axi_b_ram_wdata ),
                .m_axi_wstrb   (axi_b_ram_wstrb ),
                .m_axi_wlast   (axi_b_ram_wlast ),
                .m_axi_wvalid  (axi_b_ram_wvalid),
                .m_axi_wready  (axi_b_ram_wready),

                .m_axi_bresp   (axi_b_ram_bresp ),
                .m_axi_bvalid  (axi_b_ram_bvalid),
                .m_axi_bready  (axi_b_ram_bready)
            );
        end else if (ELEMENT_WIDTH == 16) begin : axi_wconv16_gen
            axi_wconv256to16 wconv_inst (
                .s_axi_aclk   (clk),
                .s_axi_aresetn(rstn),

                .s_axi_awid    (s_axi_b_awid   ),
                .s_axi_awaddr  (s_axi_b_awaddr ),
                .s_axi_awlen   (s_axi_b_awlen  ),
                .s_axi_awsize  (s_axi_b_awsize ),
                .s_axi_awburst (s_axi_b_awburst),
                .s_axi_awlock  (s_axi_b_awlock ),
                .s_axi_awcache (s_axi_b_awcache),
                .s_axi_awprot  (s_axi_b_awprot ),
                .s_axi_awregion(4'b0),
                .s_axi_awqos   (4'b0),
                .s_axi_awvalid (s_axi_b_awvalid),
                .s_axi_awready (s_axi_b_awready),

                .s_axi_wdata   (s_axi_b_wdata ),
                .s_axi_wstrb   (s_axi_b_wstrb ),
                .s_axi_wlast   (s_axi_b_wlast ),
                .s_axi_wvalid  (s_axi_b_wvalid),
                .s_axi_wready  (s_axi_b_wready),

                .s_axi_bid     (s_axi_b_bid   ),
                .s_axi_bresp   (s_axi_b_bresp ),
                .s_axi_bvalid  (s_axi_b_bvalid),
                .s_axi_bready  (s_axi_b_bready),

                .m_axi_awaddr  (axi_b_ram_awaddr  ),
                .m_axi_awlen   (axi_b_ram_awlen   ),
                .m_axi_awsize  (axi_b_ram_awsize  ),
                .m_axi_awburst (axi_b_ram_awburst ),
                .m_axi_awlock  (axi_b_ram_awlock  ),
                .m_axi_awcache (axi_b_ram_awcache ),
                .m_axi_awprot  (axi_b_ram_awprot  ),
                .m_axi_awregion(axi_b_ram_awregion),
                .m_axi_awqos   (axi_b_ram_awqos   ),
                .m_axi_awvalid (axi_b_ram_awvalid ),
                .m_axi_awready (axi_b_ram_awready ),

                .m_axi_wdata   (axi_b_ram_wdata ),
                .m_axi_wstrb   (axi_b_ram_wstrb ),
                .m_axi_wlast   (axi_b_ram_wlast ),
                .m_axi_wvalid  (axi_b_ram_wvalid),
                .m_axi_wready  (axi_b_ram_wready),

                .m_axi_bresp   (axi_b_ram_bresp ),
                .m_axi_bvalid  (axi_b_ram_bvalid),
                .m_axi_bready  (axi_b_ram_bready)
            );
        end
    endgenerate 

    axi_ram #(
        .DATA_WIDTH(AXI_B_DATA_WIDTH),
        .ADDR_WIDTH(AXI_B_ADDR_WIDTH),
        .STRB_WIDTH(AXI_B_STRB_WIDTH),
        .ID_WIDTH  (ID_WIDTH),
        .NUM_WORDS (AXI_B_TOTAL_WORDS)
    ) axi_b_ram_inst (
        .clk(clk),
        .rstn(rstn),

        .s_axi_awid   ({ID_WIDTH{1'b0}}), // wconv doesn't drive ID signals
        .s_axi_awaddr (axi_b_ram_awaddr[AXI_B_ADDR_WIDTH-1:0]),
        .s_axi_awlen  (axi_b_ram_awlen),
        .s_axi_awsize (axi_b_ram_awsize),
        .s_axi_awburst(axi_b_ram_awburst),
        .s_axi_awlock (axi_b_ram_awlock),
        .s_axi_awcache(axi_b_ram_awcache),
        .s_axi_awprot (axi_b_ram_awprot),
        .s_axi_awvalid(axi_b_ram_awvalid),
        .s_axi_awready(axi_b_ram_awready),

        .s_axi_wdata  (axi_b_ram_wdata),
        .s_axi_wstrb  (axi_b_ram_wstrb),
        .s_axi_wlast  (axi_b_ram_wlast),
        .s_axi_wvalid (axi_b_ram_wvalid),
        .s_axi_wready (axi_b_ram_wready),

        .s_axi_bid    (),
        .s_axi_bresp  (axi_b_ram_bresp),
        .s_axi_bvalid (axi_b_ram_bvalid),
        .s_axi_bready (axi_b_ram_bready),

        .s_axi_arid   (axi_b_ram_arid),
        .s_axi_araddr (axi_b_ram_araddr),
        .s_axi_arlen  (axi_b_ram_arlen),
        .s_axi_arsize (axi_b_ram_arsize),
        .s_axi_arburst(axi_b_ram_arburst),
        .s_axi_arlock (axi_b_ram_arlock),
        .s_axi_arcache(axi_b_ram_arcache),
        .s_axi_arprot (axi_b_ram_arprot),
        .s_axi_arvalid(axi_b_ram_arvalid),
        .s_axi_arready(axi_b_ram_arready),

        .s_axi_rid    (axi_b_ram_rid),
        .s_axi_rdata  (axi_b_ram_rdata),
        .s_axi_rresp  (axi_b_ram_rresp),
        .s_axi_rlast  (axi_b_ram_rlast),
        .s_axi_rvalid (axi_b_ram_rvalid),
        .s_axi_rready (axi_b_ram_rready)
    );

    // ========================================
    //         SHARED BUFFER OUTPUT
    // ========================================

    // Regions
    localparam REGION_VEC_INIT  = 2'd0; // Holds vec_init
    localparam REGION_OUTER     = 2'd1; // Holds input_integral_outer
    localparam REGION_INNER     = 2'd2; // Holds aa2 * input_uhat_inner

    localparam [AXI_B_ADDR_WIDTH-1:0] VEC_INIT_OFFSET  = REGION_VEC_INIT * AXI_B_BYTES_PER_REGION;
    localparam [AXI_B_ADDR_WIDTH-1:0] VEC_OUTER_OFFSET = REGION_OUTER    * AXI_B_BYTES_PER_REGION;
    localparam [AXI_B_ADDR_WIDTH-1:0] VEC_INNER_OFFSET = REGION_INNER    * AXI_B_BYTES_PER_REGION;

    localparam AXI_B_DMA_LEN_WIDTH = $clog2(AXI_B_BYTES_PER_REGION + 1);
    localparam AXI_B_DMA_BURST_LEN = 256;
    localparam AXI_B_DMA_TAG_WIDTH = 8;

    reg  [1:0] axi_b_region_sel; // driven elsewhere
    reg        start_axi_b_mm2s; // driven elsewhere

    // Descriptor
    wire [AXI_B_ADDR_WIDTH-1:0]    axi_b_rd_desc_addr;
    wire [AXI_B_DMA_LEN_WIDTH-1:0] axi_b_rd_desc_len;
    reg  [AXI_B_DMA_TAG_WIDTH-1:0] axi_b_rd_desc_tag;
    reg                            axi_b_rd_desc_valid;
    wire                           axi_b_rd_desc_ready;
    wire                           axi_b_rd_status_valid;

    assign axi_b_rd_desc_len = AXI_B_BYTES_PER_REGION;
    assign axi_b_rd_desc_addr = (axi_b_region_sel == REGION_VEC_INIT) ? VEC_INIT_OFFSET  :
                                (axi_b_region_sel == REGION_OUTER)    ? VEC_OUTER_OFFSET : VEC_INNER_OFFSET;

    always @(posedge clk) begin
        if (!rstn) begin
            axi_b_rd_desc_valid <= 1'b0;
            axi_b_rd_desc_tag   <= {AXI_B_DMA_TAG_WIDTH{1'b0}};
        end else begin
            // Associate tag with region
            if (start_axi_b_mm2s && !axi_b_rd_desc_valid)
                axi_b_rd_desc_tag <= {{(AXI_B_DMA_TAG_WIDTH-2){1'b0}}, axi_b_region_sel};

            // Program descriptor
            if      (!axi_b_rd_desc_valid) axi_b_rd_desc_valid <= start_axi_b_mm2s;
            else if ( axi_b_rd_desc_ready) axi_b_rd_desc_valid <= 1'b0;
        end
    end

    // Output signals
    wire [AXI_B_DATA_WIDTH-1:0] b_dma_axis_tdata;
    wire                        b_dma_axis_tvalid;
    wire                        b_dma_axis_tready;
    wire                        b_dma_axis_tlast;

    axi_dma_rd #(
        .AXI_DATA_WIDTH(AXI_B_DATA_WIDTH),
        .AXI_ADDR_WIDTH(AXI_B_ADDR_WIDTH),
        .AXI_STRB_WIDTH(AXI_B_STRB_WIDTH),
        .AXI_ID_WIDTH  (ID_WIDTH),
        .AXI_MAX_BURST_LEN(AXI_B_DMA_BURST_LEN),
        .AXIS_USER_ENABLE (0),
        .LEN_WIDTH(AXI_B_DMA_LEN_WIDTH),
        .TAG_WIDTH(AXI_B_DMA_TAG_WIDTH)
    ) dma (
        .clk(clk), .rstn(rstn),
    
        .s_axis_read_desc_addr (axi_b_rd_desc_addr),
        .s_axis_read_desc_len  (axi_b_rd_desc_len),
        .s_axis_read_desc_tag  (axi_b_rd_desc_tag),
        .s_axis_read_desc_id   ({ID_WIDTH{1'b0}}),
        .s_axis_read_desc_dest (8'b0),
        .s_axis_read_desc_user (1'b0),
        .s_axis_read_desc_valid(axi_b_rd_desc_valid),
        .s_axis_read_desc_ready(axi_b_rd_desc_ready),
    
        .m_axis_read_desc_status_tag  (),
        .m_axis_read_desc_status_error(),
        .m_axis_read_desc_status_valid(axi_b_rd_status_valid),
    
        .m_axis_read_data_tdata (b_dma_axis_tdata ),
        .m_axis_read_data_tkeep (),
        .m_axis_read_data_tvalid(b_dma_axis_tvalid),
        .m_axis_read_data_tready(b_dma_axis_tready),
        .m_axis_read_data_tlast (b_dma_axis_tlast ),
        .m_axis_read_data_tid   (),
        .m_axis_read_data_tdest (),
        .m_axis_read_data_tuser (),
    
        .m_axi_arid   (axi_b_ram_arid),
        .m_axi_araddr (axi_b_ram_araddr),
        .m_axi_arlen  (axi_b_ram_arlen),
        .m_axi_arsize (axi_b_ram_arsize),
        .m_axi_arburst(axi_b_ram_arburst),
        .m_axi_arlock (axi_b_ram_arlock),
        .m_axi_arcache(axi_b_ram_arcache),
        .m_axi_arprot (axi_b_ram_arprot),
        .m_axi_arvalid(axi_b_ram_arvalid),
        .m_axi_arready(axi_b_ram_arready),
        .m_axi_rid    (axi_b_ram_rid),
        .m_axi_rdata  (axi_b_ram_rdata),
        .m_axi_rresp  (axi_b_ram_rresp),
        .m_axi_rlast  (axi_b_ram_rlast),
        .m_axi_rvalid (axi_b_ram_rvalid),
        .m_axi_rready (axi_b_ram_rready),
    
        .enable(1'b1)
    );

    // Output routing
    wire [AXI_B_DATA_WIDTH-1:0] vec_init_axis_tdata;
    wire                        vec_init_axis_tvalid;
    wire                        vec_init_axis_tready;
    wire                        vec_init_axis_tlast;

    wire [AXI_B_DATA_WIDTH-1:0] uhat_inner_axis_tdata;
    wire                        uhat_inner_axis_tvalid;
    wire                        uhat_inner_axis_tready;
    wire                        uhat_inner_axis_tlast;

    wire [AXI_B_DATA_WIDTH-1:0] int_outer_axis_tdata;
    wire                        int_outer_axis_tvalid;
    wire                        int_outer_axis_tready;
    wire                        int_outer_axis_tlast;

    assign vec_init_axis_tdata  = b_dma_axis_tdata;
    assign vec_init_axis_tvalid = (axi_b_region_sel == REGION_VEC_INIT) ? b_dma_axis_tvalid : 1'b0;
    assign vec_init_axis_tlast  = b_dma_axis_tlast;
    
    assign int_outer_axis_tdata  = b_dma_axis_tdata;
    assign int_outer_axis_tvalid = (axi_b_region_sel == REGION_OUTER) ? b_dma_axis_tvalid : 1'b0;
    assign int_outer_axis_tlast  = b_dma_axis_tlast;
    
    assign uhat_inner_axis_tdata  = b_dma_axis_tdata;
    assign uhat_inner_axis_tvalid = (axi_b_region_sel == REGION_INNER) ? b_dma_axis_tvalid : 1'b0;
    assign uhat_inner_axis_tlast  = b_dma_axis_tlast;
    
    assign b_dma_axis_tready =
        (axi_b_region_sel == REGION_VEC_INIT) ? vec_init_axis_tready   :
        (axi_b_region_sel == REGION_OUTER)    ? int_outer_axis_tready : uhat_inner_axis_tready;

    // ========================================
    //               CONTROLLER
    // ========================================

    wire [ELEMENT_WIDTH-1:0] vec_next_axis_tdata;
    wire                     vec_next_axis_tvalid;
    wire                     vec_next_axis_tready;
    wire                     vec_next_axis_tlast;

    wire [ELEMENT_WIDTH-1:0] err_axis_tdata;
    wire                     err_axis_tvalid;
    wire                     err_axis_tready;

    wire [ELEMENT_WIDTH-1:0] vec_in_axis_tdata;
    wire                     vec_in_axis_tvalid;
    wire                     vec_in_axis_tready;
    wire                     vec_in_axis_tlast;

    wire [ELEMENT_WIDTH-1:0] vec_result_axis_tdata;
    wire                     vec_result_axis_tvalid;
    wire                     vec_result_axis_tready;
    wire                     vec_result_axis_tlast;

    check_convergence #(
        .DATA_WIDTH(ELEMENT_WIDTH)
    ) chk_inst (
        .clk(clk), .rstn(rstn),

        // Initial guess
        .vec_init_axis_tdata (vec_init_axis_tdata ),
        .vec_init_axis_tvalid(vec_init_axis_tvalid),
        .vec_init_axis_tready(vec_init_axis_tready),
        .vec_init_axis_tlast (vec_init_axis_tlast ),

        // This iteration output
        .vec_next_axis_tdata (vec_next_axis_tdata),
        .vec_next_axis_tvalid(vec_next_axis_tvalid),
        .vec_next_axis_tready(vec_next_axis_tready),
        .vec_next_axis_tlast (vec_next_axis_tlast),

        // This iteration error
        .err_axis_tdata (err_axis_tdata),
        .err_axis_tvalid(err_axis_tvalid),
        .err_axis_tready(err_axis_tready),

        // Next iteration input
        .vec_in_axis_tdata (vec_in_axis_tdata),
        .vec_in_axis_tvalid(vec_in_axis_tvalid),
        .vec_in_axis_tready(vec_in_axis_tready),
        .vec_in_axis_tlast (vec_in_axis_tlast),
        
        // Result
        .vec_result_axis_tdata (vec_result_axis_tdata),
        .vec_result_axis_tvalid(vec_result_axis_tvalid),
        .vec_result_axis_tready(vec_result_axis_tready),
        .vec_result_axis_tlast (vec_result_axis_tlast)
    );

    // ========================================
    //           FROM VEC_IN TO MVM
    // ========================================

    localparam I_EXP64 = 64'h0000_0000; // TODO: get real value
    localparam I_EXP32 = 32'h0000_0000; // TODO: get real value
    localparam I_EXP16 = 16'h0000_0000; // TODO: get real value

    wire [ELEMENT_WIDTH-1:0] i_exp_tdata;   
    wire                     i_exp_tvalid;
    wire                     i_exp_tready;

    wire [ELEMENT_WIDTH-1:0] pow0_axis_tdata;
    wire                     pow0_axis_tvalid;
    wire                     pow0_axis_tready;
    wire                     pow0_axis_tlast;

    generate
        if          (ELEMENT_WIDTH == 64) begin : exp64 assign i_exp_tdata = I_EXP64;
        end else if (ELEMENT_WIDTH == 32) begin : exp32 assign i_exp_tdata = I_EXP32;
        end else if (ELEMENT_WIDTH == 16) begin : exp16 assign i_exp_tdata = I_EXP16;
        end
    endgenerate

    assign i_exp_tvalid = vec_in_axis_tvalid;

    pow #(
        .DATA_WIDTH(ELEMENT_WIDTH)
    ) pow_inst0 (
        .clk(clk), .rstn(rstn),

        // base
        .s_axis_1_tdata (vec_in_axis_tdata),
        .s_axis_1_tvalid(vec_in_axis_tvalid),
        .s_axis_1_tready(vec_in_axis_tready),
        .s_axis_1_tlast (vec_in_axis_tlast),

        // exp
        .s_axis_2_tdata (i_exp_tdata),
        .s_axis_2_tvalid(i_exp_tvalid),
        .s_axis_2_tready(i_exp_tready),
        
        // result 
        .m_axis_tdata (pow0_axis_tdata),
        .m_axis_tvalid(pow0_axis_tvalid),
        .m_axis_tready(pow0_axis_tready),
        .m_axis_tlast (pow0_axis_tlast)
    );

    wire [ELEMENT_WIDTH-1:0] mult0_axis_tdata;
    wire                     mult0_axis_tvalid;
    wire                     mult0_axis_tready;
    wire                     mult0_axis_tlast;

    generate
        if (ELEMENT_WIDTH == 64) begin : mult64_gen
            fp64_mult mult_inst0 (
                .aclk(clk), .aresetn(rstn),

                .s_axis_a_tdata(pow0_axis_tdata),
                .s_axis_a_tvalid(pow0_axis_tvalid),
                .s_axis_a_tready(pow0_axis_tready),
                .s_axis_a_tlast(pow0_axis_tlast),

                .s_axis_b_tdata (int_outer_axis_tdata),
                .s_axis_b_tvalid(int_outer_axis_tvalid),
                .s_axis_b_tready(int_outer_axis_tready),

                .m_axis_result_tdata (mult0_axis_tdata),
                .m_axis_result_tvalid(mult0_axis_tvalid),
                .m_axis_result_tready(mult0_axis_tready),
                .m_axis_result_tlast (mult0_axis_tlast)
            );
        end else if (ELEMENT_WIDTH == 32) begin: mult32_gen
            fp32_mult mult_inst0 (
                .aclk(clk), .aresetn(rstn),

                .s_axis_a_tdata(pow0_axis_tdata),
                .s_axis_a_tvalid(pow0_axis_tvalid),
                .s_axis_a_tready(pow0_axis_tready),
                .s_axis_a_tlast(pow0_axis_tlast),

                .s_axis_b_tdata (int_outer_axis_tdata),
                .s_axis_b_tvalid(int_outer_axis_tvalid),
                .s_axis_b_tready(int_outer_axis_tready),

                .m_axis_result_tdata (mult0_axis_tdata),
                .m_axis_result_tvalid(mult0_axis_tvalid),
                .m_axis_result_tready(mult0_axis_tready),
                .m_axis_result_tlast (mult0_axis_tlast)
            );
        end else if (ELEMENT_WIDTH == 16) begin: mult16_gen
            fp16_mult mult_inst0 (
                .aclk(clk), .aresetn(rstn),

                .s_axis_a_tdata(pow0_axis_tdata),
                .s_axis_a_tvalid(pow0_axis_tvalid),
                .s_axis_a_tready(pow0_axis_tready),
                .s_axis_a_tlast(pow0_axis_tlast),

                .s_axis_b_tdata (int_outer_axis_tdata),
                .s_axis_b_tvalid(int_outer_axis_tvalid),
                .s_axis_b_tready(int_outer_axis_tready),

                .m_axis_result_tdata (mult0_axis_tdata),
                .m_axis_result_tvalid(mult0_axis_tvalid),
                .m_axis_result_tready(mult0_axis_tready),
                .m_axis_result_tlast (mult0_axis_tlast)
            );
        end
    endgenerate

    // ELEMENT_WIDTH -> MVM_RAM_DATA_WIDTH
    wire [MVM_RAM_DATA_WIDTH-1:0] wconv_axis_tdata;
    wire                          wconv_axis_tvalid;
    wire                          wconv_axis_tready;
    wire                          wconv_axis_tlast;

    generate
        if (ELEMENT_WIDTH == 64) begin: wconv64_gen
            axis_wconv64to256 wconv_inst (
                .aclk(clk), .aresetn(rstn),

                .s_axis_tdata (mult0_axis_tdata),
                .s_axis_tvalid(mult0_axis_tvalid),
                .s_axis_tready(mult0_axis_tready),
                .s_axis_tlast (mult0_axis_tlast),

                .m_axis_tdata (wconv_axis_tdata),
                .m_axis_tvalid(wconv_axis_tvalid),
                .m_axis_tready(wconv_axis_tready),
                .m_axis_tlast (wconv_axis_tlast)
            );
        end else if (ELEMENT_WIDTH == 32) begin: wconv32_gen
            axis_wconv32to256 wconv_inst (
                .aclk(clk), .aresetn(rstn),

                .s_axis_tdata (mult0_axis_tdata),
                .s_axis_tvalid(mult0_axis_tvalid),
                .s_axis_tready(mult0_axis_tready),
                .s_axis_tlast (mult0_axis_tlast),

                .m_axis_tdata (wconv_axis_tdata),
                .m_axis_tvalid(wconv_axis_tvalid),
                .m_axis_tready(wconv_axis_tready),
                .m_axis_tlast (wconv_axis_tlast)
            );
        end else if (ELEMENT_WIDTH == 16) begin: wconv16_gen
            axis_wconv16to256 wconv_inst (
                .aclk(clk), .aresetn(rstn),

                .s_axis_tdata (mult0_axis_tdata),
                .s_axis_tvalid(mult0_axis_tvalid),
                .s_axis_tready(mult0_axis_tready),
                .s_axis_tlast (mult0_axis_tlast),

                .m_axis_tdata (wconv_axis_tdata),
                .m_axis_tvalid(wconv_axis_tvalid),
                .m_axis_tready(wconv_axis_tready),
                .m_axis_tlast (wconv_axis_tlast)
            );
        end
    endgenerate 

    // Separate into NUM_PARTITIONS transfers for address alignment
    localparam VEC_IN_ELEMENTS_PER_WORD = MVM_RAM_DATA_WIDTH / ELEMENT_WIDTH;
    localparam VEC_IN_WORDS_PER_ROW     = ELEMENTS_PER_ROW / VEC_IN_ELEMENTS_PER_WORD;
    localparam VEC_IN_WORDS_PER_PART    = VEC_IN_WORDS_PER_ROW / NUM_PARTITIONS;
    localparam VEC_IN_BYTES_PER_PART    = VEC_IN_WORDS_PER_PART * MVM_RAM_STRB_WIDTH;
    localparam VEC_IN_ADDR_WIDTH        = $clog2(VEC_IN_BYTES_PER_PART);

    localparam [ADDR_WIDTH-1:0] VEC_IN_REGION_STRIDE = (1 << VEC_IN_ADDR_WIDTH);

    localparam VEC_IN_DMA_LEN_WIDTH  = $clog2(VEC_IN_BYTES_PER_PART + 1);
    localparam VEC_IN_DMA_BURST_LEN  = 256;
    localparam VEC_IN_DMA_TAG_WIDTH  = 8;
    localparam VEC_IN_PART_IDX_WIDTH = $clog2(NUM_PARTITIONS);

    reg  [ADDR_WIDTH-1:0]            vec_in_desc_addr;
    reg  [VEC_IN_DMA_LEN_WIDTH-1:0]  vec_in_desc_len;
    reg  [VEC_IN_DMA_TAG_WIDTH-1:0]  vec_in_desc_tag;
    reg                              vec_in_desc_valid;
    wire                             vec_in_desc_ready;

    wire                             vec_in_status_valid;
    reg  [VEC_IN_PART_IDX_WIDTH-1:0] vec_in_part_idx;

    wire                             start_vec_in_dma; // driven elsewhere
    reg                              vec_in_active;

    always @(posedge clk) begin
        if (!rstn) begin
            vec_in_desc_valid <= 1'b0;
            vec_in_desc_addr  <= {ADDR_WIDTH{1'b0}};
            vec_in_desc_len   <= VEC_IN_BYTES_PER_PART;
            vec_in_desc_tag   <= {VEC_IN_DMA_TAG_WIDTH{1'b0}};
            vec_in_part_idx   <= {VEC_IN_PART_IDX_WIDTH{1'b0}};
            vec_in_active     <= 1'b0;
        end else begin
            // launch whole 4-part write sequence from elsewhere
            if (start_vec_in_dma && !vec_in_active) begin
                vec_in_active   <= 1'b1;
                vec_in_part_idx <= 0;

                vec_in_desc_addr  <= MVM_RAM_BASE_ADDR;
                vec_in_desc_len   <= VEC_IN_BYTES_PER_PART;
                vec_in_desc_tag   <= 0;
                vec_in_desc_valid <= 1'b1;
            end

            // descriptor handshake
            if (vec_in_desc_valid && vec_in_desc_ready)
                vec_in_desc_valid <= 1'b0;
    
            // after one partition write completes, launch next one
            if (vec_in_active && vec_in_status_valid) begin
                if (vec_in_part_idx == NUM_PARTITIONS-1) begin
                    vec_in_active <= 1'b0;
                end else begin
                    vec_in_part_idx <= vec_in_part_idx + 1'b1;
    
                    vec_in_desc_addr  <= MVM_RAM_BASE_ADDR + ((vec_in_part_idx + 1'b1) * VEC_IN_REGION_STRIDE);
                    vec_in_desc_len   <= VEC_IN_BYTES_PER_PART;
                    vec_in_desc_tag   <= vec_in_part_idx + 1'b1;
                    vec_in_desc_valid <= 1'b1;
                end
            end
        end
    end

    axi_dma_wr #(
        .AXI_DATA_WIDTH(MVM_RAM_DATA_WIDTH),
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_STRB_WIDTH(MVM_RAM_STRB_WIDTH),
        .AXI_ID_WIDTH  (ID_WIDTH),
        .AXI_MAX_BURST_LEN(VEC_IN_DMA_BURST_LEN),
        .AXIS_LAST_ENABLE (0), // tlast only asserted on the last of NUM_PARTITIONS transfers
        .AXIS_USER_ENABLE (0),
        .LEN_WIDTH(VEC_IN_DMA_LEN_WIDTH),
        .TAG_WIDTH(VEC_IN_DMA_TAG_WIDTH)
    ) vec_in_dma (
        .clk(clk), .rstn(rstn),
    
        .s_axis_write_desc_addr (vec_in_desc_addr ),
        .s_axis_write_desc_len  (vec_in_desc_len  ),
        .s_axis_write_desc_tag  (vec_in_desc_tag  ),
        .s_axis_write_desc_valid(vec_in_desc_valid),
        .s_axis_write_desc_ready(vec_in_desc_ready),
    
        .m_axis_write_desc_status_len  (),
        .m_axis_write_desc_status_tag  (),
        .m_axis_write_desc_status_id   (),
        .m_axis_write_desc_status_dest (),
        .m_axis_write_desc_status_user (),
        .m_axis_write_desc_status_error(),
        .m_axis_write_desc_status_valid(vec_in_status_valid),
    
        .s_axis_write_data_tdata (wconv_axis_tdata),
        .s_axis_write_data_tkeep ({MVM_RAM_STRB_WIDTH{1'b1}}),
        .s_axis_write_data_tvalid(wconv_axis_tvalid),
        .s_axis_write_data_tready(wconv_axis_tready),
        .s_axis_write_data_tlast (wconv_axis_tlast),
        .s_axis_write_data_tid   ({ID_WIDTH{1'b0}}),
        .s_axis_write_data_tdest (8'b0),
        .s_axis_write_data_tuser (1'b0),
    
        .m_axi_awid   (mvm_s_axi_awid   ),
        .m_axi_awaddr (mvm_s_axi_awaddr ),
        .m_axi_awlen  (mvm_s_axi_awlen  ),
        .m_axi_awsize (mvm_s_axi_awsize ),
        .m_axi_awburst(mvm_s_axi_awburst),
        .m_axi_awlock (mvm_s_axi_awlock ),
        .m_axi_awcache(mvm_s_axi_awcache),
        .m_axi_awprot (mvm_s_axi_awprot ),
        .m_axi_awvalid(mvm_s_axi_awvalid),
        .m_axi_awready(mvm_s_axi_awready),
        .m_axi_wdata  (mvm_s_axi_wdata  ),
        .m_axi_wstrb  (mvm_s_axi_wstrb  ),
        .m_axi_wlast  (mvm_s_axi_wlast  ),
        .m_axi_wvalid (mvm_s_axi_wvalid ),
        .m_axi_wready (mvm_s_axi_wready ),
        .m_axi_bid    (mvm_s_axi_bid    ),
        .m_axi_bresp  (mvm_s_axi_bresp  ),
        .m_axi_bvalid (mvm_s_axi_bvalid ),
        .m_axi_bready (mvm_s_axi_bready ),
    
        .enable(1'b1),
        .abort(1'b0)
    );

    // ========================================
    //           FROM MVM TO CHK
    // ========================================

    // TODO

    // mvm_out -> pow -> mult -> err -> chk

/*
    err #(
        .DATA_WIDTH(DATA_WIDTH)
    ) l2 (
        .clk(clk), .rstn(rstn),

        .s_axis_1_tdata(s_axis_1_tdata),
        .s_axis_1_tvalid(s_axis_1_tvalid),
        .s_axis_1_tready(s_axis_1_tready),

        .s_axis_2_tdata(s_axis_2_tdata),
        .s_axis_2_tvalid(s_axis_2_tvalid),
        .s_axis_2_tready(s_axis_2_tready),
        
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast)

    );

*/

    // ========================================
    //           FORWARD OUTPUTS
    // ========================================

    // TODO

endmodule

