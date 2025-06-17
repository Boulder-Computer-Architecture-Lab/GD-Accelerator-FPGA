`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2025 02:23:54 PM
// Design Name: 
// Module Name: axi_stream_const_double_zero
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_stream_const_double_zero(
    input  wire        aclk,
    input  wire        aresetn,
    output wire [63:0] tdata,
    output wire        tvalid,
    input  wire        tready,
    output wire        tlast
);
    assign tdata  = 64'h0000000000000000; // IEEE-754 double 0.0
    assign tvalid = 1'b1;
    assign tlast  = 1'b1; // or toggle based on need
endmodule
