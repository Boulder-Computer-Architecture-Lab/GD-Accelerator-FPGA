`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/14/2025 07:38:26 PM
// Design Name: 
// Module Name: bram_writer
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


module bram_writer (
    input        clk,
    input        rst,
    output reg [10:0] addr,
    output reg [31:0] din,
    output reg        we,
    output            enb  // always 1
);

    assign enb = 1'b1;

    always @(posedge clk) begin
        if (rst) begin
            addr <= 0;
            din  <= 0;
            we   <= 0;
        end else begin
            if (addr != 11'h7FF) begin
                addr <= addr + 1;
                din  <= din + 1;
                we   <= 1;
            end else begin
                we <= 0;
            end
        end
    end
endmodule