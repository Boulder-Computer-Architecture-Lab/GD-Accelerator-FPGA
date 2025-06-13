`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/29/2025 02:50:14 PM
// Design Name: 
// Module Name: fp64_mult
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

/* 
// WITHOUT PIPELINING
module fp64_mult #(PARAMETER BIAS=1023)(
    input [63:0] a,
    input [63:0] b,
    output logic [63:0] result
    );
    // Decompose inputs
    logic sign_a, sign_b, sign_res;
    logic [10:0] exp_a, exp_b;
    logic [51:0] mant_a, mant_b;
    logic [52:0] full_mant_a, full_mant_b;
    logic [11:0] exp_sum;

    // Intermediate product (106 bits)
    logic [105:0] mant_prod;
    logic [51:0] mant_res;
    logic [10:0] exp_res;

    // Bit decomposition
    assign sign_a = a[63];
    assign sign_b = b[63];
    assign exp_a  = a[62:52];
    assign exp_b  = b[62:52];
    assign mant_a = a[51:0];
    assign mant_b = b[51:0];

    // Check if normalized
    assign full_mant_a = (exp_a != 0) ? {1'b1, mant_a} : {1'b0, mant_a};
    assign full_mant_b = (exp_b != 0) ? {1'b1, mant_b} : {1'b0, mant_b};

    assign sign_res = sign_a ^ sign_b;
    assign exp_sum  = exp_a + exp_b - BIAS;

    always_comb begin
        automatic logic [105:0] raw_prod = full_mant_a * full_mant_b;
        logic [10:0] adj_exp;
        logic [51:0] final_mant;

        if (raw_prod[105]) begin // MSB is 1, already normalized
            final_mant = raw_prod[104:53];
            adj_exp    = exp_sum + 1;
        end else begin
            final_mant = raw_prod[103:52];
            adj_exp    = exp_sum;
        end

        // Assemble product
        result = {sign_res, adj_exp, final_mant};
    end
endmodule
*/

module fp64_mult #(parameter BIAS = 1023)(
    input logic clk,
    input logic rst,
    input logic [63:0] a,
    input logic [63:0] b,
    output logic [63:0] result,
    output logic valid_out
);

    // Update valid bit
    logic [3:0] valid_pipe;
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            valid_pipe <= 4'b0000;
        else
            valid_pipe <= {valid_pipe[2:0], 1'b1};
    end
    
    assign valid_out = valid_pipe[3];

    // Stage 1: Input decomposition
    logic sign_a, sign_b;
    logic [10:0] exp_a, exp_b;
    logic [51:0] mant_a, mant_b;
    logic [52:0] full_mant_a, full_mant_b;
    logic sign_res_stage1;
    logic [11:0] exp_sum_stage1;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sign_res_stage1 <= 0;
            exp_sum_stage1 <= 0;
            full_mant_a <= 0;
            full_mant_b <= 0;
        end else begin
            sign_a = a[63];
            sign_b = b[63];
            exp_a  = a[62:52];
            exp_b  = b[62:52];
            mant_a = a[51:0];
            mant_b = b[51:0];

            full_mant_a <= (exp_a != 0) ? {1'b1, mant_a} : {1'b0, mant_a};
            full_mant_b <= (exp_b != 0) ? {1'b1, mant_b} : {1'b0, mant_b};
            sign_res_stage1 <= sign_a ^ sign_b;
            exp_sum_stage1 <= exp_a + exp_b - BIAS;
        end
    end

    // Stage 2: Multiply mantissas
    logic [105:0] mant_prod_stage2;
    logic sign_res_stage2;
    logic [11:0] exp_sum_stage2;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            mant_prod_stage2 <= 0;
            sign_res_stage2 <= 0;
            exp_sum_stage2 <= 0;
        end else begin
            mant_prod_stage2 <= full_mant_a * full_mant_b;
            sign_res_stage2 <= sign_res_stage1;
            exp_sum_stage2 <= exp_sum_stage1;
        end
    end

    // Stage 3: Normalize
    logic [51:0] final_mant_stage3;
    logic [10:0] adj_exp_stage3;
    logic sign_res_stage3;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            final_mant_stage3 <= 0;
            adj_exp_stage3 <= 0;
            sign_res_stage3 <= 0;
        end else begin
            if (mant_prod_stage2[105]) begin
                final_mant_stage3 <= mant_prod_stage2[104:53];
                adj_exp_stage3 <= exp_sum_stage2 + 1;
            end else begin
                final_mant_stage3 <= mant_prod_stage2[103:52];
                adj_exp_stage3 <= exp_sum_stage2;
            end
            sign_res_stage3 <= sign_res_stage2;
        end
    end

    // Stage 4: Assemble result
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= 0;
        end else begin
            result <= {sign_res_stage3, adj_exp_stage3, final_mant_stage3};
        end
    end

endmodule

