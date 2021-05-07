`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/26 08:45:57
// Design Name: 
// Module Name: EX_MEM
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


module EX_MEM(
    input wire clk, en, rst, clear,
    
    input wire [31:0] ex_alu_res_i,
    input wire [31:0] ex_rt_data_i, //to write mem

    input wire [4:0] ex_rd_i,
    input wire ex_mem_en_i,
    input wire ex_reg_en_i,
    input wire ex_reg_sel_i,

    input wire ex_mem_r_i,
    input wire [4:0] ex_rs_addr_i,
    input wire [4:0] ex_rt_addr_i,
    //output
    output wire [31:0] ex_alu_res_o,
    output wire [31:0] ex_rt_data_o, //to write mem
    output wire [4:0] ex_rd_o,
    output wire ex_mem_en_o,
    output wire ex_reg_en_o,
    output wire ex_reg_sel_o,
    output wire ex_mem_r_o,
    output wire [4:0] ex_rs_addr_o,
    output wire [4:0] ex_rt_addr_o
    );

    FlopEnRC #(32) flop_alu_res(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(ex_alu_res_i),
        .out(ex_alu_res_o)
    );

    FlopEnRC #(32) flop_rt_data(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(ex_rt_data_i),
        .out(ex_rt_data_o)
    );

    FlopEnRC #(5) flop_rd_addr(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(ex_rd_i),
        .out(ex_rd_o)
    );

    FlopEnRC #(1) flop_mem_en(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(ex_mem_en_i),
        .out(ex_mem_en_o)
    );

    FlopEnRC #(1) flop_reg_en(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(ex_reg_en_i),
        .out(ex_reg_en_o)
    );

    FlopEnRC #(1) flop_reg_sel(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(ex_reg_sel_i),
        .out(ex_reg_sel_o)
    );

    FlopEnRC #(1) flop_mem_r(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(ex_mem_r_i),
        .out(ex_mem_r_o)
    );

    FlopEnRC #(5) flop_rs_addr(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(ex_rs_addr_i),
        .out(ex_rs_addr_o)
    );

    FlopEnRC #(5) flop_rt_addr(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(ex_rt_addr_i),
        .out(ex_rt_addr_o)
    );
endmodule
