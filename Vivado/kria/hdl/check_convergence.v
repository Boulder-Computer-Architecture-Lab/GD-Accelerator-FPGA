`timescale 1ns / 1ps

module check_convergence #(
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

endmodule
