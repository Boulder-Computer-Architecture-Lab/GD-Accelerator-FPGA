`timescale 1ns / 1ps

module mvm_channel_split #(
    parameter DATA_WIDTH         = 1024,
    parameter ADDR_WIDTH         = 32,
    parameter STRB_WIDTH         = DATA_WIDTH / 8,
    parameter ID_WIDTH           = 8,
    parameter TAG                = 0,

    parameter ELEMENT_WIDTH      = 64,
    parameter ELEMENTS_PER_WORD  = DATA_WIDTH / ELEMENT_WIDTH, // MUST BE A POWER OF 2!
    
    parameter ELEMENTS_PER_ROW = 17048,
    parameter WORDS_PER_ROW = ELEMENTS_PER_ROW / ELEMENTS_PER_WORD,
    parameter NUM_ROWS = 17048,

    parameter AXI_RAM_BASE_ADDR  = 32'h8000_0000,
    parameter NUM_CHANNELS       = 4,
    parameter NUM_RAM_PARTITIONS = NUM_CHANNELS,
    
    parameter ROWS_PER_CHANNEL = NUM_ROWS / NUM_CHANNELS
)(
    // Fast clock
    input  wire s_clk,
    input  wire s_rstn,   
    
    // Slow clock
    input  wire m_clk,
    input  wire m_rstn,
    
    // Input stream A
    input  wire [DATA_WIDTH-1:0] s_axis_a_tdata,
    input  wire                  s_axis_a_tvalid,
    output wire                  s_axis_a_tready,
    input  wire                  s_axis_a_tlast,
    
    // Output result stream
    output wire [ELEMENT_WIDTH-1:0] m_axis_tdata,
    output wire                     m_axis_tvalid,
    input  wire                     m_axis_tready,
    output wire                     m_axis_tlast,
    
    // AXI master read interface (to crossbar)
    output wire [ID_WIDTH-1:0]   m_axi_arid,
    output wire [ADDR_WIDTH-1:0] m_axi_araddr,
    output wire [7:0]            m_axi_arlen,
    output wire [2:0]            m_axi_arsize,
    output wire [1:0]            m_axi_arburst,
    output wire                  m_axi_arlock,
    output wire [3:0]            m_axi_arcache,
    output wire [2:0]            m_axi_arprot,
    output wire                  m_axi_arvalid,
    input  wire                  m_axi_arready,
    input  wire [ID_WIDTH-1:0]   m_axi_rid,
    input  wire [DATA_WIDTH-1:0] m_axi_rdata,
    input  wire [1:0]            m_axi_rresp,
    input  wire                  m_axi_rlast,
    input  wire                  m_axi_rvalid,
    output wire                  m_axi_rready,

    output wire allow_prefetch,
    
    // Partition arbitration
    input  wire start,
    output reg  partition_done,
    input  wire [$clog2(NUM_RAM_PARTITIONS+1)-1:0] partition_index,

    // Gating for fifo_in
    output reg  first_part_consumed,
    input  wire activate_fifo
);

    // ========================================
    //               BUFFERS
    // ========================================
    
    localparam WORDS_PER_PARTITION = WORDS_PER_ROW / NUM_RAM_PARTITIONS;
    localparam BYTES_PER_PARTITION = WORDS_PER_PARTITION * STRB_WIDTH;
    localparam PARTITION_WIDTH = $clog2(WORDS_PER_PARTITION+1);

    localparam INPUT_FIFO_B_DEPTH = WORDS_PER_PARTITION;
    localparam INPUT_FIFO_A_DEPTH = 512;
    localparam OUTPUT_FIFO_DEPTH = 64;
    localparam SKID = 2;
        
    // ------------- Input Buffers ------------
        
    // A
    wire [DATA_WIDTH-1:0] gate_a_tdata;
    wire                  gate_a_tvalid;
    wire                  gate_a_tready;
    wire                  gate_a_tlast;
    
    wire [DATA_WIDTH-1:0] fifo_a_s_axis_tdata;
    wire                  fifo_a_s_axis_tvalid;
    wire                  fifo_a_s_axis_tready;
    wire                  fifo_a_s_axis_tlast;

    wire [DATA_WIDTH-1:0] fifo_a_m_axis_tdata;
    wire                  fifo_a_m_axis_tvalid;
    wire                  fifo_a_m_axis_tready;
    wire                  fifo_a_m_axis_tlast;    
    
    wire [DATA_WIDTH-1:0] pipe_a_tdata;
    wire                  pipe_a_tvalid;
    wire                  pipe_a_tready;
    wire                  pipe_a_tlast;

    assign fifo_a_s_axis_tdata = gate_a_tdata;
    assign fifo_a_s_axis_tvalid = activate_fifo && gate_a_tvalid;
    assign gate_a_tready = activate_fifo && fifo_a_s_axis_tready;
    assign fifo_a_s_axis_tlast = gate_a_tlast;

    axis_register #(
        .DATA_WIDTH(DATA_WIDTH),
        .KEEP_ENABLE(0), .LAST_ENABLE(1), .ID_ENABLE(0), .DEST_ENABLE(0), .USER_ENABLE(0),
        .REG_TYPE(SKID)
    ) a_gate (
        .clk(s_clk), .rstn(s_rstn),
        .s_axis_tdata (s_axis_a_tdata),
        .s_axis_tvalid(s_axis_a_tvalid),
        .s_axis_tready(s_axis_a_tready),
        .s_axis_tlast(s_axis_a_tlast),
        .m_axis_tdata (gate_a_tdata),
        .m_axis_tvalid(gate_a_tvalid),
        .m_axis_tready(gate_a_tready),
        .m_axis_tlast(gate_a_tlast)
    );

    axis_fifo #(
        .DEPTH(INPUT_FIFO_A_DEPTH),
        .DATA_WIDTH(DATA_WIDTH),
        .KEEP_ENABLE(0),
        .LAST_ENABLE(1),
        .ID_ENABLE(0),
        .DEST_ENABLE(0),
        .USER_ENABLE(0),
        .RAM_PIPELINE(1),
        .OUTPUT_FIFO_ENABLE(0),
        .FRAME_FIFO(0),
        .DROP_OVERSIZE_FRAME(0),
        .DROP_BAD_FRAME(0),
        .DROP_WHEN_FULL(0),
        .MARK_WHEN_FULL(0),
        .PAUSE_ENABLE(0)
    ) axis_data_fifo_in (
        .clk(s_clk),
        .rstn(s_rstn),
    
        .s_axis_tdata(fifo_a_s_axis_tdata),
        .s_axis_tkeep(),
        .s_axis_tvalid(fifo_a_s_axis_tvalid),
        .s_axis_tready(fifo_a_s_axis_tready),
        .s_axis_tlast(fifo_a_s_axis_tlast),
        .s_axis_tid(8'b0),
        .s_axis_tdest(8'b0),
        .s_axis_tuser(1'b0),
    
        .m_axis_tdata(fifo_a_m_axis_tdata),
        .m_axis_tkeep(),
        .m_axis_tvalid(fifo_a_m_axis_tvalid),
        .m_axis_tready(fifo_a_m_axis_tready),
        .m_axis_tlast(fifo_a_m_axis_tlast),
        .m_axis_tid(),
        .m_axis_tdest(),
        .m_axis_tuser(),
    
        .pause_req(1'b0),
        .pause_ack(),
    
        .status_depth(),
        .status_depth_commit(),
        .status_overflow(),
        .status_bad_frame(),
        .status_good_frame()
    );
    
    axis_register #(
        .DATA_WIDTH(DATA_WIDTH),
        .KEEP_ENABLE(0), .LAST_ENABLE(1), .ID_ENABLE(0), .DEST_ENABLE(0), .USER_ENABLE(0),
        .REG_TYPE(SKID)
    ) a_skid (
        .clk(s_clk), .rstn(s_rstn),
        .s_axis_tdata (fifo_a_m_axis_tdata),
        .s_axis_tvalid(fifo_a_m_axis_tvalid),
        .s_axis_tready(fifo_a_m_axis_tready),
        .s_axis_tlast(fifo_a_m_axis_tlast),
        .m_axis_tdata (pipe_a_tdata),
        .m_axis_tvalid(pipe_a_tvalid),
        .m_axis_tready(pipe_a_tready),
        .m_axis_tlast(pipe_a_tlast)
    );

    // B
    wire [DATA_WIDTH-1:0] s_axis_b_tdata;
    wire                  s_axis_b_tvalid;
    wire                  s_axis_b_tready;
    wire                  s_axis_b_tlast;

    wire [DATA_WIDTH-1:0] gate_b_tdata;
    wire                  gate_b_tvalid;
    wire                  gate_b_tready;
    wire                  gate_b_tlast;

    wire [DATA_WIDTH-1:0] fifo_b_s_axis_tdata;
    wire                  fifo_b_s_axis_tvalid;
    wire                  fifo_b_s_axis_tready;
    wire                  fifo_b_s_axis_tlast;
    
    wire [DATA_WIDTH-1:0] fifo_b_m_axis_tdata;
    wire                  fifo_b_m_axis_tvalid;
    wire                  fifo_b_m_axis_tready;
    wire                  fifo_b_m_axis_tlast;
    
    wire [DATA_WIDTH-1:0] pipe_b_tdata;
    wire                  pipe_b_tvalid;
    wire                  pipe_b_tready;
    wire                  pipe_b_tlast;

    assign fifo_b_s_axis_tdata = gate_b_tdata;
    assign fifo_b_s_axis_tvalid = gate_b_tvalid;
    assign gate_b_tready = fifo_b_s_axis_tready;
    assign fifo_b_s_axis_tlast = gate_b_tlast;
        
    axis_register #(
        .DATA_WIDTH(DATA_WIDTH),
        .KEEP_ENABLE(0), .LAST_ENABLE(1), .ID_ENABLE(0), .DEST_ENABLE(0), .USER_ENABLE(0),
        .REG_TYPE(SKID)
    ) b_gate (
        .clk(s_clk), .rstn(s_rstn),
        .s_axis_tdata (s_axis_b_tdata),
        .s_axis_tvalid(s_axis_b_tvalid),
        .s_axis_tready(s_axis_b_tready),
        .s_axis_tlast(s_axis_b_tlast),
        .m_axis_tdata (gate_b_tdata),
        .m_axis_tvalid(gate_b_tvalid),
        .m_axis_tready(gate_b_tready),
        .m_axis_tlast(gate_b_tlast)
    );

    axis_fifo #(
        .DEPTH(INPUT_FIFO_B_DEPTH),
        .DATA_WIDTH(DATA_WIDTH),
        .KEEP_ENABLE(0),
        .LAST_ENABLE(1),
        .ID_ENABLE(0),
        .DEST_ENABLE(0),
        .USER_ENABLE(0),
        .RAM_PIPELINE(1),
        .OUTPUT_FIFO_ENABLE(0),
        .FRAME_FIFO(0),
        .DROP_OVERSIZE_FRAME(0),
        .DROP_BAD_FRAME(0),
        .DROP_WHEN_FULL(0),
        .MARK_WHEN_FULL(0),
        .PAUSE_ENABLE(0)
    ) axis_data_fifo_b (
        .clk(s_clk),
        .rstn(s_rstn),
    
        .s_axis_tdata(fifo_b_s_axis_tdata),
        .s_axis_tkeep(),
        .s_axis_tvalid(fifo_b_s_axis_tvalid),
        .s_axis_tready(fifo_b_s_axis_tready),
        .s_axis_tlast(fifo_b_s_axis_tlast),
        .s_axis_tid(8'b0),
        .s_axis_tdest(8'b0),
        .s_axis_tuser(1'b0),
    
        .m_axis_tdata(fifo_b_m_axis_tdata),
        .m_axis_tkeep(),
        .m_axis_tvalid(fifo_b_m_axis_tvalid),
        .m_axis_tready(fifo_b_m_axis_tready),
        .m_axis_tlast(fifo_b_m_axis_tlast),
        .m_axis_tid(),
        .m_axis_tdest(),
        .m_axis_tuser(),
    
        .pause_req(1'b0),
        .pause_ack(),
    
        .status_depth(),
        .status_depth_commit(),
        .status_overflow(),
        .status_bad_frame(),
        .status_good_frame()
    );
        
    axis_register #(
        .DATA_WIDTH(DATA_WIDTH),
        .KEEP_ENABLE(0), .LAST_ENABLE(1), .ID_ENABLE(0), .DEST_ENABLE(0), .USER_ENABLE(0),
        .REG_TYPE(SKID)
    ) b_skid (
        .clk(s_clk), .rstn(s_rstn),
        .s_axis_tdata (fifo_b_m_axis_tdata),
        .s_axis_tvalid(fifo_b_m_axis_tvalid),
        .s_axis_tready(fifo_b_m_axis_tready),
        .s_axis_tlast(fifo_b_m_axis_tlast),
        .m_axis_tdata (pipe_b_tdata),
        .m_axis_tvalid(pipe_b_tvalid),
        .m_axis_tready(pipe_b_tready),
        .m_axis_tlast(pipe_b_tlast)
    );
    
    // ------------ Output Buffer -------------
    
    wire [ELEMENT_WIDTH-1:0] fifo_out_s_axis_tdata;
    wire                     fifo_out_s_axis_tvalid;
    wire                     fifo_out_s_axis_tready;
    wire                     fifo_out_s_axis_tlast;
        
    axis_async_fifo #(
        .DEPTH(OUTPUT_FIFO_DEPTH),
        .DATA_WIDTH(ELEMENT_WIDTH),
        .KEEP_ENABLE(0),
        .LAST_ENABLE(1),
        .ID_ENABLE(0),
        .DEST_ENABLE(0),
        .USER_ENABLE(0),
        .RAM_PIPELINE(1),
        .OUTPUT_FIFO_ENABLE(0),
        .FRAME_FIFO(0),
        .DROP_OVERSIZE_FRAME(0),
        .DROP_BAD_FRAME(0),
        .DROP_WHEN_FULL(0),
        .MARK_WHEN_FULL(0),
        .PAUSE_ENABLE(0)
    ) axis_async_fifo_out (
        .s_clk(s_clk), .m_clk(m_clk),
        .s_rstn(s_rstn), .m_rstn(m_rstn),
    
        .s_axis_tdata(fifo_out_s_axis_tdata),
        .s_axis_tkeep(),
        .s_axis_tvalid(fifo_out_s_axis_tvalid),
        .s_axis_tready(fifo_out_s_axis_tready),
        .s_axis_tlast(fifo_out_s_axis_tlast),
        .s_axis_tid(8'b0),
        .s_axis_tdest(8'b0),
        .s_axis_tuser(1'b0),
    
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tkeep(),
        .m_axis_tvalid(m_axis_tvalid),
        .m_axis_tready(m_axis_tready),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tid(),
        .m_axis_tdest(),
        .m_axis_tuser(),
    
        .s_pause_req(1'b0),
        .s_pause_ack(),
        .m_pause_req(1'b0),
        .m_pause_ack(),
            
        .s_status_depth(),
        .s_status_depth_commit(),
        .s_status_overflow(),
        .s_status_bad_frame(),
        .s_status_good_frame(),
        .m_status_depth(),
        .m_status_depth_commit(),
        .m_status_overflow(),
        .m_status_bad_frame(),
        .m_status_good_frame()    
    );

    // ========================================
    //                COUNTERS
    // ========================================
    
    reg [PARTITION_WIDTH-1:0] word_count_a;
    reg [PARTITION_WIDTH-1:0] word_count_b;

    reg partition_count_a;
    reg partition_count_b;
    
    always @(posedge s_clk) begin
        if (!s_rstn) begin
            word_count_a <= 0;
            word_count_b <= 0;
            partition_count_a <= 1'b0;
            partition_count_b <= 1'b0;
            first_part_consumed <= 1'b0;
            partition_done <= 1'b0;
        end else begin
            partition_done <= 1'b0;

            // A counter
            if (fifo_a_s_axis_tvalid && gate_a_tready) begin
                if (word_count_a == 0) 
                    partition_count_a <= ~partition_count_a;

                if (word_count_a == WORDS_PER_PARTITION-1) begin
                    word_count_a <= 0;
                    if (!first_part_consumed)
                        first_part_consumed <= 1'b1;
                end else begin
                    word_count_a <= word_count_a + 1;
                end
            end 

            // B counter
            if (fifo_b_s_axis_tvalid && gate_b_tready) begin
                if (word_count_b == 0) 
                    partition_count_b <= ~partition_count_b;

                if (word_count_b == WORDS_PER_PARTITION-1) begin
                    word_count_b <= 0;
                    partition_done <= 1'b1;
                end else begin
                    word_count_b <= word_count_b + 1;
                end
            end
        end
    end

    // Only allow one prefetched partition
    assign allow_prefetch = (partition_count_b == partition_count_a);

    // ========================================
    //   MM2S DMA (REQ VEC FROM RAM VIA XBAR)
    // ========================================
    
    localparam DMA_BURST_LEN = 256;
    localparam DMA_LEN_WIDTH = 20;
    localparam DMA_TAG_WIDTH = 8;
            
    wire [ADDR_WIDTH-1:0] dma_desc_addr = AXI_RAM_BASE_ADDR + (partition_index * BYTES_PER_PARTITION);
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
    
    always @(posedge s_clk) begin
        if (!s_rstn)
            dma_desc_valid <= 1'b0;
        else if (!dma_desc_valid)
            dma_desc_valid <= start;
        else if (dma_desc_ready)
            dma_desc_valid <= 1'b0;
    end
        
    axi_dma_rd #(
        .AXI_DATA_WIDTH(DATA_WIDTH),
        .AXI_ADDR_WIDTH(ADDR_WIDTH),
        .AXI_STRB_WIDTH(STRB_WIDTH),
        .AXI_ID_WIDTH(ID_WIDTH),
        .AXI_MAX_BURST_LEN(DMA_BURST_LEN),
        .AXIS_DATA_WIDTH(DATA_WIDTH),
        .AXIS_KEEP_ENABLE(1),
        .AXIS_LAST_ENABLE(0),
        .AXIS_USER_ENABLE(0),
        .LEN_WIDTH(DMA_LEN_WIDTH),
        .TAG_WIDTH(DMA_TAG_WIDTH),
        .ENABLE_SG(0),
        .ENABLE_UNALIGNED(1)
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
    
        .m_axis_read_data_tdata(s_axis_b_tdata),
        .m_axis_read_data_tkeep(),
        .m_axis_read_data_tvalid(s_axis_b_tvalid),
        .m_axis_read_data_tready(s_axis_b_tready),
        .m_axis_read_data_tlast(s_axis_b_tlast),
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
    //     COMPUTE LOGIC (MACS + ADDER TREE)
    // ========================================
    
    mvm_compute #(
        .DATA_WIDTH(DATA_WIDTH),
        .ELEMENT_WIDTH(ELEMENT_WIDTH),
        .ELEMENTS_PER_WORD(ELEMENTS_PER_WORD),
        .ELEMENTS_PER_ROW(ELEMENTS_PER_ROW),
        .WORDS_PER_ROW(WORDS_PER_ROW),
        .ROWS_PER_CHANNEL(ROWS_PER_CHANNEL)
    ) compute_inst (
        .clk(s_clk),
        .rstn(s_rstn),

        .s_axis_a_tdata(pipe_a_tdata),
        .s_axis_a_tvalid(pipe_a_tvalid),
        .s_axis_a_tready(pipe_a_tready),

        .s_axis_b_tdata(pipe_b_tdata),
        .s_axis_b_tvalid(pipe_b_tvalid),
        .s_axis_b_tready(pipe_b_tready),
        
        .m_axis_tdata(fifo_out_s_axis_tdata),
        .m_axis_tvalid(fifo_out_s_axis_tvalid),
        .m_axis_tready(fifo_out_s_axis_tready),
        .m_axis_tlast(fifo_out_s_axis_tlast)
    );

endmodule
