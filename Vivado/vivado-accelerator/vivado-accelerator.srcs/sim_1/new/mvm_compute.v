`timescale 1ns / 1ps

module mvm_compute #(
    parameter DATA_WIDTH         = 1024,
    parameter ELEMENTS_PER_WORD  = DATA_WIDTH / 64,
    parameter ELEMENT_WIDTH      = 64,
    parameter WORDS_PER_TRANSFER = 17048
)(
    input  wire clk,
    input  wire rstn,

    // AXIS inputs for a and b
    input  wire [DATA_WIDTH-1:0] s_axis_a_tdata,
    input  wire                  s_axis_a_tvalid,
    output wire                  s_axis_a_tready,

    input  wire [DATA_WIDTH-1:0] s_axis_b_tdata,
    input  wire                  s_axis_b_tvalid,
    output wire                  s_axis_b_tready,

    // AXIS output
    output wire [ELEMENT_WIDTH-1:0] m_axis_tdata,
    output wire                     m_axis_tvalid,
    input  wire                     m_axis_tready,
    output wire                     m_axis_tlast
);

    wire [ELEMENTS_PER_WORD-1:0] s_axis_a_tready_vec;
    wire [ELEMENTS_PER_WORD-1:0] s_axis_b_tready_vec;
    
    assign s_axis_a_tready = &s_axis_a_tready_vec;
    assign s_axis_b_tready = &s_axis_b_tready_vec;

    wire [ELEMENT_WIDTH-1:0] partial_sum   [ELEMENTS_PER_WORD-1:0];
    wire                     partial_valid [ELEMENTS_PER_WORD-1:0];
    wire                     partial_ready [ELEMENTS_PER_WORD-1:0];

    genvar i;
    generate
        for (i = 0; i < ELEMENTS_PER_WORD; i = i + 1) begin
            dot_product #(
                .WORDS_PER_TRANSFER(WORDS_PER_TRANSFER)
            ) dp (
                .clk(clk),
                .rstn(rstn),

                .s_axis_a_tdata(s_axis_a_tdata[i*64 +: 64]),
                .s_axis_a_tvalid(s_axis_a_tvalid),
                .s_axis_a_tready(s_axis_a_tready_vec[i]),

                .s_axis_b_tdata(s_axis_b_tdata[i*64 +: 64]),
                .s_axis_b_tvalid(s_axis_b_tvalid),
                .s_axis_b_tready(s_axis_b_tready_vec[i]),

                .m_axis_tdata(partial_sum[i]),
                .m_axis_tvalid(partial_valid[i]),
                .m_axis_tready(partial_ready[i]),
                .m_axis_tlast()
            );
        end
    endgenerate

    localparam integer NUM_LVLS = $clog2(ELEMENTS_PER_WORD);
    wire [ELEMENT_WIDTH-1:0] adder_tree_data  [0:NUM_LVLS][0:ELEMENTS_PER_WORD-1];
    wire                     adder_tree_valid [0:NUM_LVLS][0:ELEMENTS_PER_WORD-1];
    wire                     adder_tree_ready [0:NUM_LVLS][0:ELEMENTS_PER_WORD-1];

    generate
        for (i = 0; i < ELEMENTS_PER_WORD; i = i + 1) begin
            assign adder_tree_data[0][i]  = partial_sum[i];
            assign adder_tree_valid[0][i] = partial_valid[i];
            assign adder_tree_ready[0][i] = partial_ready[i];
        end
    endgenerate

    genvar lvl, j;
    generate
        for (lvl = 0; lvl < NUM_LVLS; lvl = lvl + 1) begin : tree_lvl
            for (j = 0; j < ELEMENTS_PER_WORD >> (lvl + 1); j = j + 1) begin : tree_node
                fp64_adder add_inst (
                    .aclk(clk),
                    .aresetn(rstn),
                    
                    .s_axis_a_tdata (adder_tree_data[lvl][2*j]),
                    .s_axis_a_tvalid(adder_tree_valid[lvl][2*j]),
                    .s_axis_a_tready(adder_tree_ready[lvl][2*j]),
                    
                    .s_axis_b_tdata (adder_tree_data[lvl][2*j+1]),
                    .s_axis_b_tvalid(adder_tree_valid[lvl][2*j+1]),
                    .s_axis_b_tready(adder_tree_ready[lvl][2*j+1]),

                    .m_axis_result_tvalid(adder_tree_valid[lvl+1][j]),
                    .m_axis_result_tdata (adder_tree_data[lvl+1][j])
                );
            end
        end
    endgenerate

    assign m_axis_tdata  = adder_tree_data[NUM_LVLS][0];
    assign m_axis_tvalid = adder_tree_valid[NUM_LVLS][0];
    assign m_axis_tlast  = m_axis_tvalid;

endmodule