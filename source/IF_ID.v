`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/26 08:45:57
// Design Name: 
// Module Name: IF_ID
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
module IF_ID(
    input wire clk,
    input wire en,
    input wire rst,
    input wire clear,
    input wire [`INSTR_WIDTH-1 :0] instr_if_i,
    input wire [`INSTR_WIDTH-1 :0] pc_if_i,

    output wire [`INSTR_WIDTH-1 :0] instr_if_o,
    output wire [`INSTR_WIDTH-1 :0] pc_if_o
    );

    FlopEnRC #(`INSTR_WIDTH) flop_instr (
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(instr_if_i),
        .out(instr_if_o)
    );

    FlopEnRC #(`INSTR_WIDTH) flop_pc (
    .clk(clk),
    .rst(rst),
    .en(~en),
    .clear(clear),
    .in(pc_if_i),
    .out(pc_if_o)
);

endmodule
