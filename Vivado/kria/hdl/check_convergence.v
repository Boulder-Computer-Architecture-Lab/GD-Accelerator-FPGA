`timescale 1ns / 1ps

module check_convergence #(
    parameter ELEMENT_WIDTH = 64,
    parameter ELEMENTS_PER_ROW = 192
)(

    input  wire clk,
    input  wire rstn,

    // Initial guess for vector
    input  wire [ELEMENT_WIDTH-1:0] vec_init_axis_tdata,
    input  wire                     vec_init_axis_tvalid,
    output wire                     vec_init_axis_tready,
    input  wire                     vec_init_axis_tlast,

    // This iteration's vector
    input  wire [ELEMENT_WIDTH-1:0] vec_next_axis_tdata,
    input  wire                     vec_next_axis_tvalid,
    output wire                     vec_next_axis_tready,
    input  wire                     vec_next_axis_tlast,

    // This iteration's error
    input  wire [ELEMENT_WIDTH-1:0] err_axis_tdata,
    input  wire                     err_axis_tvalid,
    output wire                     err_axis_tready,

    // Input vector for next iteration
    output wire [ELEMENT_WIDTH-1:0] vec_in_axis_tdata,
    output wire                     vec_in_axis_tvalid,
    input  wire                     vec_in_axis_tready,
    output wire                     vec_in_axis_tlast,

    // Result stream
    output wire [ELEMENT_WIDTH-1:0] vec_result_axis_tdata,
    output wire                     vec_result_axis_tvalid,
    input  wire                     vec_result_axis_tready,
    output wire                     vec_result_axis_tlast
);
    // =============================================================
    //                      BUFFER VEC_NEXT
    // =============================================================

    wire [ELEMENT_WIDTH-1:0] fifo_out_axis_tdata;
    wire                     fifo_out_axis_tvalid;
    wire                     fifo_out_axis_tready;
    wire                     fifo_out_axis_tlast;

    axis_fifo #(
        .DEPTH(ELEMENTS_PER_ROW),
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
    ) vec_next_fifo (
        .clk(clk),
        .rstn(rstn),
    
        .s_axis_tdata (vec_next_axis_tdata ),
        .s_axis_tkeep (),
        .s_axis_tvalid(vec_next_axis_tvalid),
        .s_axis_tready(vec_next_axis_tready),
        .s_axis_tlast (vec_next_axis_tlast ),
        .s_axis_tid   (8'b0),
        .s_axis_tdest (8'b0),
        .s_axis_tuser (1'b0),
    
        .m_axis_tdata (fifo_out_axis_tdata ),
        .m_axis_tkeep (),
        .m_axis_tvalid(fifo_out_axis_tvalid),
        .m_axis_tready(fifo_out_axis_tready),
        .m_axis_tlast (fifo_out_axis_tlast ), // err doesn't need tlast
        .m_axis_tid   (),
        .m_axis_tdest (),
        .m_axis_tuser (),
    
        .pause_req(1'b0),
        .pause_ack(),
    
        .status_depth       (),
        .status_depth_commit(),
        .status_overflow    (),
        .status_bad_frame   (),
        .status_good_frame  ()
    );

    // =============================================================
    //                      CONVERGENCE CHECK
    // =============================================================

    localparam [63:0] TOL64 = 64'h3F847AE147AE147B; // 0.01 as fp64
    localparam [31:0] TOL32 = 32'h3C23D70A;         // 0.01 as fp32
    localparam [15:0] TOL16 = 16'h211F;             // 0.01 as fp16

    wire [7:0] cmp_out_tdata;
    wire       cmp_out_tvalid;

    generate
        if (ELEMENT_WIDTH == 64) begin: cmp64_gen

            fp64_cmplt cmp_inst (
                .aclk(clk), .aresetn(rstn),

                .s_axis_a_tdata(err_axis_tdata),
                .s_axis_a_tvalid(err_axis_tvalid),
                .s_axis_a_tready(err_axis_tready),

                .s_axis_b_tdata(TOL64),
                .s_axis_b_tvalid(1'b1),
                .s_axis_b_tready(),

                .m_axis_result_tdata(cmp_out_tdata),
                .m_axis_result_tvalid(cmp_out_tvalid),
                .m_axis_result_tready(1'b1)
            );
        end else if (ELEMENT_WIDTH == 32) begin: cmp32_gen

            localparam TOLERANCE  = 32'h3C23D70A; // 0.01 as fp32

            fp32_cmplt cmp_inst (
                .aclk(clk), .aresetn(rstn),

                .s_axis_a_tdata(err_axis_tdata),
                .s_axis_a_tvalid(err_axis_tvalid),
                .s_axis_a_tready(err_axis_tready),

                .s_axis_b_tdata(TOL32),
                .s_axis_b_tvalid(1'b1),
                .s_axis_b_tready(),

                .m_axis_result_tdata(cmp_out_tdata),
                .m_axis_result_tvalid(cmp_out_tvalid),
                .m_axis_result_tready(1'b1)
            );
        end else if (ELEMENT_WIDTH == 16) begin: cmp16_gen

            localparam TOLERANCE  = 16'h211F; // 0.01 as fp16

            fp16_cmplt cmp_inst (
                .aclk(clk), .aresetn(rstn),

                .s_axis_a_tdata(err_axis_tdata),
                .s_axis_a_tvalid(err_axis_tvalid),
                .s_axis_a_tready(err_axis_tready),

                .s_axis_b_tdata(TOL16),
                .s_axis_b_tvalid(1'b1),
                .s_axis_b_tready(),

                .m_axis_result_tdata(cmp_out_tdata),
                .m_axis_result_tvalid(cmp_out_tvalid),
                .m_axis_result_tready(1'b1)
            );
        end
    endgenerate

    // =============================================================
    //                          CONTROLLER
    // =============================================================

    reg is_first;
    reg decision_valid;
    reg forward_result;

    assign vec_in_axis_tdata  = is_first ? vec_init_axis_tdata : fifo_out_axis_tdata;
    assign vec_in_axis_tvalid = is_first ? vec_init_axis_tvalid :
                                (decision_valid && !forward_result ? fifo_out_axis_tvalid : 1'b0);
    assign vec_in_axis_tlast  = is_first ? vec_init_axis_tlast : fifo_out_axis_tlast;
    
    assign vec_init_axis_tready = is_first ? vec_in_axis_tready : 1'b0;
    
    assign fifo_out_axis_tready =
        (!is_first && decision_valid && !forward_result) ? vec_in_axis_tready :
        (!is_first && decision_valid &&  forward_result) ? vec_result_axis_tready : 1'b0;

    assign vec_result_axis_tdata  = fifo_out_axis_tdata;
    assign vec_result_axis_tvalid = (!is_first && decision_valid && forward_result) ? fifo_out_axis_tvalid : 1'b0;
    assign vec_result_axis_tlast  = fifo_out_axis_tlast;

    always @(posedge clk) begin
        if (!rstn) begin
            is_first       <= 1'b1; 
            decision_valid <= 1'b0;
            forward_result <= 1'b0; 
        end else begin
            if (cmp_out_tvalid) begin
                forward_result <= cmp_out_tdata[0];
                decision_valid <= 1'b1;
            end

            if (is_first) begin
                if (vec_init_axis_tvalid && vec_init_axis_tready && vec_init_axis_tlast) begin
                    is_first <= 1'b0;
                end
            end else begin
                if (fifo_out_axis_tvalid && fifo_out_axis_tready && fifo_out_axis_tlast) begin
                    decision_valid <= 1'b0;
                    if (forward_result) begin
                        forward_result <= 1'b0; 
                        is_first <= 1'b1;
                    end
                end
            end
        end
    end

endmodule

