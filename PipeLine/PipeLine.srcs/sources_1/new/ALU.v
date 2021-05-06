`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/27 15:52:16
// Design Name: 
// Module Name: ALU
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

`include "defines.v"
module ALU(
    input wire [31:0] src_a,
    input wire [31:0] src_b,
    input wire [3:0] alu_sel,
    output reg[31:0] alu_res
    );
    always @(*) begin
        case(alu_sel)
            `ALU_ADD : alu_res = src_a + src_b;
            `ALU_SUB : alu_res = src_a - src_b;
            `ALU_AND : alu_res = src_a & src_b;
            `ALU_OR  : alu_res = src_a | src_b;
            `ALU_SLT : alu_res =  (src_a < src_b) ?
                    {{31{1'b0}},1'b1} : {32{1'b0}};
            default: alu_res = {32{1'b0}};
        endcase
    end
endmodule
