`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/26 08:45:57
// Design Name: 
// Module Name: MEM_WB
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


module MEM_WB(
    input wire clk,en,rst,clear,

    input wire [31:0] mem_mem_data_i,
    input wire [31:0] mem_alu_res_i,
    input wire [4:0] mem_rd_addr_i,
    input wire mem_wb_reg_en_i,
    input wire mem_wb_wb_sel_i,

    output wire [31:0] mem_mem_data_o,
    output wire [31:0] mem_alu_res_o,
    output wire [4:0] mem_rd_addr_o,
    output wire mem_wb_reg_en_o,
    output wire mem_wb_wb_sel_o
    );

    FlopEnRC #(32) flop_mem_data(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(mem_mem_data_i),
        .out(mem_mem_data_o)
    );
    
    FlopEnRC #(32) flop_alu_res(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(mem_alu_res_i),
        .out(mem_alu_res_o)
    );

    FlopEnRC #(5) flop_rd_addr(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(mem_rd_addr_i),
        .out(mem_rd_addr_o)
    );

    FlopEnRC #(1) flop_wb_reg_en(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(mem_wb_reg_en_i),
        .out(mem_wb_reg_en_o)
    );

    FlopEnRC #(1) flop_wb_sel(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(mem_wb_wb_sel_i),
        .out(mem_wb_wb_sel_o)
    );
    
endmodule
