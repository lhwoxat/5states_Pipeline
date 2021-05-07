`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/26 08:45:57
// Design Name: 
// Module Name: ID
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
module ID(
    input wire clk,
    input wire rst,
    input wire [`INSTR_WIDTH-1 :0] instr_if,
    //wb
    input wire wb_reg_en, //from wb
    input wire [4:0] wb_reg_addr, //from wb to update regfile
    input wire [`INSTR_WIDTH-1 :0] wb_reg_data, // from wb

    //output & sel
    output wire [5:0] op_out, //to control
    output wire [5:0] funct_out,  //to control
    
    //from control
    input wire rt_rd_sel, //to choose next pos to update wbs
    input wire reg_en,
    input wire rt_sel,
    input wire [3:0] alu_sel,
    input wire mem_en,
    input wire wb_sel,
    
    output wire [15:0] id_imme_i,
    output wire [25:0] id_imme_j,
    output wire [4:0] id_rs, 
    output wire [4:0] id_rt, 
    output wire [4:0] id_rd, //to wb
    output wire [`INSTR_WIDTH-1:0] id_rs_data_out,
    output wire [`INSTR_WIDTH-1:0] id_rt_data_out,
    //control

    //id
    output wire id_branch_op,
    output wire id_j_op,
    output wire id_mem_r_en, 
    
    //control  ex
    output wire id_rt_sel,
    output wire [3:0] id_alu_sel,
    //mem   
    output wire id_mem_en,
    //wb
    output wire id_w_reg_en,
    output wire id_wb_sel
    );

    wire [5:0] inst_op;
    wire [4:0] inst_rs,inst_rt,inst_rd,inst_shamt;
    wire [15:0] imme_i;
    wire [25:0] imme_j;
    wire [`INSTR_WIDTH -1 :0] rs_data_reg;
    wire [`INSTR_WIDTH -1 :0] rt_data_reg;
    wire [4:0] w_addr_sel;

    //set value
    assign inst_op = instr_if [31:26];
    assign inst_rs = instr_if [25:21];
    assign inst_rt = instr_if [20:16];
    assign inst_rd = instr_if [15:11];
    assign inst_shamt = instr_if [10:6];
    assign imme_i = instr_if[15:0];
    assign imme_j = instr_if[25:0];
    //set end
    
    //set branch
    assign id_mem_r_en = (inst_op == `LW_OP_CODE);
    assign id_branch_op = (inst_op == `BEQ_OP_CODE);
    assign id_j_op = (inst_op == `J_OP_CODE);
    //set end
    assign w_addr_sel = (rt_rd_sel == 1'b0) ? inst_rd :inst_rt;
    //rt_rd_sel 在id阶段就能通过控制器传来的信号判断出来，从此
    //每一步只需要传递写地址即可
    Regfiles regfile (
    .clk(clk),
    .rst(rst),
    .rs_addr(inst_rs),
    .rt_addr(inst_rt),
    .w_en(wb_reg_en),
    .w_addr(wb_reg_addr),
    .w_data(wb_reg_data),
    .rs_data(rs_data_reg),
    .rt_data(rt_data_reg) 
    );
    //set id_value
    assign id_rs = inst_rs;
    assign id_rt = inst_rt;
    assign id_rd = w_addr_sel;
    assign id_imme_i = imme_i;
    assign id_imme_j = imme_j;
    assign id_rt_sel = rt_sel;
    assign id_alu_sel = alu_sel;
    assign id_mem_en =mem_en;
    assign id_wb_sel = wb_sel;
    assign id_w_reg_en =reg_en;
    assign id_rs_data_out = rs_data_reg;
    assign id_rt_data_out = rt_data_reg;
    assign op_out = inst_op;
    assign funct_out = instr_if[5:0];
    //set end
endmodule
