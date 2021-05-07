`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/26 09:07:57
// Design Name: 
// Module Name: PC
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

module PC(
    input wire clk,
    input wire en,
    input wire rst,
    input wire [`INSTR_WIDTH - 1:0] next_pc,

    output reg [`INSTR_WIDTH -1:0] pc 
    );

    always @(posedge clk , posedge rst) begin
        if(rst) begin
           pc <= 32'hffff_fffc;
        end else if (en) begin
            pc <= next_pc;
        end
    end
endmodule
