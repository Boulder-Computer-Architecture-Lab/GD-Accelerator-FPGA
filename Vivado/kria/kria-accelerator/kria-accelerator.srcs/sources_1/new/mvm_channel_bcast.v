`timescale 1ns / 1ps

module mvm_channel_bcast #(
    parameter DATA_WIDTH         = 128,
    parameter ADDR_WIDTH         = 64,
    parameter STRB_WIDTH         = DATA_WIDTH / 8,
    parameter ID_WIDTH           = 8,
    parameter TAG                = 0,

    parameter ELEMENT_WIDTH      = 64,
    parameter ELEMENTS_PER_WORD  = DATA_WIDTH / ELEMENT_WIDTH, // MUST BE A POWER OF 2!
    
    parameter ELEMENTS_PER_ROW = 17048,
    parameter WORDS_PER_ROW = ELEMENTS_PER_ROW / ELEMENTS_PER_WORD,
    parameter NUM_ROWS = 17048,

    parameter NUM_CHANNELS       = 4,    
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

    // Input stream B
    input  wire [DATA_WIDTH-1:0] s_axis_b_tdata,
    input  wire                  s_axis_b_tvalid,
    output wire                  s_axis_b_tready,
    input  wire                  s_axis_b_tlast,
    
    // Output result stream
    output wire [ELEMENT_WIDTH-1:0] m_axis_tdata,
    output wire                     m_axis_tvalid,
    input  wire                     m_axis_tready,
    output wire                     m_axis_tlast
);

    // ========================================
    //               BUFFERS
    // ========================================

    localparam INPUT_FIFO_B_DEPTH = 2048;
    localparam INPUT_FIFO_A_DEPTH = 2048;
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
    assign fifo_a_s_axis_tvalid = gate_a_tvalid;
    assign gate_a_tready = fifo_a_s_axis_tready;
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
        .clk(s_clk),
        .rstn(s_rstn),
    
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
    //                COUNTERS
    // ========================================
    
    localparam ROW_WIDTH = $clog2(WORDS_PER_ROW+1);
    localparam NUM_ROWS_WIDTH = $clog2(ROWS_PER_CHANNEL+1);
    
    reg [ROW_WIDTH-1:0] word_count_a;
    reg [ROW_WIDTH-1:0] word_count_b;

    reg [NUM_ROWS_WIDTH-1:0] row_count_a;
    reg [NUM_ROWS_WIDTH-1:0] row_count_b;
    
    always @(posedge s_clk) begin
        if (!s_rstn) begin
            word_count_a <= 0;
            word_count_b <= 0;
            row_count_a  <= 0;
            row_count_b  <= 0;
        end else begin

            // A counter
            if (fifo_a_s_axis_tvalid && gate_a_tready) begin
                if (word_count_a == WORDS_PER_ROW-1) begin
                    word_count_a <= 0;
                    row_count_a <= row_count_a + 1;
                end else begin
                    word_count_a <= word_count_a + 1;
                end
            end 

            // B counter
            if (fifo_b_s_axis_tvalid && gate_b_tready) begin
                if (word_count_b == WORDS_PER_ROW-1) begin
                    word_count_b <= 0;
                    row_count_b <= row_count_b + 1;
                end else begin
                    word_count_b <= word_count_b + 1;
                end
            end
        end
    end

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
