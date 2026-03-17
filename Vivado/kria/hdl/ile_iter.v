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
    input  wire [ID_WIDTH-1:0]          s_axi_b_awid,
    input  wire [ADDR_WIDTH-1:0]        s_axi_b_awaddr,
    input  wire [7:0]                   s_axi_b_awlen,
    input  wire [2:0]                   s_axi_b_awsize,
    input  wire [1:0]                   s_axi_b_awburst,
    input  wire                         s_axi_b_awlock,
    input  wire [3:0]                   s_axi_b_awcache,
    input  wire [2:0]                   s_axi_b_awprot,
    input  wire                         s_axi_b_awvalid,
    output wire                         s_axi_b_awready,
    input  wire [AXI_B_DATA_WIDTH-1:0]  s_axi_b_wdata,
    input  wire [AXI_B_STRB_WIDTH-1:0]  s_axi_b_wstrb,
    input  wire                         s_axi_b_wlast,
    input  wire                         s_axi_b_wvalid,
    output wire                         s_axi_b_wready,
    output wire [ID_WIDTH-1:0]          s_axi_b_bid,
    output wire [1:0]                   s_axi_b_bresp,
    output wire                         s_axi_b_bvalid,
    input  wire                         s_axi_b_bready,

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
    wire [7:0]                      mvm_s_axi__awlen;
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
        .s_axi_b_awlen  (mvm_s_axi__awlen),
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

    localparam DMA_LEN_WIDTH = $clog2(MATRIX_BYTES_PER_PARTITION+1);
    localparam DMA_BURST_LEN = 256;
    localparam DMA_TAG_WIDTH = 8;

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
    reg  [MATRIX_ADDR_WIDTH-1:0] dma_wr_desc_addr  [MAX_CH-1:0];
    reg  [DMA_LEN_WIDTH-1:0]     dma_wr_desc_len   [MAX_CH-1:0];
    reg  [DMA_TAG_WIDTH-1:0]     dma_wr_desc_tag   [MAX_CH-1:0];
    reg                          dma_wr_desc_valid [MAX_CH-1:0];
    wire                         dma_wr_desc_ready [MAX_CH-1:0];
    
    reg  [MATRIX_ADDR_WIDTH-1:0] dma_rd_desc_addr  [MAX_CH-1:0];
    reg  [DMA_LEN_WIDTH-1:0]     dma_rd_desc_len   [MAX_CH-1:0];
    reg  [DMA_TAG_WIDTH-1:0]     dma_rd_desc_tag   [MAX_CH-1:0];
    reg                          dma_rd_desc_valid [MAX_CH-1:0];
    wire                         dma_rd_desc_ready [MAX_CH-1:0];
    
    wire dma_wr_status_valid [MAX_CH-1:0];
    wire dma_rd_status_valid [MAX_CH-1:0];

    integer i;
    always @(posedge clk) begin
        if (!rstn) begin
            for (i = 0; i < MAX_CH; i = i + 1) begin
                // Configure write descriptor
                dma_wr_desc_addr[i] <= {MATRIX_ADDR_WIDTH{1'b0}};
                dma_wr_desc_len [i] <= MATRIX_BYTES_PER_PARTITION;
                dma_wr_desc_tag [i] <= i[DMA_TAG_WIDTH-1:0];
    
                // Configure read descriptor
                dma_rd_desc_addr[i] <= {MATRIX_ADDR_WIDTH{1'b0}};
                dma_rd_desc_len [i] <= MATRIX_BYTES_PER_PARTITION;
                dma_rd_desc_tag [i] <= i[DMA_TAG_WIDTH-1:0];
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
                    if (dma_wr_desc_valid[k] && dma_wr_desc_ready[k])
                        dma_wr_desc_valid[k] <= 1'b0;
                    else if (!dma_wr_desc_valid[k] && dma_wr_status_valid[k])
                        dma_wr_desc_valid[k] <= 1'b1;

                    // Program read descriptor
                    if (!dma_rd_desc_valid[k])
                        dma_rd_desc_valid[k] <= start_mvm;
                    else if (dma_rd_desc_ready[k])
                        dma_rd_desc_valid[k] <= 1'b0;
                end
            end

            axi_dma #(
                .AXI_DATA_WIDTH   (MATRIX_DATA_WIDTH),
                .AXI_ADDR_WIDTH   (MATRIX_ADDR_WIDTH),
                .AXI_STRB_WIDTH   (MATRIX_STRB_WIDTH),
                .AXI_ID_WIDTH     (MATRIX_ID_WIDTH),
                .AXI_MAX_BURST_LEN(DMA_BURST_LEN),
                .LEN_WIDTH        (DMA_LEN_WIDTH),
                .TAG_WIDTH        (DMA_TAG_WIDTH),
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
    //          AXI_B INPUT PORT
    // ========================================

    localparam AXI_B_S_COUNT    = 1;
    localparam AXI_B_M_COUNT    = 3;

    localparam AXI_B_S_ID_WIDTH = ID_WIDTH;
    localparam AXI_B_M_ID_WIDTH = AXI_B_S_ID_WIDTH + $clog2(AXI_B_S_COUNT);

    function automatic [AXI_B_M_COUNT*ADDR_WIDTH-1:0] gen_m_base_addr;
        input [ADDR_WIDTH-1:0] base;
        input [ADDR_WIDTH-1:0] stride;
        integer i;
        begin
            for (i = 0; i < AXI_B_M_COUNT; i = i + 1) begin
                gen_m_base_addr[i*ADDR_WIDTH +: ADDR_WIDTH] = base + ( ( {ADDR_WIDTH{1'b0}} | stride ) * i );
            end
        end
    endfunction

    localparam AXI_B_WORDS_PER_PORT = WORDS_PER_ROW;
    localparam AXI_B_BYTES_PER_PORT = AXI_B_WORDS_PER_PORT * AXI_B_STRB_WIDTH;
    localparam AXI_B_ADDR_WIDTH     = $clog2(AXI_B_BYTES_PER_PORT);

    localparam [ADDR_WIDTH-1:0] AXI_B_STRIDE = (1 << AXI_B_ADDR_WIDTH);
    localparam [AXI_B_M_COUNT*ADDR_WIDTH-1:0] AXI_B_M_BASE_ADDR = gen_m_base_addr(AXI_B_BASE_ADDR, AXI_B_STRIDE);
    localparam [AXI_B_M_COUNT*32-1:0] AXI_B_M_ADDR_WIDTH = {AXI_B_M_COUNT{AXI_B_ADDR_WIDTH}};

    wire [AXI_B_M_ID_WIDTH-1:0] axi_b_ram_m_axi_awid    [AXI_B_M_COUNT-1:0];
    wire [ADDR_WIDTH-1:0]       axi_b_ram_m_axi_awaddr  [AXI_B_M_COUNT-1:0];
    wire [7:0]                  axi_b_ram_m_axi_awlen   [AXI_B_M_COUNT-1:0];
    wire [2:0]                  axi_b_ram_m_axi_awsize  [AXI_B_M_COUNT-1:0];
    wire [1:0]                  axi_b_ram_m_axi_awburst [AXI_B_M_COUNT-1:0];
    wire                        axi_b_ram_m_axi_awlock  [AXI_B_M_COUNT-1:0];
    wire [3:0]                  axi_b_ram_m_axi_awcache [AXI_B_M_COUNT-1:0];
    wire [2:0]                  axi_b_ram_m_axi_awprot  [AXI_B_M_COUNT-1:0];
    wire                        axi_b_ram_m_axi_awvalid [AXI_B_M_COUNT-1:0];
    wire                        axi_b_ram_m_axi_awready [AXI_B_M_COUNT-1:0];

    wire [AXI_B_DATA_WIDTH-1:0] axi_b_ram_m_axi_wdata   [AXI_B_M_COUNT-1:0];
    wire [AXI_B_STRB_WIDTH-1:0] axi_b_ram_m_axi_wstrb   [AXI_B_M_COUNT-1:0];
    wire                        axi_b_ram_m_axi_wlast   [AXI_B_M_COUNT-1:0];
    wire                        axi_b_ram_m_axi_wvalid  [AXI_B_M_COUNT-1:0];
    wire                        axi_b_ram_m_axi_wready  [AXI_B_M_COUNT-1:0];

    wire [AXI_B_ID_WIDTH-1:0]   axi_b_ram_m_axi_bid     [AXI_B_M_COUNT-1:0];
    wire [1:0]                  axi_b_ram_m_axi_bresp   [AXI_B_M_COUNT-1:0];
    wire                        axi_b_ram_m_axi_bvalid  [AXI_B_M_COUNT-1:0];
    wire                        axi_b_ram_m_axi_bready  [AXI_B_M_COUNT-1:0];
    
    wire [AXI_B_ID_WIDTH-1:0]   axi_b_ram_m_axi_arid    [AXI_B_M_COUNT-1:0];
    wire [ADDR_WIDTH-1:0]       axi_b_ram_m_axi_araddr  [AXI_B_M_COUNT-1:0];
    wire [7:0]                  axi_b_ram_m_axi_arlen   [AXI_B_M_COUNT-1:0];
    wire [2:0]                  axi_b_ram_m_axi_arsize  [AXI_B_M_COUNT-1:0];
    wire [1:0]                  axi_b_ram_m_axi_arburst [AXI_B_M_COUNT-1:0];
    wire                        axi_b_ram_m_axi_arlock  [AXI_B_M_COUNT-1:0];
    wire [3:0]                  axi_b_ram_m_axi_arcache [AXI_B_M_COUNT-1:0];
    wire [2:0]                  axi_b_ram_m_axi_arprot  [AXI_B_M_COUNT-1:0];
    wire                        axi_b_ram_m_axi_arvalid [AXI_B_M_COUNT-1:0];
    wire                        axi_b_ram_m_axi_arready [AXI_B_M_COUNT-1:0];

    wire [AXI_B_M_ID_WIDTH-1:0] axi_b_ram_m_axi_rid     [AXI_B_M_COUNT-1:0];
    wire [AXI_B_DATA_WIDTH-1:0] axi_b_ram_m_axi_rdata   [AXI_B_M_COUNT-1:0];
    wire [1:0]                  axi_b_ram_m_axi_rresp   [AXI_B_M_COUNT-1:0];
    wire                        axi_b_ram_m_axi_rlast   [AXI_B_M_COUNT-1:0];
    wire                        axi_b_ram_m_axi_rvalid  [AXI_B_M_COUNT-1:0];
    wire                        axi_b_ram_m_axi_rready  [AXI_B_M_COUNT-1:0];

    // Crossbar:
    //   - Input port: S_AXI_B
    //   - Output ports:
    //      0. vec_init (to mm2s -> chk)
    //      1. input_integral_outer (to BRAM)
    //      2. aa2*input_uhat_inner (to BRAM)

    axi_crossbar_wr #(
        .S_COUNT   (AXI_B_S_COUNT   ),
        .M_COUNT   (AXI_B_M_COUNT   ),
        .DATA_WIDTH(AXI_B_DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH      ),
        .S_ID_WIDTH(AXI_B_S_ID_WIDTH),
        .M_ID_WIDTH(AXI_B_M_ID_WIDTH),

        .M_BASE_ADDR (AXI_B_M_BASE_ADDR ),
        .M_ADDR_WIDTH(AXI_B_M_ADDR_WIDTH),
    
        .S_AW_REG_TYPE(2'd2),
        .S_W_REG_TYPE (2'd2),
        .S_B_REG_TYPE (2'd2),
        .M_AW_REG_TYPE({AXI_B_M_COUNT{2'd2}}),
        .M_W_REG_TYPE ({AXI_B_M_COUNT{2'd2}}),
        .M_B_REG_TYPE ({AXI_B_M_COUNT{2'd2}})
    ) xbar_wr_inst (
        .clk(clk), .rstn(rstn),

        .s_axi_awid   (s_axi_b_awid   ),
        .s_axi_awaddr (s_axi_b_awaddr ),
        .s_axi_awlen  (s_axi_b_awlen  ),
        .s_axi_awsize (s_axi_b_awsize ),
        .s_axi_awburst(s_axi_b_awburst),
        .s_axi_awlock (s_axi_b_awlock ),
        .s_axi_awcache(s_axi_b_awcache),
        .s_axi_awprot (s_axi_b_awprot ),
        .s_axi_awvalid(s_axi_b_awvalid),
        .s_axi_awready(s_axi_b_awready),
        .s_axi_wdata  (s_axi_b_wdata  ),
        .s_axi_wstrb  (s_axi_b_wstrb  ),
        .s_axi_wlast  (s_axi_b_wlast  ),
        .s_axi_wvalid (s_axi_b_wvalid ),
        .s_axi_wready (s_axi_b_wready ),
        .s_axi_bid    (s_axi_b_bid    ),
        .s_axi_bresp  (s_axi_b_bresp  ),
        .s_axi_bvalid (s_axi_b_bvalid ),
        .s_axi_bready (s_axi_b_bready ),
        .s_axi_awqos  (4'b0),
        .s_axi_awuser (1'b0),
        .s_axi_wuser  (1'b0),

        .m_axi_awid   ({axi_b_ram_m_axi_awid   [2], axi_b_ram_m_axi_awid   [1], axi_b_ram_m_axi_awid   [0]}),
        .m_axi_awaddr ({axi_b_ram_m_axi_awaddr [2], axi_b_ram_m_axi_awaddr [1], axi_b_ram_m_axi_awaddr [0]}),
        .m_axi_awlen  ({axi_b_ram_m_axi_awlen  [2], axi_b_ram_m_axi_awlen  [1], axi_b_ram_m_axi_awlen  [0]}),
        .m_axi_awsize ({axi_b_ram_m_axi_awsize [2], axi_b_ram_m_axi_awsize [1], axi_b_ram_m_axi_awsize [0]}),
        .m_axi_awburst({axi_b_ram_m_axi_awburst[2], axi_b_ram_m_axi_awburst[1], axi_b_ram_m_axi_awburst[0]}),
        .m_axi_awlock ({axi_b_ram_m_axi_awlock [2], axi_b_ram_m_axi_awlock [1], axi_b_ram_m_axi_awlock [0]}),
        .m_axi_awcache({axi_b_ram_m_axi_awcache[2], axi_b_ram_m_axi_awcache[1], axi_b_ram_m_axi_awcache[0]}),
        .m_axi_awprot ({axi_b_ram_m_axi_awprot [2], axi_b_ram_m_axi_awprot [1], axi_b_ram_m_axi_awprot [0]}),
        .m_axi_awvalid({axi_b_ram_m_axi_awvalid[2], axi_b_ram_m_axi_awvalid[1], axi_b_ram_m_axi_awvalid[0]}),
        .m_axi_awready({axi_b_ram_m_axi_awready[2], axi_b_ram_m_axi_awready[1], axi_b_ram_m_axi_awready[0]}),
        .m_axi_wdata  ({axi_b_ram_m_axi_wdata  [2], axi_b_ram_m_axi_wdata  [1], axi_b_ram_m_axi_wdata  [0]}),
        .m_axi_wstrb  ({axi_b_ram_m_axi_wstrb  [2], axi_b_ram_m_axi_wstrb  [1], axi_b_ram_m_axi_wstrb  [0]}),
        .m_axi_wlast  ({axi_b_ram_m_axi_wlast  [2], axi_b_ram_m_axi_wlast  [1], axi_b_ram_m_axi_wlast  [0]}),
        .m_axi_wvalid ({axi_b_ram_m_axi_wvalid [2], axi_b_ram_m_axi_wvalid [1], axi_b_ram_m_axi_wvalid [0]}),
        .m_axi_wready ({axi_b_ram_m_axi_wready [2], axi_b_ram_m_axi_wready [1], axi_b_ram_m_axi_wready [0]}),
        .m_axi_bid    ({axi_b_ram_m_axi_bid    [2], axi_b_ram_m_axi_bid    [1], axi_b_ram_m_axi_bid    [0]}),
        .m_axi_bresp  ({axi_b_ram_m_axi_bresp  [2], axi_b_ram_m_axi_bresp  [1], axi_b_ram_m_axi_bresp  [0]}),
        .m_axi_bvalid ({axi_b_ram_m_axi_bvalid [2], axi_b_ram_m_axi_bvalid [1], axi_b_ram_m_axi_bvalid [0]}),
        .m_axi_bready ({axi_b_ram_m_axi_bready [2], axi_b_ram_m_axi_bready [1], axi_b_ram_m_axi_bready [0]}),
        .m_axi_wuser(),
        .m_axi_buser()
    );

    // ========================================
    //          AXI_B OUTPUT BUFFERS
    // ========================================

    genvar b;
    generate
        for (b = 0; b < AXI_B_M_COUNT; b = b + 1) begin : axi_b_ram_gen
            axi_ram #(
                .DATA_WIDTH(AXI_B_DATA_WIDTH    ),
                .ADDR_WIDTH(AXI_B_ADDR_WIDTH    ),
                .STRB_WIDTH(AXI_B_STRB_WIDTH    ),
                .ID_WIDTH  (AXI_B_M_ID_WIDTH    ),
                .NUM_WORDS (AXI_B_WORDS_PER_PORT)
            ) axi_b_ram_inst (
                .clk(clk), .rstn(rstn),

                .s_axi_awid   (axi_b_ram_m_axi_awid   [b]),
                .s_axi_awaddr (axi_b_ram_m_axi_awaddr [b][AXI_B_ADDR_WIDTH-1:0]),
                .s_axi_awlen  (axi_b_ram_m_axi_awlen  [b]),
                .s_axi_awsize (axi_b_ram_m_axi_awsize [b]),
                .s_axi_awburst(axi_b_ram_m_axi_awburst[b]),
                .s_axi_awlock (axi_b_ram_m_axi_awlock [b]),
                .s_axi_awcache(axi_b_ram_m_axi_awcache[b]),
                .s_axi_awprot (axi_b_ram_m_axi_awprot [b]),
                .s_axi_awvalid(axi_b_ram_m_axi_awvalid[b]),
                .s_axi_awready(axi_b_ram_m_axi_awready[b]),
                
                .s_axi_wdata  (axi_b_ram_m_axi_wdata  [b]),
                .s_axi_wstrb  (axi_b_ram_m_axi_wstrb  [b]),
                .s_axi_wlast  (axi_b_ram_m_axi_wlast  [b]),
                .s_axi_wvalid (axi_b_ram_m_axi_wvalid [b]),
                .s_axi_wready (axi_b_ram_m_axi_wready [b]),
                
                .s_axi_bid    (axi_b_ram_m_axi_bid    [b]),
                .s_axi_bresp  (axi_b_ram_m_axi_bresp  [b]),
                .s_axi_bvalid (axi_b_ram_m_axi_bvalid [b]),
                .s_axi_bready (axi_b_ram_m_axi_bready [b]),

                .s_axi_arid   (axi_b_ram_m_axi_arid   [b]),
                .s_axi_araddr (axi_b_ram_m_axi_araddr [b][AXI_B_ADDR_WIDTH-1:0]),
                .s_axi_arlen  (axi_b_ram_m_axi_arlen  [b]),
                .s_axi_arsize (axi_b_ram_m_axi_arsize [b]),
                .s_axi_arburst(axi_b_ram_m_axi_arburst[b]),
                .s_axi_arlock (axi_b_ram_m_axi_arlock [b]),
                .s_axi_arcache(axi_b_ram_m_axi_arcache[b]),
                .s_axi_arprot (axi_b_ram_m_axi_arprot [b]),
                .s_axi_arvalid(axi_b_ram_m_axi_arvalid[b]),
                .s_axi_arready(axi_b_ram_m_axi_arready[b]),
            
                .s_axi_rid    (axi_b_ram_m_axi_rid    [b]),
                .s_axi_rdata  (axi_b_ram_m_axi_rdata  [b]),
                .s_axi_rresp  (axi_b_ram_m_axi_rresp  [b]),
                .s_axi_rlast  (axi_b_ram_m_axi_rlast  [b]),
                .s_axi_rvalid (axi_b_ram_m_axi_rvalid [b]),
                .s_axi_rready (axi_b_ram_m_axi_rready [b])
            );
        end
    endgenerate


/*

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

    pow #(
        .DATA_WIDTH(DATA_WIDTH)
    ) pow_inst (
        .clk(clk), .rstn(rstn),

        // base
        .s_axis_1_tdata(s_axis_1_tdata),
        .s_axis_1_tvalid(s_axis_1_tvalid),
        .s_axis_1_tready(s_axis_1_tready),
        .s_axis_1_tlast(s_axis_1_tlast),

        // exp
        .s_axis_2_tdata(s_axis_2_tdata),
        .s_axis_2_tvalid(s_axis_2_tvalid),
        .s_axis_2_tready(s_axis_2_tready),
        
        // result 
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast)
    );

    fp64_mult mult (
        .aclk(clk), .aresetn(rstn),

        .s_axis_a_tvalid(s_axis_a_tvalid),
        .s_axis_a_tready(s_axis_a_tready),
        .s_axis_a_tdata(s_axis_a_tdata),
        .s_axis_a_tlast(s_axis_a_tlast),

        .s_axis_b_tvalid(s_axis_b_tvalid),
        .s_axis_b_tready(s_axis_b_tready),
        .s_axis_b_tdata(s_axis_b_tdata),

        .m_axis_result_tvalid(m_axis_result_tvalid),
        .m_axis_result_tready(m_axis_result_tready),
        .m_axis_result_tdata(m_axis_result_tdata),
        .m_axis_result_tlast(m_axis_result_tlast)
    );

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

    check_convergence #(
        .DATA_WIDTH(DATA_WIDTH)
    )(

        .clk(clk), .rstn(rstn),

        // Input stream 1 
        input  wire [DATA_WIDTH-1:0] s_axis_1_tdata,
        input  wire                  s_axis_1_tvalid,
        output wire                  s_axis_1_tready,

        // Input stream 2
        input  wire [DATA_WIDTH-1:0] s_axis_2_tdata,
        input  wire                  s_axis_2_tvalid,
        output wire                  s_axis_2_tready,
        
        // Result stream
        output wire [DATA_WIDTH-1:0] m_axis_tdata,
        output wire                  m_axis_tvalid,
        input  wire                  m_axis_tready,
        output wire                  m_axis_tlast
    );

*/

endmodule
