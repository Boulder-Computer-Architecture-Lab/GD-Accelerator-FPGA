`timescale 1ns / 1ps

module mvm_channel_split #(
    parameter DATA_WIDTH         = 128,
    parameter ADDR_WIDTH         = 64,
    parameter STRB_WIDTH         = DATA_WIDTH / 8,
    parameter ID_WIDTH           = 8,
    parameter TAG                = 0,

    parameter ELEMENT_WIDTH      = 64,
    parameter ELEMENTS_PER_WORD  = DATA_WIDTH / ELEMENT_WIDTH,
    
    parameter ELEMENTS_PER_ROW = 16384,
    parameter WORDS_PER_ROW = ELEMENTS_PER_ROW / ELEMENTS_PER_WORD,
    parameter NUM_ROWS = 16384,

    parameter AXI_RAM_BASE_ADDR  = 64'h8000_0000,
    parameter NUM_CHANNELS       = 4,
    parameter NUM_RAM_PARTITIONS = NUM_CHANNELS,
    
    parameter ROWS_PER_CHANNEL = NUM_ROWS / NUM_CHANNELS
)(

    input  wire clk,
    input  wire rstn,   
    
    // Input stream A
    input  wire [DATA_WIDTH-1:0] s_axis_a_tdata,
    input  wire                  s_axis_a_tvalid,
    output wire                  s_axis_a_tready,
    input  wire                  s_axis_a_tlast,
    
    // Input stream B
    input  wire [DATA_WIDTH-1:0] s_axis_b_tdata,
    input  wire                  s_axis_b_tvalid,
    output wire                  s_axis_b_tready,
    input  wire                  s_axis_b_tlast,
    
    // Output result stream
    output wire [ELEMENT_WIDTH-1:0] m_axis_tdata,
    output wire                     m_axis_tvalid,
    input  wire                     m_axis_tready,
    output wire                     m_axis_tlast,
    
    // Partition arbitration
    output reg  partition_done,
    output wire allow_prefetch,

    // Fifo gating
    output reg  first_part_consumed,
    input  wire activate_fifo,
    input  wire channel_active
);

    // ========================================
    //               BUFFERS
    // ========================================
    
    localparam BYTES_PER_ROW = WORDS_PER_ROW * STRB_WIDTH;
    localparam WORDS_PER_PARTITION = WORDS_PER_ROW / NUM_RAM_PARTITIONS;
    localparam BYTES_PER_PARTITION = WORDS_PER_PARTITION * STRB_WIDTH;
    localparam PARTITION_WIDTH = $clog2(WORDS_PER_PARTITION+1);

    localparam INPUT_FIFO_B_DEPTH = WORDS_PER_PARTITION;
    localparam INPUT_FIFO_A_DEPTH = WORDS_PER_PARTITION;
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
        .clk(clk), .rstn(rstn),
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
        .clk(clk),
        .rstn(rstn),
    
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
        .clk(clk), .rstn(rstn),
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

    wire [$clog2(INPUT_FIFO_B_DEPTH):0] fifo_b_status_depth;

    assign fifo_b_s_axis_tdata = gate_b_tdata;
    assign fifo_b_s_axis_tvalid = channel_active && gate_b_tvalid;
    assign gate_b_tready = channel_active && fifo_b_s_axis_tready;
    assign fifo_b_s_axis_tlast = gate_b_tlast;

    axis_register #(
        .DATA_WIDTH(DATA_WIDTH),
        .KEEP_ENABLE(0), .LAST_ENABLE(1), .ID_ENABLE(0), .DEST_ENABLE(0), .USER_ENABLE(0),
        .REG_TYPE(SKID)
    ) b_gate (
        .clk(clk), .rstn(rstn),
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
        .clk(clk),
        .rstn(rstn),
    
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
    
        .status_depth(fifo_b_status_depth),
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
        .clk(clk), .rstn(rstn),
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
    
    wire [ELEMENT_WIDTH-1:0] pipe_out_tdata;
    wire                     pipe_out_tvalid;
    wire                     pipe_out_tready;
    wire                     pipe_out_tlast;

    wire [ELEMENT_WIDTH-1:0] fifo_out_s_axis_tdata;
    wire                     fifo_out_s_axis_tvalid;
    wire                     fifo_out_s_axis_tready;
    wire                     fifo_out_s_axis_tlast;
        
    axis_register #(
        .DATA_WIDTH(ELEMENT_WIDTH),
        .KEEP_ENABLE(0), .LAST_ENABLE(1), .ID_ENABLE(0), .DEST_ENABLE(0), .USER_ENABLE(0),
        .REG_TYPE(SKID)
    ) out_skid (
        .clk(clk), .rstn(rstn),
        .s_axis_tdata (pipe_out_tdata),
        .s_axis_tvalid(pipe_out_tvalid),
        .s_axis_tready(pipe_out_tready),
        .s_axis_tlast(pipe_out_tlast),
        .m_axis_tdata (fifo_out_s_axis_tdata),
        .m_axis_tvalid(fifo_out_s_axis_tvalid),
        .m_axis_tready(fifo_out_s_axis_tready),
        .m_axis_tlast(fifo_out_s_axis_tlast)
    );

    axis_fifo #(
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
    ) axis_data_fifo_out (
        .clk(clk),
        .rstn(rstn),
    
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
    
        .pause_req(1'b0),
        .pause_ack(),
    
        .status_depth(),
        .status_depth_commit(),
        .status_overflow(),
        .status_bad_frame(),
        .status_good_frame()
    );

    // ========================================
    //      PARTITION DONE AND PREFETCHING
    // ========================================
    
    reg [PARTITION_WIDTH-1:0] word_count_a;
    reg [PARTITION_WIDTH-1:0] word_count_b;

    always @(posedge clk) begin
        if (!rstn) begin
            word_count_a <= 0;
            word_count_b <= 0;
            first_part_consumed <= 1'b0;
            partition_done <= 1'b0;
        end else begin

            // A counter
            if (fifo_a_s_axis_tvalid && gate_a_tready) begin
                if (word_count_a == WORDS_PER_PARTITION-1) begin
                    word_count_a <= 0;
                    first_part_consumed <= 1'b1;
                end else begin
                    word_count_a <= word_count_a + 1;
                end
            end 

            // B counter
            partition_done <= 1'b0;
            if (fifo_b_s_axis_tvalid && gate_b_tready) begin
                if (word_count_b == WORDS_PER_PARTITION-1) begin
                    partition_done <= 1'b1;
                    word_count_b <= 0;
                end else begin
                    word_count_b <= word_count_b + 1;
                end
            end
        end
    end

    assign allow_prefetch = (fifo_b_status_depth < INPUT_FIFO_B_DEPTH-5);
    
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
        .clk(clk),
        .rstn(rstn),

        .s_axis_a_tdata(pipe_a_tdata),
        .s_axis_a_tvalid(pipe_a_tvalid),
        .s_axis_a_tready(pipe_a_tready),

        .s_axis_b_tdata(pipe_b_tdata),
        .s_axis_b_tvalid(pipe_b_tvalid),
        .s_axis_b_tready(pipe_b_tready),
        
        .m_axis_tdata(pipe_out_tdata),
        .m_axis_tvalid(pipe_out_tvalid),
        .m_axis_tready(pipe_out_tready),
        .m_axis_tlast(pipe_out_tlast)
    );

endmodule
