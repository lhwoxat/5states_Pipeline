`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/26 08:45:57
// Design Name: 
// Module Name: ID_EX
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
module ID_EX(
        input wire clk,en,rst,clear,
        input wire [15:0] id_immei_i,
        input wire [4:0] id_rs_addr_i,
        input wire [4:0] id_rt_addr_i,
        input wire [4:0] id_rd_addr_i,
        input wire [31:0] id_rs_data_i,
        input wire [31:0] id_rt_data_i,

        input wire id_rt_imme_sel_i,
        input wire [3:0] id_alu_sel_i,
        input wire id_mem_en_i,
        input wire id_wb_reg_en_i,
        input wire id_wb_sel_i,
        input wire id_mem_r_i,

        output wire [15:0] id_immei_o,
        output wire [4:0] id_rs_addr_o,
        output wire [4:0] id_rt_addr_o,
        output wire [4:0] id_rd_addr_o,
        output wire [31:0] id_rs_data_o,
        output wire [31:0] id_rt_data_o,

        output wire id_rt_imme_sel_o,
        output wire [3:0] id_alu_sel_o,
        output wire id_mem_en_o,
        output wire id_wb_reg_en_o,
        output wire id_wb_sel_o,
        output wire id_mem_r_o
    );

    FlopEnRC #(16) flop_imme(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(id_immei_i),
        .out(id_immei_o)
    );
        FlopEnRC #(5) flop_rs(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(id_rs_addr_i),
        .out(id_rs_addr_o)
    );
        FlopEnRC #(5) flop_rt(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(id_rt_addr_i),
        .out(id_rt_addr_o)
    );
    FlopEnRC #(5) flop_rd(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(id_rd_addr_i),
        .out(id_rd_addr_o)
    );
        FlopEnRC #(32) flop_rs_data(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(id_rs_data_i),
        .out(id_rs_data_o)
    );
        FlopEnRC #(32) flop_rt_data(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(id_rt_data_i),
        .out(id_rt_data_o)
    );
    FlopEnRC #(1) flop_rt_imme_sel(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(id_rt_imme_sel_i),
        .out(id_rt_imme_sel_o)
    );

    FlopEnRC #(4) flop_alu_sel(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(id_alu_sel_i),
        .out(id_alu_sel_o)
    );

    FlopEnRC #(1) flop_mem_en(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(id_mem_en_i),
        .out(id_mem_en_o)
    );

    FlopEnRC #(1) flop_reg_en(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(id_wb_reg_en_i),
        .out(id_wb_reg_en_o)
    );

    FlopEnRC #(1) flop_reg_sel(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(id_wb_sel_i),
        .out(id_wb_sel_o)
    );

    FlopEnRC #(1) flop_mem_r(
        .clk(clk),
        .rst(rst),
        .en(~en),
        .clear(clear),
        .in(id_mem_r_i),
        .out(id_mem_r_o)
    );
endmodule
