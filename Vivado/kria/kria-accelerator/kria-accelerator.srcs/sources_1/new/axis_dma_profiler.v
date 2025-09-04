`timescale 1ns/1ps

module axis_dma_profiler #(
    parameter integer NUM_DMAS        = 4, 
    parameter integer AXIL_ADDR_WIDTH = 12,
    parameter integer AXIL_DATA_WIDTH = 32,

    // Per-channel data widths
    parameter integer DATA_WIDTH0 = 64,
    parameter integer DATA_WIDTH1 = 64,
    parameter integer DATA_WIDTH2 = 64,
    parameter integer DATA_WIDTH3 = 64
)(
    input  wire                       axis_clk,
    input  wire                       axis_aresetn, 

    input  wire                       s_axil_aclk,
    input  wire                       s_axil_aresetn,

    input  wire [AXIL_ADDR_WIDTH-1:0] s_axil_awaddr,
    input  wire                       s_axil_awvalid,
    output wire                       s_axil_awready,
    input  wire [AXIL_DATA_WIDTH-1:0] s_axil_wdata,
    input  wire                       s_axil_wvalid,
    output wire                       s_axil_wready,
    output wire [1:0]                 s_axil_bresp,
    output wire                       s_axil_bvalid,
    input  wire                       s_axil_bready,
    input  wire [AXIL_ADDR_WIDTH-1:0] s_axil_araddr,
    input  wire                       s_axil_arvalid,
    output wire                       s_axil_arready,
    output wire [AXIL_DATA_WIDTH-1:0] s_axil_rdata,
    output wire [1:0]                 s_axil_rresp,
    output wire                       s_axil_rvalid,
    input  wire                       s_axil_rready,

    input  wire [DATA_WIDTH0-1:0]     s0_axis_tdata,
    input  wire                       s0_axis_tvalid,
    input  wire                       s0_axis_tlast,
    output wire                       s0_axis_tready,

    output wire [DATA_WIDTH0-1:0]     m0_axis_tdata,
    output wire                       m0_axis_tvalid,
    output wire                       m0_axis_tlast,
    input  wire                       m0_axis_tready,

    input  wire [DATA_WIDTH1-1:0]     s1_axis_tdata,
    input  wire                       s1_axis_tvalid,
    input  wire                       s1_axis_tlast,
    output wire                       s1_axis_tready,

    output wire [DATA_WIDTH1-1:0]     m1_axis_tdata,
    output wire                       m1_axis_tvalid,
    output wire                       m1_axis_tlast,
    input  wire                       m1_axis_tready,

    input  wire [DATA_WIDTH2-1:0]     s2_axis_tdata,
    input  wire                       s2_axis_tvalid,
    input  wire                       s2_axis_tlast,
    output wire                       s2_axis_tready,

    output wire [DATA_WIDTH2-1:0]     m2_axis_tdata,
    output wire                       m2_axis_tvalid,
    output wire                       m2_axis_tlast,
    input  wire                       m2_axis_tready,

    input  wire [DATA_WIDTH3-1:0]     s3_axis_tdata,
    input  wire                       s3_axis_tvalid,
    input  wire                       s3_axis_tlast,
    output wire                       s3_axis_tready,

    output wire [DATA_WIDTH3-1:0]     m3_axis_tdata,
    output wire                       m3_axis_tvalid,
    output wire                       m3_axis_tlast,
    input  wire                       m3_axis_tready
);

    // CH0
    assign m0_axis_tdata  = s0_axis_tdata;
    assign m0_axis_tvalid = s0_axis_tvalid;
    assign m0_axis_tlast  = s0_axis_tlast;
    assign s0_axis_tready = m0_axis_tready;
    // CH1
    assign m1_axis_tdata  = s1_axis_tdata;
    assign m1_axis_tvalid = s1_axis_tvalid;
    assign m1_axis_tlast  = s1_axis_tlast;
    assign s1_axis_tready = m1_axis_tready;
    // CH2
    assign m2_axis_tdata  = s2_axis_tdata;
    assign m2_axis_tvalid = s2_axis_tvalid;
    assign m2_axis_tlast  = s2_axis_tlast;
    assign s2_axis_tready = m2_axis_tready;
    // CH3
    assign m3_axis_tdata  = s3_axis_tdata;
    assign m3_axis_tvalid = s3_axis_tvalid;
    assign m3_axis_tlast  = s3_axis_tlast;
    assign s3_axis_tready = m3_axis_tready;

    localparam integer MAX_CH = 4;
    wire [MAX_CH-1:0] tvalid_v = {s3_axis_tvalid, s2_axis_tvalid, s1_axis_tvalid, s0_axis_tvalid};
    wire [MAX_CH-1:0] tready_v = {s3_axis_tready, s2_axis_tready, s1_axis_tready, s0_axis_tready};
    wire [MAX_CH-1:0] tlast_v  = {s3_axis_tlast,  s2_axis_tlast,  s1_axis_tlast,  s0_axis_tlast};

    // Bytes per beat per channel
    localparam integer DATA_BYTES0 = DATA_WIDTH0/8;
    localparam integer DATA_BYTES1 = DATA_WIDTH1/8;
    localparam integer DATA_BYTES2 = DATA_WIDTH2/8;
    localparam integer DATA_BYTES3 = DATA_WIDTH3/8;

    reg  [MAX_CH-1:0] running, have_result;
    reg  [63:0]       cycle_cnt [0:MAX_CH-1];
    reg  [63:0]       beat_cnt  [0:MAX_CH-1];
    reg  [63:0]       byte_cnt  [0:MAX_CH-1];
    reg  [31:0]       pkt_cnt   [0:MAX_CH-1];

    genvar ch;
    generate
        for (ch = 0; ch < MAX_CH; ch = ch + 1) begin : g_prof
            wire active = (ch < NUM_DMAS);
            wire hs     = tvalid_v[ch] & tready_v[ch];

            wire [15:0] BYTES_THIS =
                (ch==0) ? DATA_BYTES0[15:0] :
                (ch==1) ? DATA_BYTES1[15:0] :
                (ch==2) ? DATA_BYTES2[15:0] : DATA_BYTES3[15:0];

            always @(posedge axis_clk) begin
                if (!axis_aresetn) begin
                    running[ch]     <= 1'b0;
                    have_result[ch] <= 1'b0;
                    cycle_cnt[ch]   <= 64'd0;
                    beat_cnt[ch]    <= 64'd0;
                    byte_cnt[ch]    <= 64'd0;
                    pkt_cnt[ch]     <= 32'd0;
                end else if (!active) begin
                    // keep pass-through, just zero the stats
                    running[ch]     <= 1'b0;
                    have_result[ch] <= 1'b0;
                    cycle_cnt[ch]   <= 64'd0;
                    beat_cnt[ch]    <= 64'd0;
                    byte_cnt[ch]    <= 64'd0;
                    pkt_cnt[ch]     <= 32'd0;
                end else begin
                    if (!running[ch] && hs) begin
                        running[ch]     <= 1'b1;
                        have_result[ch] <= 1'b0;
                        cycle_cnt[ch]   <= 64'd1;          // include first cycle
                        beat_cnt[ch]    <= 64'd1;          // include first beat
                        byte_cnt[ch]    <= BYTES_THIS;
                    end else if (running[ch]) begin
                        cycle_cnt[ch] <= cycle_cnt[ch] + 1;
                        if (hs) begin
                            beat_cnt[ch] <= beat_cnt[ch] + 1;
                            byte_cnt[ch] <= byte_cnt[ch] + BYTES_THIS;
                            if (tlast_v[ch]) begin
                                running[ch]     <= 1'b0;
                                have_result[ch] <= 1'b1;
                                pkt_cnt[ch]     <= pkt_cnt[ch] + 1;
                            end
                        end
                    end
                end
            end
        end
    endgenerate

    wire [AXIL_ADDR_WIDTH-1:0] m_axil_awaddr;
    wire                       m_axil_awvalid;
    wire                       m_axil_awready;
    wire [AXIL_DATA_WIDTH-1:0] m_axil_wdata;
    wire                       m_axil_wvalid;
    wire                       m_axil_wready;
    wire [1:0]                 m_axil_bresp;
    wire                       m_axil_bvalid;
    wire                       m_axil_bready;
    wire [AXIL_ADDR_WIDTH-1:0] m_axil_araddr;
    wire                       m_axil_arvalid;
    wire                       m_axil_arready;
    wire [AXIL_DATA_WIDTH-1:0] m_axil_rdata;
    wire [1:0]                 m_axil_rresp;
    wire                       m_axil_rvalid;
    wire                       m_axil_rready;

    axil_cdc #(
        .DATA_WIDTH (AXIL_DATA_WIDTH),
        .ADDR_WIDTH (AXIL_ADDR_WIDTH)
    ) axil_cdc_i (
        .s_clk          (s_axil_aclk),
        .s_rstn         (s_axil_aresetn),
        .s_axil_awaddr  (s_axil_awaddr),
        .s_axil_awvalid (s_axil_awvalid),
        .s_axil_awready (s_axil_awready),
        .s_axil_wdata   (s_axil_wdata),
        .s_axil_wvalid  (s_axil_wvalid),
        .s_axil_wready  (s_axil_wready),
        .s_axil_bresp   (s_axil_bresp),
        .s_axil_bvalid  (s_axil_bvalid),
        .s_axil_bready  (s_axil_bready),
        .s_axil_araddr  (s_axil_araddr),
        .s_axil_arvalid (s_axil_arvalid),
        .s_axil_arready (s_axil_arready),
        .s_axil_rdata   (s_axil_rdata),
        .s_axil_rresp   (s_axil_rresp),
        .s_axil_rvalid  (s_axil_rvalid),
        .s_axil_rready  (s_axil_rready),

        .m_clk          (axis_clk),
        .m_rstn         (axis_aresetn),
        .m_axil_awaddr  (m_axil_awaddr),
        .m_axil_awvalid (m_axil_awvalid),
        .m_axil_awready (m_axil_awready),
        .m_axil_wdata   (m_axil_wdata),
        .m_axil_wvalid  (m_axil_wvalid),
        .m_axil_wready  (m_axil_wready),
        .m_axil_bresp   (m_axil_bresp),
        .m_axil_bvalid  (m_axil_bvalid),
        .m_axil_bready  (m_axil_bready),
        .m_axil_araddr  (m_axil_araddr),
        .m_axil_arvalid (m_axil_arvalid),
        .m_axil_arready (m_axil_arready),
        .m_axil_rdata   (m_axil_rdata),
        .m_axil_rresp   (m_axil_rresp),
        .m_axil_rvalid  (m_axil_rvalid),
        .m_axil_rready  (m_axil_rready)
    );

    wire [AXIL_ADDR_WIDTH-1:0] reg_rd_addr;
    wire                       reg_rd_en;
    reg  [AXIL_DATA_WIDTH-1:0] reg_rd_data;

    axil_reg_if #(
        .ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .DATA_WIDTH(AXIL_DATA_WIDTH)
    ) axil_rd_i (
        .clk           (axis_clk),
        .rstn          (axis_aresetn),
        .s_axil_awaddr (m_axil_awaddr),
        .s_axil_awvalid(m_axil_awvalid),
        .s_axil_awready(m_axil_awready),
        .s_axil_wdata  (m_axil_wdata),
        .s_axil_wvalid (m_axil_wvalid),
        .s_axil_wready (m_axil_wready),
        .s_axil_bresp  (m_axil_bresp),
        .s_axil_bvalid (m_axil_bvalid),
        .s_axil_bready (m_axil_bready),
        .s_axil_araddr (m_axil_araddr),
        .s_axil_arvalid(m_axil_arvalid),
        .s_axil_arready(m_axil_arready),
        .s_axil_rdata  (m_axil_rdata),
        .s_axil_rresp  (m_axil_rresp),
        .s_axil_rvalid (m_axil_rvalid),
        .s_axil_rready (m_axil_rready),
        .reg_rd_addr   (reg_rd_addr),
        .reg_rd_en     (reg_rd_en),
        .reg_rd_data   (reg_rd_data)
    );

    // -------- decode: ch window + word offset --------
    localparam integer CH_BITS        = $clog2(MAX_CH);
    localparam integer BYTES_PER_WIN  = 'h100; // 0x100 bytes per channel window
    localparam integer WORD_BYTES     = AXIL_DATA_WIDTH/8;
    localparam integer WORDS_PER_WIN  = BYTES_PER_WIN / WORD_BYTES;
    localparam integer WIN_WORD_BITS  = $clog2(WORDS_PER_WIN);
    localparam integer SHIFT          = $clog2(WORD_BYTES);

    wire [AXIL_ADDR_WIDTH-1:0] waddr = reg_rd_addr >> SHIFT;
    wire [WIN_WORD_BITS-1:0]   word_off = waddr[WIN_WORD_BITS-1:0];
    wire [CH_BITS-1:0]         ch_sel   = waddr[WIN_WORD_BITS + CH_BITS - 1 : WIN_WORD_BITS];

    function [63:0] get64;
        input [1:0] ch; input [63:0] a0,a1,a2,a3;
        begin case (ch) 2'd0:get64=a0; 2'd1:get64=a1; 2'd2:get64=a2; default:get64=a3; endcase end
    endfunction
    function [31:0] get32;
        input [1:0] ch; input [31:0] a0,a1,a2,a3;
        begin case (ch) 2'd0:get32=a0; 2'd1:get32=a1; 2'd2:get32=a2; default:get32=a3; endcase end
    endfunction

    wire [63:0] cycles_mux = get64(ch_sel, cycle_cnt[0], cycle_cnt[1], cycle_cnt[2], cycle_cnt[3]);
    wire [63:0] beats_mux  = get64(ch_sel, beat_cnt [0], beat_cnt [1], beat_cnt [2], beat_cnt [3]);
    wire [63:0] bytes_mux  = get64(ch_sel, byte_cnt [0], byte_cnt [1], byte_cnt [2], byte_cnt [3]);
    wire [31:0] pkts_mux   = get32(ch_sel, pkt_cnt  [0], pkt_cnt  [1], pkt_cnt  [2], pkt_cnt  [3]);

    always @* begin
        case (word_off)
            6'h00: reg_rd_data = {30'd0, running[ch_sel], have_result[ch_sel]}; // STATUS
            6'h01: reg_rd_data = cycles_mux[31:0];
            6'h02: reg_rd_data = cycles_mux[63:32];
            6'h03: reg_rd_data = beats_mux[31:0];
            6'h04: reg_rd_data = beats_mux[63:32];
            6'h05: reg_rd_data = bytes_mux[31:0];
            6'h06: reg_rd_data = bytes_mux[63:32];
            6'h07: reg_rd_data = pkts_mux;
            default: reg_rd_data = {AXIL_DATA_WIDTH{1'b0}};
        endcase
    end

endmodule
