`timescale 1ns/1ps

module axis_dma_profiler #(
    parameter NUM_DMAS = 4, 
    parameter MAX_DMAS = 4,

    parameter AXIS_S_DATA_WIDTH = 128,
    parameter AXIS_M_DATA_WIDTH = 64,

    parameter AXIL_ADDR_WIDTH = 12,
    parameter AXIL_DATA_WIDTH = 32
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

    input  wire [MAX_DMAS-1:0]        s_tready_v,
    input  wire [MAX_DMAS-1:0]        s_tvalid_v,
    input  wire [MAX_DMAS-1:0]        s_tlast_v,

    input  wire [MAX_DMAS-1:0]        m_tready_v,
    input  wire [MAX_DMAS-1:0]        m_tvalid_v,
    input  wire [MAX_DMAS-1:0]        m_tlast_v
);

    // -------- global stats --------
    reg  [MAX_DMAS-1:0] running;
    reg  [MAX_DMAS-1:0] running_m;

    wire any_hs_s      = |(s_tvalid_v & s_tready_v);
    wire any_running_s = |running;
    wire any_running_m = |running_m;

    // Track first s_axis hs to last s_axis hs
    reg        g_ss_active, g_ss_valid;
    reg [63:0] g_ss_cycles;

    always @(posedge axis_clk) begin
        if (!axis_aresetn) begin
            g_ss_active <= 1'b0; 
            g_ss_valid  <= 1'b0;
            g_ss_cycles <= 64'd0;
        end else begin
            if (!g_ss_active && !any_running_s && any_hs_s) begin
                g_ss_active <= 1'b1;
                g_ss_valid  <= 1'b0;
                g_ss_cycles <= 64'd1;
            end else if (g_ss_active) begin
                if (!any_running_s) begin
                    g_ss_active  <= 1'b0;
                    g_ss_valid   <= 1'b1;
                end else begin
                    g_ss_cycles <= g_ss_cycles + 1;
                end
            end
        end
    end

    // Track first s_axis hs to last m_axis hs
    reg        g_sm_active, g_sm_valid;
    reg [63:0] g_sm_cycles;

    always @(posedge axis_clk) begin
        if (!axis_aresetn) begin
            g_sm_active <= 1'b0; 
            g_sm_valid  <= 1'b0;
            g_sm_cycles <= 64'd0;
        end else begin
            if (!g_sm_active && !any_running_m && any_hs_s) begin
                g_sm_active <= 1'b1;
                g_sm_valid  <= 1'b0;
                g_sm_cycles <= 64'd1;
            end else if (g_sm_active) begin
                if (!any_running_m) begin
                    g_sm_active  <= 1'b0;
                    g_sm_valid   <= 1'b1;
                end else begin
                    g_sm_cycles <= g_sm_cycles + 1;
                end
            end
        end
    end

    // -------- per channel stats --------
    localparam AXIS_S_DATA_BYTES = AXIS_S_DATA_WIDTH/8;
    localparam AXIS_M_DATA_BYTES = AXIS_M_DATA_WIDTH/8;

    reg  [MAX_DMAS-1:0] have_result;
    reg  [63:0]         cycle_cnt       [0:MAX_DMAS-1];
    reg  [63:0]         beat_cnt        [0:MAX_DMAS-1];
    reg  [63:0]         byte_cnt        [0:MAX_DMAS-1];
    reg  [31:0]         pkt_cnt         [0:MAX_DMAS-1];
    reg  [63:0]         tready_low_cnt  [0:MAX_DMAS-1];
    reg  [63:0]         tvalid_low_cnt  [0:MAX_DMAS-1];
    reg  [63:0]         first_hs_offset [0:MAX_DMAS-1];

    reg seen_hs [0:MAX_DMAS-1];

    reg         armed      [0:MAX_DMAS-1]; // seen tlast, waiting for next packet start
    reg  [63:0] idle_cnt   [0:MAX_DMAS-1];
    reg  [63:0] gap_last   [0:MAX_DMAS-1];
    reg  [63:0] gap_total  [0:MAX_DMAS-1];
    reg  [63:0] gap_min    [0:MAX_DMAS-1];
    reg  [63:0] gap_max    [0:MAX_DMAS-1];
    reg  [31:0] gap_count  [0:MAX_DMAS-1];
    reg         gap_valid  [0:MAX_DMAS-1];
    reg  [63:0] busy_total [0:MAX_DMAS-1];

    genvar ch;
    generate
        for (ch = 0; ch < MAX_DMAS; ch = ch + 1) begin : g_prof

            wire active = (ch < NUM_DMAS);

            wire hs  = s_tvalid_v[ch] && s_tready_v[ch];
            wire hsm = m_tvalid_v[ch] && m_tready_v[ch];

            always @(posedge axis_clk) begin
                if (!axis_aresetn || !active) begin
                    seen_hs[ch]     <= 1'b0;
                    running[ch]     <= 1'b0;
                    have_result[ch] <= 1'b0;

                    cycle_cnt[ch]   <= 64'd0;
                    beat_cnt[ch]    <= 64'd0;
                    byte_cnt[ch]    <= 64'd0;
                    pkt_cnt[ch]     <= 32'd0;

                    tready_low_cnt[ch] <= 64'd0;
                    tvalid_low_cnt[ch] <= 64'd0;

                    first_hs_offset[ch] <= 64'd0;

                    armed[ch]       <= 1'b0;
                    idle_cnt[ch]    <= 64'd0;
                    gap_last[ch]    <= 64'd0;
                    gap_total[ch]   <= 64'd0;
                    gap_min[ch]     <= 64'hFFFF_FFFF_FFFF_FFFF;
                    gap_max[ch]     <= 64'd0;
                    gap_count[ch]   <= 32'd0;
                    gap_valid[ch]   <= 1'b0;
                    busy_total[ch]  <= 64'd0;

                    running_m[ch]   <= 1'b0;

                end else begin
                    if (seen_hs[ch] && !running[ch] && armed[ch])
                        idle_cnt[ch] <= idle_cnt[ch] + 1;

                    if (!running[ch] && hs) begin

                        seen_hs[ch]         <= 1'b1;
                        first_hs_offset[ch] <= g_ss_cycles; // see when channel starts
                                                            // relative to other channels
                        running[ch]     <= 1'b1;
                        have_result[ch] <= 1'b0;
                        cycle_cnt[ch]   <= 64'd1; // include first cycle
                        beat_cnt[ch]    <= 64'd1; // include first beat
                        byte_cnt[ch]    <= AXIS_S_DATA_BYTES;

                        tready_low_cnt[ch] <= 64'd0;
                        tvalid_low_cnt[ch] <= 64'd0;

                        if (armed[ch]) begin
                            gap_last[ch] <= idle_cnt[ch];
                            gap_total[ch] <= gap_total[ch] + idle_cnt[ch];
                            gap_count[ch] <= gap_count[ch] + 1;
                            // min/max with valid gate
                            if (!gap_valid[ch] || idle_cnt[ch] < gap_min[ch]) gap_min[ch] <= idle_cnt[ch];
                            if (!gap_valid[ch] || idle_cnt[ch] > gap_max[ch]) gap_max[ch] <= idle_cnt[ch];
                            gap_valid[ch] <= 1'b1;
                        end
                        armed[ch]    <= 1'b0;
                        idle_cnt[ch] <= 64'd0;
                    end else if (running[ch]) begin

                        cycle_cnt[ch] <= cycle_cnt[ch] + 1;

                        if (hs) begin
                            beat_cnt[ch] <= beat_cnt[ch] + 1;
                            byte_cnt[ch] <= byte_cnt[ch] + AXIS_S_DATA_BYTES;
                            if (s_tlast_v[ch]) begin
                                running[ch]     <= 1'b0;
                                have_result[ch] <= 1'b1;
                                pkt_cnt[ch]     <= pkt_cnt[ch] + 1;

                                armed[ch]    <= 1'b1;
                                idle_cnt[ch] <= 64'd0;

                                busy_total[ch] <= busy_total[ch] + cycle_cnt[ch];
                            end
                        end 

                        if (!s_tvalid_v[ch])
                            tvalid_low_cnt[ch] <= tvalid_low_cnt[ch] + 1;
                        if (!s_tready_v[ch])
                            tready_low_cnt[ch] <= tready_low_cnt[ch] + 1;

                    end

                    if (!running_m[ch] && hs)
                        running_m[ch] <= 1'b1;
                    if (hsm && m_tlast_v[ch])
                        running_m[ch] <= 1'b0;

                end
            end
        end
    endgenerate

    // -------- AXIL register --------
    wire [AXIL_ADDR_WIDTH-1:0] reg_rd_addr;
    wire                       reg_rd_en;
    reg  [AXIL_DATA_WIDTH-1:0] reg_rd_data;

    axil_reg_if_rd #(
        .ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .DATA_WIDTH(AXIL_DATA_WIDTH)
    ) axil_rd_i (
        .clk           (axis_clk),
        .rstn          (axis_aresetn),
        .s_axil_araddr (s_axil_araddr),
        .s_axil_arvalid(s_axil_arvalid),
        .s_axil_arready(s_axil_arready),
        .s_axil_rdata  (s_axil_rdata),
        .s_axil_rresp  (s_axil_rresp),
        .s_axil_rvalid (s_axil_rvalid),
        .s_axil_rready (s_axil_rready),
        .reg_rd_addr   (reg_rd_addr),
        .reg_rd_en     (reg_rd_en),
        .reg_rd_data   (reg_rd_data)
    );

    // -------- decode: ch window + word offset --------
    localparam CH_BITS        = $clog2(MAX_DMAS);
    localparam BYTES_PER_WIN  = 'h100; // 0x100 bytes per channel window
    localparam WORD_BYTES     = AXIL_DATA_WIDTH/8;
    localparam WORDS_PER_WIN  = BYTES_PER_WIN / WORD_BYTES;
    localparam WIN_WORD_BITS  = $clog2(WORDS_PER_WIN);
    localparam SHIFT          = $clog2(WORD_BYTES);

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

    wire [63:0] tready_low_mux = get64(ch_sel, tready_low_cnt[0], tready_low_cnt[1], tready_low_cnt[2], tready_low_cnt[3]);
    wire [63:0] tvalid_low_mux = get64(ch_sel, tvalid_low_cnt[0], tvalid_low_cnt[1], tvalid_low_cnt[2], tvalid_low_cnt[3]);

    wire [63:0] first_hs_offset_mux = get64(ch_sel, first_hs_offset[0], first_hs_offset[1], first_hs_offset[2], first_hs_offset[3]);

    wire [63:0] busy_total_mux = get64(ch_sel, busy_total[0], busy_total[1], busy_total[2], busy_total[3]);

    wire [63:0] gap_last_mux  = get64(ch_sel, gap_last [0], gap_last [1], gap_last [2], gap_last [3]);
    wire [63:0] gap_total_mux = get64(ch_sel, gap_total[0], gap_total[1], gap_total[2], gap_total[3]);
    wire [63:0] gap_min_mux   = get64(ch_sel, gap_min  [0], gap_min  [1], gap_min  [2], gap_min  [3]);
    wire [63:0] gap_max_mux   = get64(ch_sel, gap_max  [0], gap_max  [1], gap_max  [2], gap_max  [3]);
    wire [31:0] gap_count_mux = get32(ch_sel, gap_count[0], gap_count[1], gap_count[2], gap_count[3]);

    localparam [5:0] CHANNEL_BASE = 6'h00;
    localparam [5:0] GAP_BASE     = 6'h10;
    localparam [5:0] GLOBAL_BASE  = 6'h1A;

    always @* begin
        case (word_off)

            /* ========================== REGISTER MAP ========================== */

            // PER CHANNEL PER PACKET (window offsets are within each 0x100-byte channel window)
            (CHANNEL_BASE+6'h00): reg_rd_data = {30'd0, running[ch_sel], have_result[ch_sel]}; // [0x00] Status
            (CHANNEL_BASE+6'h01): reg_rd_data = cycles_mux[31:0];                              // [0x04] Packet cycle count (LO)
            (CHANNEL_BASE+6'h02): reg_rd_data = cycles_mux[63:32];                             // [0x08] Packet cycle count (HI)
            (CHANNEL_BASE+6'h03): reg_rd_data = beats_mux[31:0];                               // [0x0C] Packet beat count (LO)
            (CHANNEL_BASE+6'h04): reg_rd_data = beats_mux[63:32];                              // [0x10] Packet beat count (HI)
            (CHANNEL_BASE+6'h05): reg_rd_data = bytes_mux[31:0];                               // [0x14] Packet byte count (LO)
            (CHANNEL_BASE+6'h06): reg_rd_data = bytes_mux[63:32];                              // [0x18] Packet byte count (HI)
            (CHANNEL_BASE+6'h07): reg_rd_data = pkts_mux;                                      // [0x1C] Packet counter
            
            (CHANNEL_BASE+6'h08): reg_rd_data = tready_low_mux[31:0];                          // [0x20] Cycles with TREADY=0 while running (LO)
            (CHANNEL_BASE+6'h09): reg_rd_data = tready_low_mux[63:32];                         // [0x24] Cycles with TREADY=0 while running (HI)
            (CHANNEL_BASE+6'h0A): reg_rd_data = tvalid_low_mux[31:0];                          // [0x28] Cycles with TVALID=0 while running (LO)
            (CHANNEL_BASE+6'h0B): reg_rd_data = tvalid_low_mux[63:32];                         // [0x2C] Cycles with TVALID=0 while running (HI)

            (CHANNEL_BASE+6'h0C): reg_rd_data = first_hs_offset_mux[31:0];                     // [0x30] First hs relative to global first hs (LO)
            (CHANNEL_BASE+6'h0D): reg_rd_data = first_hs_offset_mux[63:32];                    // [0x34] First hs relative to global first hs (HI)
            
            (CHANNEL_BASE+6'h0E): reg_rd_data = busy_total_mux[31:0];                          // [0x38] Sum of busy cycles over all packets (LO)
            (CHANNEL_BASE+6'h0F): reg_rd_data = busy_total_mux[63:32];                         // [0x3C] Sum of busy cycles over all packets (HI)
            
            // PER CHANNEL BETWEEN PACKETS (idle/gap statistics between packet end and next packet start)
            (GAP_BASE+6'h00): reg_rd_data = {30'd0, armed[ch_sel], gap_valid[ch_sel]};         // [0x40] Gap status
            (GAP_BASE+6'h01): reg_rd_data = gap_last_mux [31:0];                               // [0x44] Last inter-packet gap (cycles) (LO)
            (GAP_BASE+6'h02): reg_rd_data = gap_last_mux [63:32];                              // [0x48] Last inter-packet gap (cycles) (HI)
            (GAP_BASE+6'h03): reg_rd_data = gap_total_mux[31:0];                               // [0x4C] Total accumulated inter-packet gap (LO)
            (GAP_BASE+6'h04): reg_rd_data = gap_total_mux[63:32];                              // [0x50] Total accumulated inter-packet gap (HI)
            (GAP_BASE+6'h05): reg_rd_data = gap_min_mux  [31:0];                               // [0x54] Minimum observed inter-packet gap (LO)
            (GAP_BASE+6'h06): reg_rd_data = gap_min_mux  [63:32];                              // [0x58] Minimum observed inter-packet gap (HI)
            (GAP_BASE+6'h07): reg_rd_data = gap_max_mux  [31:0];                               // [0x5C] Maximum observed inter-packet gap (LO)
            (GAP_BASE+6'h08): reg_rd_data = gap_max_mux  [63:32];                              // [0x60] Maximum observed inter-packet gap (HI)
            (GAP_BASE+6'h09): reg_rd_data = gap_count_mux;                                     // [0x64] Number of inter-packet gaps measured
            
            // GLOBAL COUNTERS (aliased in every channel window; same values regardless of ch_sel)
            (GLOBAL_BASE+6'h00): reg_rd_data = {30'd0, g_ss_active, g_ss_valid};               // [0x68] Global S->S status
            (GLOBAL_BASE+6'h01): reg_rd_data = g_ss_cycles[31:0];                              // [0x6C] Global S->S cycle count (LO)
            (GLOBAL_BASE+6'h02): reg_rd_data = g_ss_cycles[63:32];                             // [0x70] Global S->S cycle count (HI)
            
            (GLOBAL_BASE+6'h03): reg_rd_data = {30'd0, g_sm_active, g_sm_valid};               // [0x74] Global S->M status
            (GLOBAL_BASE+6'h04): reg_rd_data = g_sm_cycles[31:0];                              // [0x78] Global S->M cycle count (LO)
            (GLOBAL_BASE+6'h05): reg_rd_data = g_sm_cycles[63:32];                             // [0x7C] Global S->M cycle count (HI)
            
            /* ================================================================== */

            default: reg_rd_data = {AXIL_DATA_WIDTH{1'b0}};
        endcase
    end

endmodule
