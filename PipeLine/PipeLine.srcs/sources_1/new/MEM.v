`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/26 08:45:57
// Design Name: 
// Module Name: MEM
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
module MEM(
    input wire clk,
    input wire mem_mem_en,
    input wire [31:0] mem_alu_res,
    input wire [31:0] mem_memdata,
    input wire [4:0] mem_rd_addr,
    input wire mem_wb_reg_en,
    input wire mem_wb_wb_sel,

    output wire [31:0] wb_mem_data,
    output wire [31:0] wb_alu_res,
    output wire [4:0] wb_wb_rd_addr,
    output wire wb_reg_en,
    output wire wb_wb_sel
    );

    wire [31:0] w_mem_data_temp;
    Memory mem(
        .addra(mem_alu_res),
        .clka(clk),
        .dina(mem_memdata),
        .douta(w_mem_data_temp),
        .ena(1'b1),
        .wea({4{mem_mem_en}})
    );

    assign wb_mem_data = w_mem_data_temp;
    assign wb_alu_res = mem_alu_res;
    assign wb_wb_rd_addr = mem_rd_addr;
    assign wb_reg_en = mem_wb_reg_en;
    assign wb_wb_sel = mem_wb_wb_sel;
endmodule
