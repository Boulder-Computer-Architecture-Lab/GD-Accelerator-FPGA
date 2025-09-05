`timescale 1ns / 1ps

module mvm_accelerator_split #(
    parameter DATA_WIDTH         = 128,
    parameter ADDR_WIDTH         = 32,
    parameter STRB_WIDTH         = DATA_WIDTH / 8,
    parameter ID_WIDTH           = 8,
    
    parameter ELEMENT_WIDTH      = 64,
    parameter ELEMENTS_PER_WORD  = DATA_WIDTH / ELEMENT_WIDTH, // MUST BE A POWER OF 2!
    
    parameter ELEMENTS_PER_ROW   = 17048,
    parameter WORDS_PER_ROW      = ELEMENTS_PER_ROW / ELEMENTS_PER_WORD,
    parameter NUM_ROWS           = 1024,
    
    parameter NUM_CHANNELS       = 4,
    parameter NUM_RAM_PARTITIONS = NUM_CHANNELS,
    
    parameter ROWS_PER_CHANNEL   = NUM_ROWS / NUM_CHANNELS,
    
    parameter AXI_RAM_BASE_ADDR  = 32'h8000_0000,
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
    
    // Output stream arrays
    wire [ELEMENT_WIDTH-1:0] m_axis_tdata  [MAX_CH-1:0];
    wire                     m_axis_tvalid [MAX_CH-1:0];
    wire                     m_axis_tready [MAX_CH-1:0];
    wire                     m_axis_tlast  [MAX_CH-1:0];
    
    wire [ID_WIDTH-1:0]         m_axi_arid     [MAX_CH-1:0];
    wire [ADDR_WIDTH-1:0]       m_axi_araddr   [MAX_CH-1:0];
    wire [7:0]                  m_axi_arlen    [MAX_CH-1:0];
    wire [2:0]                  m_axi_arsize   [MAX_CH-1:0];
    wire [1:0]                  m_axi_arburst  [MAX_CH-1:0];
    wire                        m_axi_arlock   [MAX_CH-1:0];
    wire [3:0]                  m_axi_arcache  [MAX_CH-1:0];
    wire [2:0]                  m_axi_arprot   [MAX_CH-1:0];
    wire                        m_axi_arvalid  [MAX_CH-1:0];
    wire                        m_axi_arready  [MAX_CH-1:0];
    
    wire [ID_WIDTH-1:0]         m_axi_rid      [MAX_CH-1:0];
    wire [DATA_WIDTH-1:0]       m_axi_rdata    [MAX_CH-1:0];
    wire [1:0]                  m_axi_rresp    [MAX_CH-1:0];
    wire                        m_axi_rlast    [MAX_CH-1:0];
    wire                        m_axi_rvalid   [MAX_CH-1:0];
    wire                        m_axi_rready   [MAX_CH-1:0];

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
    //                  PARTITION ACCESS LOGIC
    // =============================================================

    localparam NUM_PARTITIONS_WIDTH = $clog2(NUM_RAM_PARTITIONS+1);
    localparam ROWS_PER_CHANNEL_WIDTH = $clog2(ROWS_PER_CHANNEL+1);

    reg                             ch_start  [NUM_CHANNELS-1:0];
    reg                             ch_init   [NUM_CHANNELS-1:0];
    reg  [NUM_PARTITIONS_WIDTH-1:0] ch_pidx   [NUM_CHANNELS-1:0];
    reg                             ch_active [NUM_CHANNELS-1:0];
    wire                            ch_pdone  [NUM_CHANNELS-1:0];

    reg  [ROWS_PER_CHANNEL_WIDTH-1:0] ch_num_rows_fetched [NUM_CHANNELS-1:0];
    wire                              ch_all_rows_fetched [NUM_CHANNELS-1:0];

    reg  part_in_use [NUM_RAM_PARTITIONS-1:0];
    reg  part_grant  [NUM_RAM_PARTITIONS-1:0];
    wire part_valid  [NUM_RAM_PARTITIONS-1:0];

    wire allow_prefetch [NUM_CHANNELS-1:0];
    
    integer p, q, r;

    genvar ch;
    generate
        for (ch = 0; ch < NUM_CHANNELS; ch = ch + 1) begin : assign_fetched
            assign ch_all_rows_fetched[ch] = (ch_num_rows_fetched[ch] == ROWS_PER_CHANNEL);
        end
    endgenerate
    
    // Per channel signals
    always @(posedge s_clk) begin
        if (!s_rstn) begin
            for (p = 0; p < NUM_CHANNELS; p = p + 1) begin
                ch_start[p]  <= 1'b0;
                ch_active[p] <= 1'b0;
                ch_init[p]   <= (p == 0);
                ch_pidx[p]   <= {NUM_PARTITIONS_WIDTH{1'b0}};
                ch_num_rows_fetched[p] <= {ROWS_PER_CHANNEL_WIDTH{1'b0}};
            end
        end else begin
            for (p = 0; p < NUM_CHANNELS; p = p + 1) begin
                if (!ch_start[p]) begin
                    ch_start[p] <= part_grant[ch_pidx[p]] 
                                    &&  ch_init[p] 
                                    && !ch_active[p] 
                                    && (allow_prefetch[p] || NUM_RAM_PARTITIONS == 1)
                                    && !ch_all_rows_fetched[p];
                end else begin
                    ch_start[p] <= 1'b0;
                    ch_active[p] <= 1'b1;
                end

                if (p > 0 && !ch_init[p] && ch_pdone[p-1])
                    ch_init[p] <= 1'b1; // For filling pipeline

                if (ch_pdone[p]) begin
                    ch_active[p] <= 1'b0;
                    if (ch_pidx[p] == NUM_RAM_PARTITIONS-1) begin
                        ch_pidx[p] <= {NUM_PARTITIONS_WIDTH{1'b0}};
                        if (!ch_all_rows_fetched[p])
                            ch_num_rows_fetched[p] <= ch_num_rows_fetched[p] + 1;
                    end else begin
                        ch_pidx[p] <= ch_pidx[p] + 1;
                    end
                end
            end
        end
    end

    // Per partition signals
    always @(posedge s_clk) begin
        if (!s_rstn) begin
            for (q = 0; q < NUM_RAM_PARTITIONS; q = q + 1) begin
                part_grant[q] <= 1'b0;
            end
        end else begin
            for (q = 0; q < NUM_CHANNELS; q = q + 1) begin
                if (!ch_all_rows_fetched[q] && !ch_active[q]) begin
                    if (part_valid[ch_pidx[q]] && !part_in_use[ch_pidx[q]] && !part_grant[ch_pidx[q]])
                        part_grant[ch_pidx[q]] <= 1'b1;
                end
            end

            for (q = 0; q < NUM_CHANNELS; q = q + 1) begin
                if (ch_start[q] && part_grant[ch_pidx[q]])
                    part_grant[ch_pidx[q]] <= 1'b0;
            end
        end
    end
    
    always @* begin
        for (r = 0; r < NUM_RAM_PARTITIONS; r = r + 1) 
            part_in_use[r] = 1'b0;
        
        for (r = 0; r < NUM_CHANNELS; r = r + 1) begin
            if (ch_active[r])
                part_in_use[ch_pidx[r]] = 1'b1;
        end
    end

    // =============================================================
    //                 TRACK PARTITION VALID 
    // =============================================================
    
    localparam WORDS_PER_BURST = 256;
    localparam WORDS_PER_PARTITION = WORDS_PER_ROW / NUM_RAM_PARTITIONS;
    localparam BURSTS_PER_PARTITION = WORDS_PER_PARTITION / WORDS_PER_BURST; // must divide evenly
    localparam TOTAL_BURSTS = NUM_RAM_PARTITIONS * BURSTS_PER_PARTITION;
    localparam BURST_COUNT_WIDTH = $clog2(TOTAL_BURSTS+1);

    reg  [BURST_COUNT_WIDTH-1:0] burst_count;

    always @(posedge s_clk) begin
        if (!s_rstn) begin
            burst_count <= 0;
        end else if (s_axi_b_bvalid && s_axi_b_bready) begin
            burst_count <= burst_count + 1;
        end
    end

    genvar pvalid;
    generate
        for (pvalid = 0; pvalid < NUM_RAM_PARTITIONS; pvalid = pvalid + 1) begin : gen_pvalid
            assign part_valid[pvalid] = (burst_count >= (pvalid+1) * BURSTS_PER_PARTITION);
        end
    endgenerate

    // =============================================================
    //                  MVM_CHANNEL FIFO_A GATING
    // =============================================================

    wire activate_fifo       [NUM_CHANNELS-1:0];
    wire first_part_consumed [NUM_CHANNELS-1:0];

    assign activate_fifo[0] = 1'b1;

    genvar i;
    generate
        for (i = 1; i < NUM_CHANNELS; i = i + 1) begin : activate_fifos
            assign activate_fifo[i] = first_part_consumed[i-1];
        end
    endgenerate
    
    // =============================================================
    //                  GENERATE CHANNELS
    // =============================================================

    generate
        for (ch = 0; ch < NUM_CHANNELS; ch = ch + 1) begin : channel_gen
        
            mvm_channel_split #(
              .DATA_WIDTH(DATA_WIDTH),
              .ADDR_WIDTH(ADDR_WIDTH),
              .STRB_WIDTH(STRB_WIDTH),
              .ID_WIDTH(ID_WIDTH),
              .TAG(ch[7:0]),

              .ELEMENT_WIDTH(ELEMENT_WIDTH),
              .ELEMENTS_PER_WORD(ELEMENTS_PER_WORD),
              .ELEMENTS_PER_ROW(ELEMENTS_PER_ROW),
              .WORDS_PER_ROW(WORDS_PER_ROW),
              .NUM_ROWS(NUM_ROWS),

              .AXI_RAM_BASE_ADDR(AXI_RAM_BASE_ADDR),
              .NUM_CHANNELS(NUM_CHANNELS),
              .NUM_RAM_PARTITIONS(NUM_RAM_PARTITIONS),
              .ROWS_PER_CHANNEL(ROWS_PER_CHANNEL)

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
              
              .start(ch_start[ch]),
              .partition_done(ch_pdone[ch]),
              .partition_index(ch_pidx[ch]),

              .first_part_consumed(first_part_consumed[ch]),
              .activate_fifo(activate_fifo[ch]),
              .allow_prefetch(allow_prefetch[ch])
            );
        end
    endgenerate

    // =============================================================
    //                          AXI RAM
    // =============================================================
    
    localparam BYTES_PER_PARTITION   = WORDS_PER_PARTITION * STRB_WIDTH;
    localparam AXI_RAM_ADDR_WIDTH    = $clog2(BYTES_PER_PARTITION);
    localparam RAM_SEL_WIDTH         = NUM_PARTITIONS_WIDTH;
    
    wire [RAM_SEL_WIDTH-1:0] ram_sel = (s_axi_b_awaddr - AXI_RAM_BASE_ADDR) / BYTES_PER_PARTITION;
    
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
    
    assign s_axi_b_bvalid  = ram_bvalid[ram_sel];
    assign s_axi_b_bid     = ram_bid[ram_sel];
    assign s_axi_b_bresp   = ram_bresp[ram_sel];
    assign s_axi_b_awready = ram_awready[ram_sel];
    assign s_axi_b_wready  = ram_wready[ram_sel];
    
    genvar k;
    generate
        for (k = 0; k < NUM_RAM_PARTITIONS; k = k + 1) begin : ram_gen
            
            wire [ADDR_WIDTH-1:0] partition_base_addr = AXI_RAM_BASE_ADDR + k * BYTES_PER_PARTITION;
            wire [AXI_RAM_ADDR_WIDTH-1:0] local_awaddr = s_axi_b_awaddr - partition_base_addr;
            
            wire [ADDR_WIDTH-1:0] ar_rel_addr_k = ram_m_axi_araddr[k] - AXI_RAM_BASE_ADDR;
            wire [RAM_SEL_WIDTH-1:0] ar_ram_sel_k = ar_rel_addr_k / BYTES_PER_PARTITION;
            
            wire awvalid_sel = s_axi_b_awvalid && (ram_sel == k);
            wire wvalid_sel  = s_axi_b_wvalid  && (ram_sel == k);
            wire bready_sel  = s_axi_b_bready  && (ram_sel == k);
            wire arvalid_sel = ram_m_axi_arvalid[k] && (ar_ram_sel_k == k);
        
            axi_ram #(
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(AXI_RAM_ADDR_WIDTH),
                .STRB_WIDTH(STRB_WIDTH),
                .ID_WIDTH(AXI_RAM_ID_WIDTH),
                .NUM_WORDS(WORDS_PER_PARTITION)
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
    
    generate
        if (NUM_CHANNELS > 1 || NUM_RAM_PARTITIONS > 1) begin
            localparam S_ID_WIDTH = ID_WIDTH;
            localparam M_ID_WIDTH = AXI_RAM_ID_WIDTH; 
        
            localparam [ADDR_WIDTH-1:0] RAM_MAX_BURSTS = BURSTS_PER_PARTITION;
            localparam [ADDR_WIDTH-1:0] REGION_ADDR_WIDTH = AXI_RAM_ADDR_WIDTH;
            
            localparam [NUM_CHANNELS*ADDR_WIDTH-1:0] S_THREADS = {NUM_CHANNELS{32'd1}};
            localparam [NUM_CHANNELS*ADDR_WIDTH-1:0] S_ACCEPT  = {NUM_CHANNELS{32'd4}};
            localparam [NUM_RAM_PARTITIONS*ADDR_WIDTH-1:0] M_ISSUE = {NUM_RAM_PARTITIONS{RAM_MAX_BURSTS}};
            
            localparam [NUM_RAM_PARTITIONS*ADDR_WIDTH-1:0] M_BASE_ADDR = gen_m_base_addr(AXI_RAM_BASE_ADDR, BYTES_PER_PARTITION);
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
            
                .S_AR_REG_TYPE({NUM_CHANNELS{2'd2}}),
                .S_R_REG_TYPE({NUM_CHANNELS{2'd2}}),
                .M_AR_REG_TYPE({NUM_RAM_PARTITIONS{2'd2}}),
                .M_R_REG_TYPE({NUM_RAM_PARTITIONS{2'd2}})
            ) axi_crossbar_inst (
                .clk(s_clk),
                .rstn(s_rstn),
                `include "split_interconnect_channels.vh"
                .s_axi_arqos({NUM_CHANNELS{{NUM_RAM_PARTITIONS{1'b0}}}}),
                .s_axi_aruser({NUM_RAM_PARTITIONS{1'b0}}),
                .m_axi_ruser({NUM_RAM_PARTITIONS{1'b0}})
            );
        end else if (NUM_CHANNELS == 1 && NUM_RAM_PARTITIONS == 1) begin
            assign ram_m_axi_arid   [0] = m_axi_arid   [0];
            assign ram_m_axi_araddr [0] = m_axi_araddr [0];
            assign ram_m_axi_arlen  [0] = m_axi_arlen  [0];
            assign ram_m_axi_arsize [0] = m_axi_arsize [0];
            assign ram_m_axi_arburst[0] = m_axi_arburst[0];
            assign ram_m_axi_arlock [0] = m_axi_arlock [0];
            assign ram_m_axi_arcache[0] = m_axi_arcache[0];
            assign ram_m_axi_arprot [0] = m_axi_arprot [0];
            assign ram_m_axi_arvalid[0] = m_axi_arvalid[0];
            assign m_axi_arready    [0] = ram_m_axi_arready[0];
            
            assign m_axi_rid        [0] = ram_m_axi_rid   [0];
            assign m_axi_rdata      [0] = ram_m_axi_rdata [0];
            assign m_axi_rresp      [0] = ram_m_axi_rresp [0];
            assign m_axi_rlast      [0] = ram_m_axi_rlast [0];
            assign m_axi_rvalid     [0] = ram_m_axi_rvalid[0];
            assign ram_m_axi_rready [0] = m_axi_rready    [0];
        end
    endgenerate

endmodule
