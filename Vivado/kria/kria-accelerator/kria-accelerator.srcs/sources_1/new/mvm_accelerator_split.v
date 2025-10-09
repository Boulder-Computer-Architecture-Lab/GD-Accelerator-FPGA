`timescale 1ns / 1ps

module mvm_accelerator_split #(
    parameter DATA_WIDTH         = 128,
    parameter ADDR_WIDTH         = 64,
    parameter STRB_WIDTH         = DATA_WIDTH / 8,
    parameter ID_WIDTH           = 8,
    
    parameter ELEMENT_WIDTH      = 64,
    parameter ELEMENTS_PER_WORD  = DATA_WIDTH / ELEMENT_WIDTH,
    
    parameter ELEMENTS_PER_ROW   = 16384,
    parameter WORDS_PER_ROW      = ELEMENTS_PER_ROW / ELEMENTS_PER_WORD,
    parameter NUM_ROWS           = 16384,
    
    parameter NUM_CHANNELS       = 4,
    parameter NUM_RAM_PARTITIONS = NUM_CHANNELS,
    
    parameter ROWS_PER_CHANNEL   = NUM_ROWS / NUM_CHANNELS,
    
    parameter AXI_RAM_BASE_ADDR  = 64'h8000_0000
)(
    input wire clk,
    input wire rstn,
    
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
    input  wire [ID_WIDTH-1:0]   s_axi_b_awid,
    input  wire [ADDR_WIDTH-1:0] s_axi_b_awaddr,
    input  wire [7:0]            s_axi_b_awlen,
    input  wire [2:0]            s_axi_b_awsize,
    input  wire [1:0]            s_axi_b_awburst,
    input  wire                  s_axi_b_awlock,
    input  wire [3:0]            s_axi_b_awcache,
    input  wire [2:0]            s_axi_b_awprot,
    input  wire                  s_axi_b_awvalid,
    output wire                  s_axi_b_awready,
    
    input  wire [DATA_WIDTH-1:0] s_axi_b_wdata,
    input  wire [STRB_WIDTH-1:0] s_axi_b_wstrb,
    input  wire                  s_axi_b_wlast,
    input  wire                  s_axi_b_wvalid,
    output wire                  s_axi_b_wready,
    
    output wire [ID_WIDTH-1:0]   s_axi_b_bid,
    output wire [1:0]            s_axi_b_bresp,
    output wire                  s_axi_b_bvalid,
    input  wire                  s_axi_b_bready
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

    localparam NUM_PARTITIONS_WIDTH   = $clog2(NUM_RAM_PARTITIONS+1);
    localparam ROWS_PER_CHANNEL_WIDTH = $clog2(ROWS_PER_CHANNEL+1);
    localparam DEST_WIDTH             = $clog2(NUM_CHANNELS);

    reg                             ch_start  [NUM_CHANNELS-1:0];
    reg                             ch_init   [NUM_CHANNELS-1:0];
    reg  [NUM_PARTITIONS_WIDTH-1:0] ch_pidx   [NUM_CHANNELS-1:0];
    reg                             ch_active [NUM_CHANNELS-1:0];
    wire                            ch_pdone  [NUM_CHANNELS-1:0];

    reg  [ROWS_PER_CHANNEL_WIDTH-1:0] ch_num_rows_fetched [NUM_CHANNELS-1:0];
    wire                              ch_all_rows_fetched [NUM_CHANNELS-1:0];

    reg                   part_in_use [NUM_RAM_PARTITIONS-1:0];
    reg                   part_grant  [NUM_RAM_PARTITIONS-1:0];
    wire                  part_valid  [NUM_RAM_PARTITIONS-1:0];
    reg  [DEST_WIDTH-1:0] part_dest   [NUM_RAM_PARTITIONS-1:0];

    wire ch_allow_prefetch [NUM_CHANNELS-1:0];
    
    integer p, q, r;

    genvar ch;
    generate
        for (ch = 0; ch < NUM_CHANNELS; ch = ch + 1) begin : assign_fetched
            assign ch_all_rows_fetched[ch] = (ch_num_rows_fetched[ch] == ROWS_PER_CHANNEL);
        end
    endgenerate
    
    // Per channel signals
    always @(posedge clk) begin
        if (!rstn) begin
            for (p = 0; p < NUM_CHANNELS; p = p + 1) begin
                ch_pidx[p]   <= 0;
                ch_start[p]  <= 1'b0;
                ch_active[p] <= 1'b0;
                ch_init[p]   <= (p == 0);
                ch_num_rows_fetched[p] <= 0;
            end
        end else begin
            for (p = 0; p < NUM_CHANNELS; p = p + 1) begin
                if (p > 0 && !ch_init[p] && ch_pdone[p-1])
                    ch_init[p] <= 1'b1;

                if (!ch_start[p]) begin
                    ch_start[p] <= part_grant[ch_pidx[p]] 
                                    &&  ch_init[p] 
                                    && !ch_active[p] 
                                    &&  ch_allow_prefetch[p]
                                    && !ch_all_rows_fetched[p];
                end else begin
                    ch_start[p] <= 1'b0;
                    ch_active[p] <= 1'b1;
                end

                if (ch_pdone[p]) begin
                    ch_active[p] <= 1'b0;
                    if (ch_pidx[p] == NUM_RAM_PARTITIONS-1) begin
                        ch_pidx[p] <= 0;
                        ch_num_rows_fetched[p] <= ch_num_rows_fetched[p] + 1;
                    end else begin
                        ch_pidx[p] <= ch_pidx[p] + 1;
                    end
                end
            end
        end
    end

    // Per partition signals
    always @(posedge clk) begin
        if (!rstn) begin
            for (q = 0; q < NUM_RAM_PARTITIONS; q = q + 1) begin
                part_grant[q] <= 1'b0;
                part_dest[q]  <= 0;
            end
        end else begin
            for (q = 0; q < NUM_CHANNELS; q = q + 1) begin
                if (!ch_all_rows_fetched[q] && !ch_active[q])
                    part_grant[ch_pidx[q]] <= part_valid[ch_pidx[q]] && !part_in_use[ch_pidx[q]];

                if (ch_start[q]) begin
                    part_grant[ch_pidx[q]] <= 1'b0;
                    part_dest[ch_pidx[q]] <= q[DEST_WIDTH-1:0];
                end
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
    //                   TRACK PARTITION VALID 
    // =============================================================
    
    localparam WORDS_PER_BURST = 256;
    localparam WORDS_PER_PARTITION = WORDS_PER_ROW / NUM_RAM_PARTITIONS;
    localparam BURSTS_PER_PARTITION = WORDS_PER_PARTITION / WORDS_PER_BURST; // must divide evenly
    localparam TOTAL_BURSTS = NUM_RAM_PARTITIONS * BURSTS_PER_PARTITION;
    localparam BURST_COUNT_WIDTH = $clog2(TOTAL_BURSTS+1);

    reg  [BURST_COUNT_WIDTH-1:0] burst_count;

    always @(negedge clk) begin
        if (!rstn) begin
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

    wire [DATA_WIDTH-1:0] s_axis_b_tdata  [NUM_CHANNELS-1:0];
    wire                  s_axis_b_tvalid [NUM_CHANNELS-1:0];
    wire                  s_axis_b_tready [NUM_CHANNELS-1:0];
    wire                  s_axis_b_tlast  [NUM_CHANNELS-1:0];

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
              .clk(clk),
              .rstn(rstn),
                      
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
              .m_axis_tlast (m_axis_tlast[ch]),
              
              .partition_done(ch_pdone[ch]),
              .allow_prefetch(ch_allow_prefetch[ch]),

              .first_part_consumed(first_part_consumed[ch]),
              .activate_fifo(activate_fifo[ch]),
              .channel_active(ch_active[ch])
            );
        end
    endgenerate

    // =============================================================
    //                   AXI CROSSBAR AND SWITCH
    // =============================================================
    
    localparam AXI_RAM_ADDR_WIDTH = $clog2(WORDS_PER_PARTITION * STRB_WIDTH);
    localparam SKID = 2;
    
    wire [ID_WIDTH-1:0]   ram_m_axi_awid    [NUM_RAM_PARTITIONS-1:0];
    wire [ADDR_WIDTH-1:0] ram_m_axi_awaddr  [NUM_RAM_PARTITIONS-1:0];
    wire [7:0]            ram_m_axi_awlen   [NUM_RAM_PARTITIONS-1:0];
    wire [2:0]            ram_m_axi_awsize  [NUM_RAM_PARTITIONS-1:0];
    wire [1:0]            ram_m_axi_awburst [NUM_RAM_PARTITIONS-1:0];
    wire                  ram_m_axi_awlock  [NUM_RAM_PARTITIONS-1:0];
    wire [3:0]            ram_m_axi_awcache [NUM_RAM_PARTITIONS-1:0];
    wire [2:0]            ram_m_axi_awprot  [NUM_RAM_PARTITIONS-1:0];
    wire                  ram_m_axi_awvalid [NUM_RAM_PARTITIONS-1:0];
    wire                  ram_m_axi_awready [NUM_RAM_PARTITIONS-1:0];

    wire [DATA_WIDTH-1:0] ram_m_axi_wdata   [NUM_RAM_PARTITIONS-1:0];
    wire [STRB_WIDTH-1:0] ram_m_axi_wstrb   [NUM_RAM_PARTITIONS-1:0];
    wire                  ram_m_axi_wlast   [NUM_RAM_PARTITIONS-1:0];
    wire                  ram_m_axi_wvalid  [NUM_RAM_PARTITIONS-1:0];
    wire                  ram_m_axi_wready  [NUM_RAM_PARTITIONS-1:0];

    wire [ID_WIDTH-1:0]   ram_m_axi_bid     [NUM_RAM_PARTITIONS-1:0];
    wire [1:0]            ram_m_axi_bresp   [NUM_RAM_PARTITIONS-1:0];
    wire                  ram_m_axi_bvalid  [NUM_RAM_PARTITIONS-1:0];
    wire                  ram_m_axi_bready  [NUM_RAM_PARTITIONS-1:0];
    
    wire [ID_WIDTH-1:0]   ram_m_axi_arid    [NUM_RAM_PARTITIONS-1:0];
    wire [ADDR_WIDTH-1:0] ram_m_axi_araddr  [NUM_RAM_PARTITIONS-1:0];
    wire [7:0]            ram_m_axi_arlen   [NUM_RAM_PARTITIONS-1:0];
    wire [2:0]            ram_m_axi_arsize  [NUM_RAM_PARTITIONS-1:0];
    wire [1:0]            ram_m_axi_arburst [NUM_RAM_PARTITIONS-1:0];
    wire                  ram_m_axi_arlock  [NUM_RAM_PARTITIONS-1:0];
    wire [3:0]            ram_m_axi_arcache [NUM_RAM_PARTITIONS-1:0];
    wire [2:0]            ram_m_axi_arprot  [NUM_RAM_PARTITIONS-1:0];
    wire                  ram_m_axi_arvalid [NUM_RAM_PARTITIONS-1:0];
    wire                  ram_m_axi_arready [NUM_RAM_PARTITIONS-1:0];

    wire [ID_WIDTH-1:0]   ram_m_axi_rid     [NUM_RAM_PARTITIONS-1:0];
    wire [DATA_WIDTH-1:0] ram_m_axi_rdata   [NUM_RAM_PARTITIONS-1:0];
    wire [1:0]            ram_m_axi_rresp   [NUM_RAM_PARTITIONS-1:0];
    wire                  ram_m_axi_rlast   [NUM_RAM_PARTITIONS-1:0];
    wire                  ram_m_axi_rvalid  [NUM_RAM_PARTITIONS-1:0];
    wire                  ram_m_axi_rready  [NUM_RAM_PARTITIONS-1:0];

    wire [DATA_WIDTH-1:0] ram_axis_b_tdata  [NUM_RAM_PARTITIONS-1:0];
    wire                  ram_axis_b_tvalid [NUM_RAM_PARTITIONS-1:0];
    wire                  ram_axis_b_tready [NUM_RAM_PARTITIONS-1:0];
    wire                  ram_axis_b_tlast  [NUM_RAM_PARTITIONS-1:0];
    wire [DEST_WIDTH-1:0] ram_axis_b_tdest  [NUM_RAM_PARTITIONS-1:0];

    function automatic [NUM_RAM_PARTITIONS*ADDR_WIDTH-1:0] gen_m_base_addr;
        input [ADDR_WIDTH-1:0] base;
        input [ADDR_WIDTH-1:0] stride;
        integer i;
        begin
            for (i = 0; i < NUM_RAM_PARTITIONS; i = i + 1) begin
                gen_m_base_addr[i*ADDR_WIDTH +: ADDR_WIDTH] = base + ( ( {ADDR_WIDTH{1'b0}} | stride ) * i );
            end
        end
    endfunction
    
    generate
        if (NUM_CHANNELS > 1 || NUM_RAM_PARTITIONS > 1) begin

            localparam [ADDR_WIDTH-1:0] REGION_STRIDE = (1 << AXI_RAM_ADDR_WIDTH);
            localparam [NUM_RAM_PARTITIONS*ADDR_WIDTH-1:0] M_BASE_ADDR = gen_m_base_addr(AXI_RAM_BASE_ADDR, REGION_STRIDE);
            localparam [NUM_RAM_PARTITIONS*32-1:0] M_ADDR_WIDTH = {NUM_RAM_PARTITIONS{AXI_RAM_ADDR_WIDTH}};
        
            axi_crossbar_wr #(
                .S_COUNT(1),
                .M_COUNT(NUM_RAM_PARTITIONS),
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH),
                .S_ID_WIDTH(ID_WIDTH),
                .M_ID_WIDTH(ID_WIDTH),

                .M_BASE_ADDR(M_BASE_ADDR),
                .M_ADDR_WIDTH(M_ADDR_WIDTH),
            
                .S_AW_REG_TYPE(2'd2),
                .S_W_REG_TYPE(2'd2),
                .S_B_REG_TYPE(2'd2),
                .M_AW_REG_TYPE({NUM_RAM_PARTITIONS{2'd2}}),
                .M_W_REG_TYPE({NUM_RAM_PARTITIONS{2'd2}}),
                .M_B_REG_TYPE({NUM_RAM_PARTITIONS{2'd2}})
            ) xbar_wr_inst (
                .clk(clk), 
                .rstn(rstn),
                `include "xbar_wr_channels.vh"
                .s_axi_awqos(4'b0),
                .s_axi_awuser(1'b0),
                .s_axi_wuser(1'b0),
                .m_axi_wuser(),
                .m_axi_buser()
            );

            axis_switch #(
                .S_COUNT(NUM_RAM_PARTITIONS),
                .M_COUNT(NUM_CHANNELS),
                .DATA_WIDTH(DATA_WIDTH),

                .KEEP_ENABLE(0),
                .ID_ENABLE(0),
                .USER_ENABLE(0),

                .M_DEST_WIDTH(0),
                .S_DEST_WIDTH(DEST_WIDTH),

                .S_REG_TYPE(SKID),
                .M_REG_TYPE(SKID),

                .ARB_TYPE_ROUND_ROBIN(1),
                .ARB_LSB_HIGH_PRIORITY(0)
            ) switch_inst (
                .clk(clk),
                .rstn(rstn),

                .s_axis_tdata ({ram_axis_b_tdata[3], ram_axis_b_tdata[2], ram_axis_b_tdata[1], ram_axis_b_tdata[0]}),
                .s_axis_tkeep (),
                .s_axis_tvalid({ram_axis_b_tvalid[3], ram_axis_b_tvalid[2], ram_axis_b_tvalid[1], ram_axis_b_tvalid[0]}),
                .s_axis_tready({ram_axis_b_tready[3], ram_axis_b_tready[2], ram_axis_b_tready[1], ram_axis_b_tready[0]}),
                .s_axis_tlast ({ram_axis_b_tlast[3], ram_axis_b_tlast[2], ram_axis_b_tlast[1], ram_axis_b_tlast[0]}),
                .s_axis_tid   (),
                .s_axis_tdest ({ram_axis_b_tdest[3], ram_axis_b_tdest[2], ram_axis_b_tdest[1], ram_axis_b_tdest[0]}),
                .s_axis_tuser (),

                .m_axis_tdata ({s_axis_b_tdata[3], s_axis_b_tdata[2], s_axis_b_tdata[1], s_axis_b_tdata[0]}),
                .m_axis_tkeep (),
                .m_axis_tvalid({s_axis_b_tvalid[3], s_axis_b_tvalid[2], s_axis_b_tvalid[1], s_axis_b_tvalid[0]}),
                .m_axis_tready({s_axis_b_tready[3], s_axis_b_tready[2], s_axis_b_tready[1], s_axis_b_tready[0]}),
                .m_axis_tlast ({s_axis_b_tlast[3], s_axis_b_tlast[2], s_axis_b_tlast[1], s_axis_b_tlast[0]}),
                .m_axis_tid   (),
                .m_axis_tdest (),
                .m_axis_tuser ()
            );

        end else if (NUM_CHANNELS == 1 && NUM_RAM_PARTITIONS == 1) begin
            assign ram_m_axi_awid    [0] = s_axi_b_awid;
            assign ram_m_axi_awaddr  [0] = s_axi_b_awaddr;
            assign ram_m_axi_awlen   [0] = s_axi_b_awlen;
            assign ram_m_axi_awsize  [0] = s_axi_b_awsize;
            assign ram_m_axi_awburst [0] = s_axi_b_awburst;
            assign ram_m_axi_awlock  [0] = s_axi_b_awlock;
            assign ram_m_axi_awcache [0] = s_axi_b_awcache;
            assign ram_m_axi_awprot  [0] = s_axi_b_awprot;
            assign ram_m_axi_awvalid [0] = s_axi_b_awvalid;
            assign s_axi_b_awready       = ram_m_axi_awready [0];

            assign ram_m_axi_wdata  [0] = s_axi_b_wdata;
            assign ram_m_axi_wstrb  [0] = s_axi_b_wstrb;
            assign ram_m_axi_wlast  [0] = s_axi_b_wlast;
            assign ram_m_axi_wvalid [0] = s_axi_b_wvalid;
            assign s_axi_b_wready       = ram_m_axi_wready [0];

            assign s_axi_b_bid          = ram_m_axi_bid    [0];
            assign s_axi_b_bresp        = ram_m_axi_bresp  [0];
            assign s_axi_b_bvalid       = ram_m_axi_bvalid [0];
            assign ram_m_axi_bready [0] = s_axi_b_bready;

            assign ram_m_axi_arid    [0] = m_axi_arid        [0];
            assign ram_m_axi_araddr  [0] = m_axi_araddr      [0];
            assign ram_m_axi_arlen   [0] = m_axi_arlen       [0];
            assign ram_m_axi_arsize  [0] = m_axi_arsize      [0];
            assign ram_m_axi_arburst [0] = m_axi_arburst     [0];
            assign ram_m_axi_arlock  [0] = m_axi_arlock      [0];
            assign ram_m_axi_arcache [0] = m_axi_arcache     [0];
            assign ram_m_axi_arprot  [0] = m_axi_arprot      [0];
            assign ram_m_axi_arvalid [0] = m_axi_arvalid     [0];
            assign m_axi_arready     [0] = ram_m_axi_arready [0];
            
            assign m_axi_rid        [0]  = ram_m_axi_rid    [0];
            assign m_axi_rdata      [0]  = ram_m_axi_rdata  [0];
            assign m_axi_rresp      [0]  = ram_m_axi_rresp  [0];
            assign m_axi_rlast      [0]  = ram_m_axi_rlast  [0];
            assign m_axi_rvalid     [0]  = ram_m_axi_rvalid [0];
            assign ram_m_axi_rready [0]  = m_axi_rready     [0];
        end
    endgenerate

    // =============================================================
    //                   AXI RAM -> MM2S DMAS
    // =============================================================

    localparam BYTES_PER_PARTITION = WORDS_PER_PARTITION * STRB_WIDTH;
    localparam DMA_LEN_WIDTH = $clog2(BYTES_PER_PARTITION+1);
    localparam DMA_BURST_LEN = 256;
    localparam DMA_TAG_WIDTH = 8;
    
    genvar k;
    generate
        for (k = 0; k < NUM_RAM_PARTITIONS; k = k + 1) begin : ram_gen

            wire [AXI_RAM_ADDR_WIDTH-1:0] dma_desc_addr = AXI_RAM_BASE_ADDR + (k * BYTES_PER_PARTITION);
            wire [DMA_LEN_WIDTH-1:0]      dma_desc_len  = BYTES_PER_PARTITION;

            reg  first_desc;
            wire [DEST_WIDTH-1:0] next_dest     = (part_dest[k] == NUM_CHANNELS-1) ? 0 : (part_dest[k] + 1);
            wire [DEST_WIDTH-1:0] dma_desc_dest = !first_desc ? next_dest : part_dest[k];
                
            reg  dma_desc_valid;
            wire dma_desc_ready;
            reg  dma_desc_busy;
            
            wire [7:0] dma_desc_tag  = k;
            wire [7:0] dma_desc_id   = k;
            wire       dma_desc_user = 1'b0;

            wire [7:0] dma_status_tag;
            wire [3:0] dma_status_error;
            wire       dma_status_valid;

            always @(posedge clk) begin
                if (!rstn) begin
                    dma_desc_valid <= 1'b0;
                    dma_desc_busy  <= 1'b0;
                    first_desc     <= 1'b1;
                end else begin
                    if (!dma_desc_busy && part_grant[k]) begin
                        dma_desc_valid <= 1'b1;
                    end

                    if (dma_desc_valid && dma_desc_ready) begin
                        dma_desc_valid <= 1'b0;
                        dma_desc_busy  <= 1'b1;
                        first_desc     <= 1'b0;
                    end

                    if (dma_status_valid) begin
                        dma_desc_busy <= 1'b0;
                    end
                end
            end
                
            axi_dma_rd #(
                .AXI_DATA_WIDTH(DATA_WIDTH),
                .AXI_ADDR_WIDTH(AXI_RAM_ADDR_WIDTH),
                .AXI_STRB_WIDTH(STRB_WIDTH),
                .AXI_ID_WIDTH(ID_WIDTH),
                .AXI_MAX_BURST_LEN(DMA_BURST_LEN),
                .AXIS_USER_ENABLE(0),
                .AXIS_DEST_ENABLE(1),
                .AXIS_DEST_WIDTH(DEST_WIDTH),
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
            
                .m_axis_read_data_tdata(ram_axis_b_tdata[k]),
                .m_axis_read_data_tkeep(),
                .m_axis_read_data_tvalid(ram_axis_b_tvalid[k]),
                .m_axis_read_data_tready(ram_axis_b_tready[k]),
                .m_axis_read_data_tlast(ram_axis_b_tlast[k]),
                .m_axis_read_data_tid(),
                .m_axis_read_data_tdest(ram_axis_b_tdest[k]),
                .m_axis_read_data_tuser(),
            
                .m_axi_arid(ram_m_axi_arid[k]),
                .m_axi_araddr(ram_m_axi_araddr[k][AXI_RAM_ADDR_WIDTH-1:0]),
                .m_axi_arlen(ram_m_axi_arlen[k]),
                .m_axi_arsize(ram_m_axi_arsize[k]),
                .m_axi_arburst(ram_m_axi_arburst[k]),
                .m_axi_arlock(ram_m_axi_arlock[k]),
                .m_axi_arcache(ram_m_axi_arcache[k]),
                .m_axi_arprot(ram_m_axi_arprot[k]),
                .m_axi_arvalid(ram_m_axi_arvalid[k]),
                .m_axi_arready(ram_m_axi_arready[k]),
                .m_axi_rid(ram_m_axi_rid[k]),
                .m_axi_rdata(ram_m_axi_rdata[k]),
                .m_axi_rresp(ram_m_axi_rresp[k]),
                .m_axi_rlast(ram_m_axi_rlast[k]),
                .m_axi_rvalid(ram_m_axi_rvalid[k]),
                .m_axi_rready(ram_m_axi_rready[k]),
            
                .enable(1'b1)
            );

            axi_ram #(
                .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(AXI_RAM_ADDR_WIDTH),
                .STRB_WIDTH(STRB_WIDTH),
                .ID_WIDTH(ID_WIDTH),
                .RAM_TYPE(0), // BRAM
                .NUM_WORDS(WORDS_PER_PARTITION)
            ) axi_ram_inst (
                .clk(clk),
                .rstn(rstn),
        
                .s_axi_awid(ram_m_axi_awid[k]),
                .s_axi_awaddr(ram_m_axi_awaddr[k][AXI_RAM_ADDR_WIDTH-1:0]),
                .s_axi_awlen(ram_m_axi_awlen[k]),
                .s_axi_awsize(ram_m_axi_awsize[k]),
                .s_axi_awburst(ram_m_axi_awburst[k]),
                .s_axi_awlock(ram_m_axi_awlock[k]),
                .s_axi_awcache(ram_m_axi_awcache[k]),
                .s_axi_awprot(ram_m_axi_awprot[k]),
                .s_axi_awvalid(ram_m_axi_awvalid[k]),
                .s_axi_awready(ram_m_axi_awready[k]),
                
                .s_axi_wdata(ram_m_axi_wdata[k]),
                .s_axi_wstrb(ram_m_axi_wstrb[k]),
                .s_axi_wlast(ram_m_axi_wlast[k]),
                .s_axi_wvalid(ram_m_axi_wvalid[k]),
                .s_axi_wready(ram_m_axi_wready[k]),
                
                .s_axi_bid(ram_m_axi_bid[k]),
                .s_axi_bresp(ram_m_axi_bresp[k]),
                .s_axi_bvalid(ram_m_axi_bvalid[k]),
                .s_axi_bready(ram_m_axi_bready[k]),
        
                .s_axi_arid(ram_m_axi_arid[k]),
                .s_axi_araddr(ram_m_axi_araddr[k][AXI_RAM_ADDR_WIDTH-1:0]),
                .s_axi_arlen(ram_m_axi_arlen[k]),
                .s_axi_arsize(ram_m_axi_arsize[k]),
                .s_axi_arburst(ram_m_axi_arburst[k]),
                .s_axi_arlock(ram_m_axi_arlock[k]),
                .s_axi_arcache(ram_m_axi_arcache[k]),
                .s_axi_arprot(ram_m_axi_arprot[k]),
                .s_axi_arvalid(ram_m_axi_arvalid[k]),
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
    
endmodule
