`timescale 1ns / 1ps

module check_convergence #(
    parameter DATA_WIDTH = 64,
    parameter TOLERANCE  = 64'h3F847AE147AE147B // 0.01 as fp64
)(

    input  wire clk,
    input  wire rstn,

    // Initial guess for vector
    input  wire [DATA_WIDTH-1:0] vec_init_axis_tdata,
    input  wire                  vec_init_axis_tvalid,
    output wire                  vec_init_axis_tready,
    input  wire                  vec_init_axis_tlast,

    // This iteration's vector
    input  wire [DATA_WIDTH-1:0] vec_next_axis_tdata,
    input  wire                  vec_next_axis_tvalid,
    output wire                  vec_next_axis_tready,
    input  wire                  vec_next_axis_tlast,

    // This iteration's error
    input  wire [DATA_WIDTH-1:0] err_axis_tdata,
    input  wire                  err_axis_tvalid,
    output wire                  err_axis_tready,

    // Input vector for next iteration
    output wire [DATA_WIDTH-1:0] vec_in_axis_tdata,
    output wire                  vec_in_axis_tvalid,
    input  wire                  vec_in_axis_tready,
    output wire                  vec_in_axis_tlast,

    // Result stream
    output wire [DATA_WIDTH-1:0] vec_result_axis_tdata,
    output wire                  vec_result_axis_tvalid,
    input  wire                  vec_result_axis_tready,
    output wire                  vec_result_axis_tlast
);

    // =============================================================
    //                      CONVERGENCE CHECK
    // =============================================================

    wire [7:0] cmp_out_tdata;
    wire       cmp_out_tvalid;

    fp64_cmplt cmp_inst (
        .aclk(clk), .aresetn(rstn),

        .s_axis_a_tdata(err_axis_tdata),
        .s_axis_a_tvalid(err_axis_tvalid),
        .s_axis_a_tready(err_axis_tready),

        .s_axis_b_tdata(TOLERANCE),
        .s_axis_b_tvalid(1'b1),
        .s_axis_b_tready(),

        .m_axis_result_tdata(cmp_out_tdata),
        .m_axis_result_tvalid(cmp_out_tvalid),
        .m_axis_result_tready(1'b1)
    );

    // =============================================================
    //                          CONTROLLER
    // =============================================================

    reg is_first;
    reg decision_valid;
    reg forward_result;

    assign vec_in_axis_tdata  = is_first ? vec_init_axis_tdata : vec_next_axis_tdata;
    assign vec_in_axis_tvalid = is_first ? vec_init_axis_tvalid :
                                (decision_valid && !forward_result ? vec_next_axis_tvalid : 1'b0);
    assign vec_in_axis_tlast  = is_first ? vec_init_axis_tlast : vec_next_axis_tlast;
    
    assign vec_init_axis_tready = is_first ? vec_in_axis_tready : 1'b0;
    
    assign vec_next_axis_tready =
        (!is_first && decision_valid && !forward_result) ? vec_in_axis_tready :
        (!is_first && decision_valid &&  forward_result) ? vec_result_axis_tready : 1'b0;

    assign vec_result_axis_tdata  = vec_next_axis_tdata;
    assign vec_result_axis_tvalid = (!is_first && decision_valid && forward_result) ? vec_next_axis_tvalid : 1'b0;
    assign vec_result_axis_tlast  = vec_next_axis_tlast;

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
                if (vec_next_axis_tvalid && vec_next_axis_tready && vec_next_axis_tlast) begin
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

