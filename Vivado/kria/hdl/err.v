`timescale 1ns / 1ps

module err #(
    parameter DATA_WIDTH = 64
)(

    input  wire                  clk,
    input  wire                  rstn,

    // Input stream 1 
    input  wire [DATA_WIDTH-1:0] s_axis_1_tdata,
    input  wire                  s_axis_1_tvalid,
    output wire                  s_axis_1_tready,

    // Input stream 2
    input  wire [DATA_WIDTH-1:0] s_axis_2_tdata,
    input  wire                  s_axis_2_tvalid,
    output wire                  s_axis_2_tready,
    
    // Result stream
    output wire [DATA_WIDTH-1:0] m_axis_tdata,
    output wire                  m_axis_tvalid,
    input  wire                  m_axis_tready,
    output wire                  m_axis_tlast

);

    // Computes squared error:
    // for fp input vectors x and y,
    // returns sum((x_i-y_i)^2)

    wire sub_out_tdata;
    wire sub_out_tvalid;
    wire sub_out_tready;

    wire mult_out_tdata;
    wire mult_out_tvalid;
    wire mult_out_tready;

    generate
        if (DATA_WIDTH == 64) begin

            fp64_sub sub(
                .aclk(clk), .aresetn(rstn),
                
                .s_axis_a_tdata (s_axis_1_tdata),
                .s_axis_a_tvalid(s_axis_1_tvalid),
                .s_axis_a_tready(s_axis_1_tready),
                .s_axis_a_tlast (),

                .s_axis_b_tdata (s_axis_2_tdata),
                .s_axis_b_tvalid(s_axis_2_tvalid),
                .s_axis_b_tready(s_axis_2_tready),
                .s_axis_b_tlast (),

                .m_axis_result_tdata (sub_out_tdata),
                .m_axis_result_tvalid(sub_out_tvalid),
                .m_axis_result_tready(sub_out_tready),
                .m_axis_result_tlast ()
            );

            fp64_mult sq(
                .aclk(clk), .aresetn(rstn),
                
                .s_axis_a_tdata (sub_out_tdata),
                .s_axis_a_tvalid(sub_out_tvalid),
                .s_axis_a_tready(sub_out_tready),
                .s_axis_a_tlast (),

                .s_axis_b_tdata (sub_out_tdata),
                .s_axis_b_tvalid(sub_out_tvalid),
                .s_axis_b_tready(sub_out_tready),
                .s_axis_b_tlast (),

                .m_axis_result_tdata (mult_out_tdata),
                .m_axis_result_tvalid(mult_out_tvalid),
                .m_axis_result_tready(mult_out_tready),
                .m_axis_result_tlast ()
            );

            fp64_accum acc(
                .aclk(clk), .aresetn(rstn),
            
                .s_axis_a_tdata (acc_axis_a_tdata),
                .s_axis_a_tvalid(acc_axis_a_tvalid),
                .s_axis_a_tready(acc_axis_a_tready),
                .s_axis_a_tlast (acc_axis_a_tlast),
            
                .m_axis_result_tdata (m_axis_tdata),
                .m_axis_result_tvalid(m_axis_tvalid),
                .m_axis_result_tready(m_axis_tready),
                .m_axis_result_tlast (m_axis_tlast)
            );
        
        end else if (DATA_WIDTH == 32) begin

        end else if (DATA_WIDTH == 16) begin

        end

    endgenerate

endmodule
