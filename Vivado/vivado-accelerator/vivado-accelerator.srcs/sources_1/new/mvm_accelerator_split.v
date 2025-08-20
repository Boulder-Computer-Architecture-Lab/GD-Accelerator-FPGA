`timescale 1ns / 1ps

module mvm_accelerator_split #(
    parameter DATA_WIDTH         = 1024,
    parameter ADDR_WIDTH         = 32,
    parameter STRB_WIDTH         = DATA_WIDTH / 8,
    parameter ID_WIDTH           = 4,
    
    parameter ELEMENT_WIDTH      = 64,
    parameter ELEMENTS_PER_WORD  = DATA_WIDTH / ELEMENT_WIDTH, // MUST BE A POWER OF 2!
    
    parameter WORDS_PER_ROW      = 17048,
    parameter NUM_ROWS           = 1024,
    
    parameter NUM_CHANNELS       = 4,
    parameter NUM_RAM_PARTITIONS = NUM_CHANNELS,
    
    parameter ROWS_PER_CHANNEL   = NUM_ROWS / NUM_CHANNELS,
    
    parameter AXI_RAM_BASE_ADDR  = 32'h8000_0000,
    parameter AXI_RAM_ID_WIDTH   = ID_WIDTH + 4 + $clog2(NUM_CHANNELS)
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
    
    // Input stream arrays
    wire [DATA_WIDTH-1:0] s_axis_a_tdata  [NUM_CHANNELS-1:0];
    wire                  s_axis_a_tvalid [NUM_CHANNELS-1:0];
    wire                  s_axis_a_tready [NUM_CHANNELS-1:0];
    wire                  s_axis_a_tlast  [NUM_CHANNELS-1:0];
    
    wire [DATA_WIDTH-1:0] s_axis_b_tdata  [NUM_CHANNELS-1:0];
    wire                  s_axis_b_tvalid [NUM_CHANNELS-1:0];
    wire                  s_axis_b_tready [NUM_CHANNELS-1:0];
    
    // Output stream arrays
    wire [ELEMENT_WIDTH-1:0] m_axis_tdata  [NUM_CHANNELS-1:0];
    wire                     m_axis_tvalid [NUM_CHANNELS-1:0];
    wire                     m_axis_tready [NUM_CHANNELS-1:0];
    wire                     m_axis_tlast  [NUM_CHANNELS-1:0];
    
    wire [(ID_WIDTH+4)-1:0]     m_axi_arid     [NUM_CHANNELS-1:0];
    wire [ADDR_WIDTH-1:0]       m_axi_araddr   [NUM_CHANNELS-1:0];
    wire [7:0]                  m_axi_arlen    [NUM_CHANNELS-1:0];
    wire [2:0]                  m_axi_arsize   [NUM_CHANNELS-1:0];
    wire [1:0]                  m_axi_arburst  [NUM_CHANNELS-1:0];
    wire                        m_axi_arlock   [NUM_CHANNELS-1:0];
    wire [3:0]                  m_axi_arcache  [NUM_CHANNELS-1:0];
    wire [2:0]                  m_axi_arprot   [NUM_CHANNELS-1:0];
    wire                        m_axi_arvalid  [NUM_CHANNELS-1:0];
    wire                        m_axi_arready  [NUM_CHANNELS-1:0];
    
    wire [(ID_WIDTH+4)-1:0]     m_axi_rid      [NUM_CHANNELS-1:0];
    wire [DATA_WIDTH-1:0]       m_axi_rdata    [NUM_CHANNELS-1:0];
    wire [1:0]                  m_axi_rresp    [NUM_CHANNELS-1:0];
    wire                        m_axi_rlast    [NUM_CHANNELS-1:0];
    wire                        m_axi_rvalid   [NUM_CHANNELS-1:0];
    wire                        m_axi_rready   [NUM_CHANNELS-1:0];

    // =============================================================
    //                  PARTITION ACCESS LOGIC
    // =============================================================

    localparam NUM_CHANNELS_WIDTH = $clog2(NUM_CHANNELS);
    localparam NUM_PARTITIONS_WIDTH = $clog2(NUM_RAM_PARTITIONS);
        
    reg  [NUM_PARTITIONS_WIDTH-1:0] partition_idx  [NUM_CHANNELS-1:0];
    
    reg  partition_in_use [NUM_RAM_PARTITIONS-1:0];
    reg  partition_grant  [NUM_RAM_PARTITIONS-1:0];
    wire partition_done   [NUM_RAM_PARTITIONS-1:0];

    reg  channel_active   [NUM_CHANNELS-1:0];
    reg  start            [NUM_CHANNELS-1:0];
    reg  between_rows     [NUM_CHANNELS-1:0];
    reg  init_activate    [NUM_CHANNELS-1:0];
    
    integer p, q, r, s;
    
    always @(posedge s_clk) begin
        if (!s_rstn) begin
            for (p = 0; p < NUM_CHANNELS; p = p + 1) begin
                start[p] <= 1'b0;
                partition_idx[p] <= 0;
                partition_grant[p] <= 1'b0;
                channel_active[p] <= 1'b0;
            end
        end else begin
            for (p = 0; p < NUM_CHANNELS; p = p + 1) begin
                if (!start[p]) begin
                    start[p] <= partition_grant[p] && init_activate[p] && !channel_active[p];
                end else begin
                    start[p] <= 1'b0;
                    channel_active[p] <= 1'b1;
                end
                
                if (!between_rows[p] && !partition_in_use[partition_idx[p]])
                    partition_grant[p] <= 1'b1;
            
                if (partition_done[p]) begin
                    partition_grant[p] <= 1'b0;
                    channel_active[p] <= 1'b0;
                    partition_idx[p] <= (partition_idx[p] + 1) % NUM_RAM_PARTITIONS;
                end
            end
        end
    end
    
    always @* begin
        for (q = 0; q < NUM_RAM_PARTITIONS; q = q + 1) begin
            partition_in_use[q] = 1'b0;
        end
        for (q = 0; q < NUM_RAM_PARTITIONS; q = q + 1) begin
            if (partition_grant[q])
                partition_in_use[partition_idx[q]] = 1'b1;
        end
    end
        
    always @(posedge s_clk) begin
        if (!s_rstn) begin
            for (r = 0; r < NUM_CHANNELS; r = r + 1) begin
                between_rows[r] <= 1'b1;
            end
        end else begin
            for (r = 0; r < NUM_CHANNELS; r = r + 1) begin
                if (s_axis_a_tready[r] && s_axis_a_tvalid[r] && s_axis_a_tlast[r])
                    between_rows[r] <= 1'b1;
                else if (between_rows[r] && s_axis_a_tready[r] && s_axis_a_tvalid[r])
                    between_rows[r] <= 1'b0;
            end
        end
    end
    
    always @(posedge s_clk) begin
        if (!s_rstn) begin
            for (s = 1; s < NUM_CHANNELS; s = s + 1) begin
                init_activate[s] <= (s == 0);
            end
        end else begin
            for (s = 1; s < NUM_CHANNELS; s = s + 1) begin
                if (!init_activate[s] && partition_done[s-1])
                    init_activate[s] <= 1'b1;
            end
        end
    end
    
    // =============================================================
    //                  GENERATE CHANNELS
    // =============================================================
    
    `include "bind_channels.vh"
        
    genvar ch;
    generate
        for (ch = 0; ch < NUM_CHANNELS; ch = ch + 1) begin: channel_gen
        
            mvm_channel_split #(
              .DATA_WIDTH(DATA_WIDTH),
              .ADDR_WIDTH(ADDR_WIDTH),
              .STRB_WIDTH(STRB_WIDTH),
              .ID_WIDTH(AXI_RAM_ID_WIDTH),
              .ELEMENT_WIDTH(ELEMENT_WIDTH),
              .ELEMENTS_PER_WORD(ELEMENTS_PER_WORD),
              .WORDS_PER_ROW(WORDS_PER_ROW),
              .AXI_RAM_BASE_ADDR(AXI_RAM_BASE_ADDR),
              .NUM_CHANNELS(NUM_CHANNELS),
              .NUM_RAM_PARTITIONS(NUM_RAM_PARTITIONS),
              .ROWS_PER_CHANNEL(ROWS_PER_CHANNEL),
              .TAG(ch[7:0])
            ) channel_inst (
              .s_clk(s_clk), .m_clk(m_clk),
              .s_rstn(s_rstn), .m_rstn(m_rstn),
                      
              .s_axis_a_tdata (s_axis_a_tdata[ch]),
              .s_axis_a_tvalid(s_axis_a_tvalid[ch]),
              .s_axis_a_tready(s_axis_a_tready[ch]),
              .s_axis_a_tlast (s_axis_a_tlast[ch]),
              
              .m_axis_tdata (m_axis_tdata[ch]),
              .m_axis_tvalid(m_axis_tvalid[ch]),
              .m_axis_tready(m_axis_tready[ch]),
              .m_axis_tlast (m_axis_tlast[ch]),
              
              .m_axi_arid    (m_axi_arid[ch]),
              .m_axi_araddr  (m_axi_araddr[ch]),
              .m_axi_arlen   (m_axi_arlen[ch]),
              .m_axi_arsize  (m_axi_arsize[ch]),
              .m_axi_arburst (m_axi_arburst[ch]),
              .m_axi_arlock  (m_axi_arlock[ch]),
              .m_axi_arcache (m_axi_arcache[ch]),
              .m_axi_arprot  (m_axi_arprot[ch]),
              .m_axi_arvalid (m_axi_arvalid[ch]),
              .m_axi_arready (m_axi_arready[ch]),
              .m_axi_rid     (m_axi_rid[ch]),
              .m_axi_rdata   (m_axi_rdata[ch]),
              .m_axi_rresp   (m_axi_rresp[ch]),
              .m_axi_rlast   (m_axi_rlast[ch]),
              .m_axi_rvalid  (m_axi_rvalid[ch]),
              .m_axi_rready  (m_axi_rready[ch]),
              
              .start(start[ch]),
              .init_activate(init_activate[ch]),
              .channel_active(channel_active[ch]),
              .partition_index(partition_idx[ch]),
              .partition_done(partition_done[ch])
            );
        end
    endgenerate

    // =============================================================
    //                          AXI RAM
    // =============================================================
    
    localparam ELEMENTS_PER_ROW = WORDS_PER_ROW * ELEMENTS_PER_WORD;
    localparam WORDS_PER_RAM_INST = WORDS_PER_ROW / NUM_RAM_PARTITIONS;
    localparam ELEMENTS_PER_RAM_INST = WORDS_PER_RAM_INST * ELEMENTS_PER_WORD;
    localparam BYTES_PER_RAM_INST = WORDS_PER_RAM_INST * STRB_WIDTH;
    
    localparam AXI_RAM_ADDR_WIDTH = $clog2(BYTES_PER_RAM_INST);
    localparam ARQOS = 4'b0000;
    
    localparam RAM_SEL_WIDTH = $clog2(NUM_RAM_PARTITIONS);
    
    wire [ADDR_WIDTH-1:0] rel_addr = s_axi_b_awaddr - AXI_RAM_BASE_ADDR;
    wire [RAM_SEL_WIDTH-1:0] ram_sel = rel_addr / BYTES_PER_RAM_INST;
    
    wire                        ram_awready  [NUM_RAM_PARTITIONS-1:0];
    wire                        ram_wready   [NUM_RAM_PARTITIONS-1:0];
    wire [AXI_RAM_ID_WIDTH-1:0] ram_bid      [NUM_RAM_PARTITIONS-1:0];
    wire [1:0]                  ram_bresp    [NUM_RAM_PARTITIONS-1:0];
    wire                        ram_bvalid   [NUM_RAM_PARTITIONS-1:0];
    
    wire [AXI_RAM_ID_WIDTH-1:0] ram_m_axi_arid    [NUM_RAM_PARTITIONS-1:0];
    wire [ADDR_WIDTH-1:0]       ram_m_axi_araddr  [NUM_RAM_PARTITIONS-1:0];
    wire [7:0]                  ram_m_axi_arlen   [NUM_RAM_PARTITIONS-1:0];
    wire [2:0]                  ram_m_axi_arsize  [NUM_RAM_PARTITIONS-1:0];
    wire [1:0]                  ram_m_axi_arburst [NUM_RAM_PARTITIONS-1:0];
    wire                        ram_m_axi_arlock  [NUM_RAM_PARTITIONS-1:0];
    wire [3:0]                  ram_m_axi_arcache [NUM_RAM_PARTITIONS-1:0];
    wire [2:0]                  ram_m_axi_arprot  [NUM_RAM_PARTITIONS-1:0];
    wire                        ram_m_axi_arvalid [NUM_RAM_PARTITIONS-1:0];
    wire                        ram_m_axi_arready [NUM_RAM_PARTITIONS-1:0];
    wire [AXI_RAM_ID_WIDTH-1:0] ram_m_axi_rid     [NUM_RAM_PARTITIONS-1:0];
    wire [DATA_WIDTH-1:0]       ram_m_axi_rdata   [NUM_RAM_PARTITIONS-1:0];
    wire [1:0]                  ram_m_axi_rresp   [NUM_RAM_PARTITIONS-1:0];
    wire                        ram_m_axi_rlast   [NUM_RAM_PARTITIONS-1:0];
    wire                        ram_m_axi_rvalid  [NUM_RAM_PARTITIONS-1:0];
    wire                        ram_m_axi_rready  [NUM_RAM_PARTITIONS-1:0];
    
    assign s_axi_b_bvalid = ram_bvalid[ram_sel];
    assign s_axi_b_bid    = ram_bid[ram_sel];
    assign s_axi_b_bresp  = ram_bresp[ram_sel];
    assign s_axi_b_awready = ram_awready[ram_sel];
    assign s_axi_b_wready  = ram_wready[ram_sel];
    
    genvar k;
    generate
        for (k = 0; k < NUM_RAM_PARTITIONS; k = k + 1) begin : ram_gen
            
            wire [ADDR_WIDTH-1:0] partition_base_addr = AXI_RAM_BASE_ADDR + k * BYTES_PER_RAM_INST;
            wire [AXI_RAM_ADDR_WIDTH-1:0] local_awaddr = s_axi_b_awaddr - partition_base_addr;
            
            wire [ADDR_WIDTH-1:0] ar_rel_addr_k = ram_m_axi_araddr[k] - AXI_RAM_BASE_ADDR;
            wire [RAM_SEL_WIDTH-1:0] ar_ram_sel_k = ar_rel_addr_k / BYTES_PER_RAM_INST;
            
            wire awvalid_sel = s_axi_b_awvalid && (ram_sel == k);
            wire wvalid_sel  = s_axi_b_wvalid  && (ram_sel == k);
            wire bready_sel  = s_axi_b_bready  && (ram_sel == k);
            wire arvalid_sel = ram_m_axi_arvalid[k] && (ar_ram_sel_k == k);
        
            axi_ram #(
                .NUM_WORDS(WORDS_PER_RAM_INST),
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(AXI_RAM_ADDR_WIDTH),
                .ID_WIDTH(AXI_RAM_ID_WIDTH)
            ) axi_ram_inst (
                .clk(s_clk),
                .rstn(s_rstn),
        
                // AXI Full Slave
                .s_axi_awid(s_axi_b_awid),
                .s_axi_awaddr(local_awaddr),
                .s_axi_awlen(s_axi_b_awlen),
                .s_axi_awsize(s_axi_b_awsize),
                .s_axi_awburst(s_axi_b_awburst),
                .s_axi_awlock(s_axi_b_awlock),
                .s_axi_awcache(s_axi_b_awcache),
                .s_axi_awprot(s_axi_b_awprot),
                .s_axi_awvalid(awvalid_sel),
                .s_axi_awready(ram_awready[k]),
                
                .s_axi_wdata(s_axi_b_wdata),
                .s_axi_wstrb(s_axi_b_wstrb),
                .s_axi_wlast(s_axi_b_wlast),
                .s_axi_wvalid(wvalid_sel),
                .s_axi_wready(ram_wready[k]),
                
                .s_axi_bid(ram_bid[k]),
                .s_axi_bresp(ram_bresp[k]),
                .s_axi_bvalid(ram_bvalid[k]),
                .s_axi_bready(bready_sel),
        
                // AXI Master Read
                .s_axi_arid(ram_m_axi_arid[k]),
                .s_axi_araddr(ram_m_axi_araddr[k][AXI_RAM_ADDR_WIDTH-1:0]),
                .s_axi_arlen(ram_m_axi_arlen[k]),
                .s_axi_arsize(ram_m_axi_arsize[k]),
                .s_axi_arburst(ram_m_axi_arburst[k]),
                .s_axi_arlock(ram_m_axi_arlock[k]),
                .s_axi_arcache(ram_m_axi_arcache[k]),
                .s_axi_arprot(ram_m_axi_arprot[k]),
                .s_axi_arvalid(arvalid_sel),
                .s_axi_arready(ram_m_axi_arready[k]),
            
                .s_axi_rid(ram_m_axi_rid[k]),
                .s_axi_rdata(ram_m_axi_rdata[k]),
                .s_axi_rresp(ram_m_axi_rresp[k]),
                .s_axi_rlast(ram_m_axi_rlast[k]),
                .s_axi_rvalid(ram_m_axi_rvalid[k]),
                .s_axi_rready(ram_m_axi_rready[k])
            );
        end
    endgenerate
    
    // =============================================================
    //              AXI CROSSBAR (BETWEEN DMAs AND RAM)
    // =============================================================

    /*
    function [NUM_RAM_PARTITIONS*ADDR_WIDTH-1:0] gen_m_base_addr;
        input [ADDR_WIDTH-1:0] base;
        input [ADDR_WIDTH-1:0] stride;
        integer i;
        begin
            for (i = 0; i < NUM_RAM_PARTITIONS; i = i + 1) begin
                gen_m_base_addr[(i+1)*ADDR_WIDTH-1 -: ADDR_WIDTH] = base + (i * stride);
            end
        end
    endfunction
    
    localparam DMA_BURST_LEN = 256;
    localparam [ADDR_WIDTH-1:0] RAM_MAX_BURSTS = WORDS_PER_RAM_INST / DMA_BURST_LEN;
    localparam [ADDR_WIDTH-1:0] REGION_ADDR_WIDTH = $clog2(BYTES_PER_RAM_INST);
    
    localparam S_ID_WIDTH = ID_WIDTH + 4;
    localparam M_ID_WIDTH = AXI_RAM_ID_WIDTH; 
    
    localparam [NUM_CHANNELS*ADDR_WIDTH-1:0] S_THREADS = {NUM_CHANNELS{32'd1}};
    localparam [NUM_CHANNELS*ADDR_WIDTH-1:0] S_ACCEPT  = {NUM_CHANNELS{32'd4}};
    localparam [NUM_RAM_PARTITIONS*ADDR_WIDTH-1:0] M_ISSUE = {NUM_RAM_PARTITIONS{RAM_MAX_BURSTS}};
    
    localparam [NUM_RAM_PARTITIONS*ADDR_WIDTH-1:0] M_BASE_ADDR = gen_m_base_addr(AXI_RAM_BASE_ADDR, BYTES_PER_RAM_INST);
    localparam [NUM_RAM_PARTITIONS*ADDR_WIDTH-1:0] M_ADDR_WIDTH = {NUM_RAM_PARTITIONS{REGION_ADDR_WIDTH}};
    localparam [NUM_CHANNELS*NUM_RAM_PARTITIONS-1:0] M_CONNECT = {NUM_RAM_PARTITIONS{{NUM_CHANNELS{1'b1}}}};

    axi_crossbar_rd #(
        .S_COUNT(NUM_CHANNELS),
        .M_COUNT(NUM_RAM_PARTITIONS),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .S_ID_WIDTH(S_ID_WIDTH),
        .M_ID_WIDTH(M_ID_WIDTH),
    
        .ARUSER_ENABLE(0),
        .RUSER_ENABLE(0),
        .ARUSER_WIDTH(1),
        .RUSER_WIDTH(1),
    
        .S_THREADS(S_THREADS),
        .S_ACCEPT(S_ACCEPT),
        .M_ISSUE(M_ISSUE),
    
        .M_REGIONS(1),
        .M_BASE_ADDR(M_BASE_ADDR),
        .M_ADDR_WIDTH(M_ADDR_WIDTH),
        .M_CONNECT(M_CONNECT),
        .M_SECURE({NUM_RAM_PARTITIONS{1'b0}}),
    
        .S_AR_REG_TYPE({NUM_CHANNELS{2'd1}}),
        .S_R_REG_TYPE({NUM_CHANNELS{2'd1}}),
        .M_AR_REG_TYPE({NUM_RAM_PARTITIONS{2'd1}}),
        .M_R_REG_TYPE({NUM_RAM_PARTITIONS{2'd1}})
    ) axi_crossbar_inst (
        .clk(s_clk),
        .rstn(s_rstn),
        `include "split_interconnect_channels.vh"
        .s_axi_arqos({NUM_CHANNELS{{NUM_RAM_PARTITIONS{1'b0}}}}),
        .m_axi_ruser({NUM_RAM_PARTITIONS{1'b0}})
    );
    */

    localparam AXI_WDATA_WIDTH     = DATA_WIDTH * NUM_CHANNELS;
    localparam AXI_WSTRB_WIDTH     = STRB_WIDTH * NUM_CHANNELS;
    localparam AXI_AWID_WIDTH      = AXI_RAM_ID_WIDTH * NUM_CHANNELS;
    localparam AXI_AWADDR_WIDTH    = ADDR_WIDTH * NUM_CHANNELS;
    localparam AXI_AWLEN_WIDTH     = 8 * NUM_CHANNELS;
    localparam AXI_AWSIZE_WIDTH    = 3 * NUM_CHANNELS;
    localparam AXI_AWBURST_WIDTH   = 2 * NUM_CHANNELS;
    localparam AXI_AWLOCK_WIDTH    = 1 * NUM_CHANNELS;
    localparam AXI_AWCACHE_WIDTH   = 4 * NUM_CHANNELS;
    localparam AXI_AWPROT_WIDTH    = 3 * NUM_CHANNELS;
    localparam AXI_AWQOS_WIDTH     = 4 * NUM_CHANNELS;
    localparam AXI_AWUSER_WIDTH    = 1 * NUM_CHANNELS;
    
    axi_crossbar_0 axi_crossbar_inst (
        .aclk(s_clk),
        .aresetn(s_rstn),

        `include "split_interconnect_channels.vh"

        // Tie off unused write channels
        .s_axi_awid    ({AXI_AWID_WIDTH{1'b0}}),
        .s_axi_awaddr  ({AXI_AWADDR_WIDTH{1'b0}}),
        .s_axi_awlen   ({AXI_AWLEN_WIDTH{1'b0}}),
        .s_axi_awsize  ({AXI_AWSIZE_WIDTH{1'b0}}),
        .s_axi_awburst ({AXI_AWBURST_WIDTH{1'b0}}),
        .s_axi_awlock  ({AXI_AWLOCK_WIDTH{1'b0}}),
        .s_axi_awcache ({AXI_AWCACHE_WIDTH{1'b0}}),
        .s_axi_awprot  ({AXI_AWPROT_WIDTH{1'b0}}),
        .s_axi_awqos   ({AXI_AWQOS_WIDTH{1'b0}}),
        .s_axi_awvalid ({NUM_CHANNELS{1'b0}}),
        .s_axi_wdata   ({AXI_WDATA_WIDTH{1'b0}}),
        .s_axi_wstrb   ({AXI_WSTRB_WIDTH{1'b0}}),
        .s_axi_wlast   ({NUM_CHANNELS{1'b0}}),
        .s_axi_wvalid  ({NUM_CHANNELS{1'b0}}),
        .s_axi_bready  ({NUM_CHANNELS{1'b0}}),

        .m_axi_awready (),
        .m_axi_wready  (),
        .m_axi_bid     (),
        .m_axi_bresp   (),
        .m_axi_bvalid  (),
        .m_axi_bready  (),

        .s_axi_awready (),
        .s_axi_wready  (),
        .s_axi_bid     (),
        .s_axi_bresp   (),
        .s_axi_bvalid  (),

        .m_axi_awid    (),
        .m_axi_awaddr  (),
        .m_axi_awlen   (),
        .m_axi_awsize  (),
        .m_axi_awburst (),
        .m_axi_awlock  (),
        .m_axi_awcache (),
        .m_axi_awprot  (),
        .m_axi_awqos   (),
        .m_axi_awvalid (),
        .m_axi_wdata   (),
        .m_axi_wstrb   (),
        .m_axi_wlast   (),
        .m_axi_wvalid  ()
    );

endmodule