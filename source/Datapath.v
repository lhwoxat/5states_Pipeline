`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/26 08:45:57
// Design Name: 
// Module Name: Datapath
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
module Datapath(
    input wire clk,
    input wire rst,

    //controller
    input wire dp_rt_rd_sel,
    input wire dp_wb_reg_en,
    input wire [1:0] dp_branch_sel,
    input wire [1:0] dp_branch_j,
    input wire dp_rt_imme_sel,
    input wire [3:0] dp_alu_sel,
    input wire dp_w_mem_en,
    input wire dp_wb_sel,


    //hazard unit
    input wire pc_stall,
    input wire if_id_stall,
    input wire if_id_flush,
    //input wire id_ex_flush
    input wire id_ex_flush,
    // input wire EX_MEM_stall,
    // input wire EX_MEM_flush,
    // input wire MEM_WB_stall,
    // input wire MEM_WB_flush,
    input wire [1:0] ex_forwardA,
    input wire [1:0] ex_forwardB,
    input wire [1:0] id_forwardA,
    input wire [1:0] id_forwardB,


    output wire [5:0] dp_op,
    output wire [5:0] dp_funct,
    //to hazard unti
    output wire [4:0] id_rs_addr,
    output wire [4:0] id_rt_addr,
    output wire id_branch_op,
    output wire id_j_op,
    output wire id_ex_mem_r,
    output wire ex_mem_mem_r,

    output wire [4:0] id_ex_rt_addr,
    output wire [4:0] id_ex_rs_addr,
    output wire [4:0] id_ex_rd_addr,
    output wire [4:0] ex_mem_rt_addr, //not used
    output wire [4:0] ex_mem_rs_addr,  //not used

    output wire id_ex_wb_reg_en,
    output wire ex_mem_w_reg_en,
    output wire [4:0] ex_mem_rd_addr,
    
    output wire mem_wb_w_reg_en,
    output wire [4:0] mem_wb_rd_addr
    );
    wire id_ex_stall, ex_mem_stall, ex_mem_flush, mem_wb_stall, mem_wb_flush;
    assign id_ex_stall  = 1'b0;
    assign ex_mem_stall = 1'b0;
    assign ex_mem_flush = 1'b0;
    assign mem_wb_stall = 1'b0;
    assign mem_wb_flush = 1'b0;

    wire [15:0] branch_imme_i;
    wire [25:0] branch_imme_j;
    wire [31:0] beq_rs_data_dp;
    wire [31:0] beq_rt_data_dp; 
    wire [31:0] id_rs_data_dp, id_rt_data_dp;
    wire [`INSTR_WIDTH-1:0] if_instr, if_id_instr;
    wire [31:0] id_pc, if_pc;
    IF if_(
    .clk(clk),
    .en(pc_stall), //pass to pc
    .rst(rst),
    .branch_sel(dp_branch_sel),
    .j_sel(dp_branch_j),
    .i_imme(branch_imme_i),
    .rs_data(beq_rs_data_dp),
    .rt_data(beq_rt_data_dp),
    .j_imme(branch_imme_j),

    .id_rs_data(id_rs_data_dp),
    .id_pc(id_pc),
    .instr(if_instr),
    .pc_if(if_pc)
    );

    IF_ID IF_ID_REGS(
    .clk(clk),
    .en(if_id_stall),
    .rst(rst),
    .clear(if_id_flush),
    .instr_if_i(if_instr),
    .pc_if_i(if_pc),

    .instr_if_o(if_id_instr),
    .pc_if_o(id_pc)
    );
    //wb
    wire wb_reg_en_dp;
    wire [4:0] wb_reg_addr_dp;
    wire [31:0] wb_reg_data_dp;
    
    wire [15:0] id_imme_dp;
    wire [4:0] id_rd_dp;
    wire id_mem_r_en_dp;
    wire id_rt_imme_sel_dp;
    wire [3:0] id_alu_sel_dp;
    wire id_mem_en_dp;
    wire id_w_reg_en_dp;
    wire id_wb_sel_dp;
    
    ID id(
    .clk(clk),
    .rst(rst),
    .instr_if(if_id_instr),
    //wb
    .wb_reg_en(wb_reg_en_dp), //from wb
    .wb_reg_addr(wb_reg_addr_dp), //from wb to update regfile
    .wb_reg_data(wb_reg_data_dp), // from wb
    //output & sel
    .op_out(dp_op), //to control
    .funct_out(dp_funct),  //to control
    //from control
    .rt_rd_sel(dp_rt_rd_sel), //to choose next pos to update wbs
    .reg_en(dp_wb_reg_en),
    .rt_sel(dp_rt_imme_sel),
    .alu_sel(dp_alu_sel),
    .mem_en(dp_w_mem_en),
    .wb_sel(dp_wb_sel),
    
    .id_imme_i(id_imme_dp),
    .id_imme_j(branch_imme_j),
    .id_rs(id_rs_addr), 
    .id_rt(id_rt_addr), 
    .id_rd(id_rd_dp), //to wb
    .id_rs_data_out(id_rs_data_dp),
    .id_rt_data_out(id_rt_data_dp),
    //id
    .id_branch_op(id_branch_op),
    .id_j_op(id_j_op),
    .id_mem_r_en(id_mem_r_en), 
    
    //control  ex
    .id_rt_sel(id_rt_imme_sel_dp),
    .id_alu_sel(id_alu_sel_dp),
    //mem   
    .id_mem_en(id_mem_en_dp),
    //wb
    .id_w_reg_en(id_w_reg_en_dp),
    .id_wb_sel(id_wb_sel_dp)
    );

    wire [31:0] ex_mem_alu_res_dp;
    assign branch_imme_i = id_imme_dp;
    assign beq_rs_data_dp = (id_forwardA == 2'b00)? id_rs_data_dp:
    (id_forwardA ==2'b01)? ex_mem_alu_res_dp : wb_reg_data_dp;
    assign beq_rt_data_dp = (id_forwardB == 2'b00)? id_rt_data_dp:
    (id_forwardB == 2'b01) ?ex_mem_alu_res_dp : wb_reg_data_dp;
    wire id_ex_rt_imme_sel , id_ex_mem_en, id_ex_wb_sel;
    wire [3:0] id_ex_alu_sel;
    wire [15:0] id_ex_immei;
    wire [31:0] id_ex_rs_data, id_ex_rt_data;
    ID_EX ID_EX_REGS(
        .clk(clk),
        .en(id_ex_stall),
        .rst(rst),
        .clear(id_ex_flush),
        .id_immei_i(id_imme_dp),
        .id_rs_addr_i(id_rs_addr),
        .id_rt_addr_i(id_rt_addr),
        .id_rd_addr_i(id_rd_dp),
        .id_rs_data_i(id_rs_data_dp),
        .id_rt_data_i(id_rt_data_dp),//

        .id_rt_imme_sel_i(id_rt_imme_sel_dp),
        .id_alu_sel_i(id_alu_sel_dp),
        .id_mem_en_i(id_mem_en_dp),
        .id_wb_reg_en_i(id_w_reg_en_dp),
        .id_wb_sel_i(id_wb_sel_dp),
        .id_mem_r_i(id_mem_r_en),//

        .id_immei_o(id_ex_immei),
        .id_rs_addr_o(id_ex_rs_addr),
        .id_rt_addr_o(id_ex_rt_addr),
        .id_rd_addr_o(id_ex_rd_addr),
        .id_rs_data_o(id_ex_rs_data),
        .id_rt_data_o(id_ex_rt_data),//

        .id_rt_imme_sel_o(id_ex_rt_imme_sel),
        .id_alu_sel_o(id_ex_alu_sel),
        .id_mem_en_o(id_ex_mem_en),
        .id_wb_reg_en_o(id_ex_wb_reg_en),
        .id_wb_sel_o(id_ex_wb_sel),
        .id_mem_r_o(id_ex_mem_r)
    );
    wire [31:0] ex_alu_res, ex_rt_data;
    wire [4:0] ex_rd_addr;
    wire ex_mem_en, ex_w_reg_en, ex_wb_sel;
    EX ex(
    .id_rs_data(id_ex_rs_data),
    .id_rt_data(id_ex_rt_data),
    .id_rt_imme_sel(id_ex_rt_imme_sel), //imme or rt
    .id_alu_sel(id_ex_alu_sel),
    .id_imme_i(id_ex_immei),//
    .W_forwardA(ex_forwardA),
    .W_forwardB(ex_forwardB),
    .ex_mem_alu_res(ex_mem_alu_res_dp),
    .wb_wb_data(wb_reg_data_dp),
    // control
    .id_rd(id_ex_rd_addr),
    // mem
    .id_w_mem_ena(id_ex_mem_en),
    // wb
    .id_w_reg_en(id_ex_wb_reg_en),
    .id_wb_sel(id_ex_wb_sel),

    .ex_alu_res(ex_alu_res),
    .ex_rt_data(ex_rt_data),
    .ex_rd(ex_rd_addr),
    .ex_mem_en(ex_mem_en),
    .ex_w_reg_en(ex_w_reg_en),
    .ex_wb_sel(ex_wb_sel)
    );

    wire [31:0] ex_mem_rt_data;
    wire ex_mem_mem_en, ex_mem_wb_sel;
    EX_MEM EX_MEM_REGS(
    .clk(clk),
    .en(ex_mem_stall),
    .rst(rst),
    .clear(ex_mem_flush),
    .ex_alu_res_i(ex_alu_res),
    .ex_rt_data_i(ex_rt_data), //to write mem

    .ex_rd_i(ex_rd_addr),
    .ex_mem_en_i(ex_mem_en),
    .ex_reg_en_i(ex_w_reg_en),
    .ex_reg_sel_i(ex_wb_sel),

    .ex_mem_r_i(id_ex_mem_r),
    .ex_rs_addr_i(id_ex_rs_addr),
    .ex_rt_addr_i(id_ex_rt_addr),
    //output
    .ex_alu_res_o(ex_mem_alu_res_dp),
    .ex_rt_data_o(ex_mem_rt_data), //to write mem
    .ex_rd_o(ex_mem_rd_addr),
    .ex_mem_en_o(ex_mem_mem_en),
    .ex_reg_en_o(ex_mem_w_reg_en),
    .ex_reg_sel_o(ex_mem_wb_sel),
    .ex_mem_r_o(ex_mem_mem_r),
    .ex_rs_addr_o(ex_mem_rs_addr), //not uesd 
    .ex_rt_addr_o(ex_mem_rt_addr)  //not used
    );

    wire [31:0] mem_data;
    wire [31:0] mem_alu_res;
    wire [4:0] mem_rd_addr;
    wire mem_wb_wb_reg_en, mem_wb_sel;
    MEM mem(
    .clk(clk),
    .mem_mem_en(ex_mem_mem_en),
    .mem_alu_res(ex_mem_alu_res_dp),
    .mem_memdata(ex_mem_rt_data),
    .mem_rd_addr(ex_mem_rd_addr),
    .mem_wb_reg_en(ex_mem_w_reg_en),
    .mem_wb_wb_sel(ex_mem_wb_sel),

    .wb_mem_data(mem_data),
    .wb_alu_res(mem_alu_res),
    .wb_wb_rd_addr(mem_rd_addr),
    .wb_reg_en(mem_wb_wb_reg_en),
    .wb_wb_sel(mem_wb_sel)
    );

    wire [31:0] mem_wb_mem_data, mem_wb_alu_res;
    wire mem_wb_wb_sel;
    MEM_WB MEM_WB_REGS(
    .clk(clk),
    .en(mem_wb_stall),
    .rst(rst),
    .clear(mem_wb_flush),
    .mem_mem_data_i(mem_data),
    .mem_alu_res_i(mem_alu_res),
    .mem_rd_addr_i(mem_rd_addr),
    .mem_wb_reg_en_i(mem_wb_wb_reg_en),
    .mem_wb_wb_sel_i(mem_wb_sel),

    .mem_mem_data_o(mem_wb_mem_data),
    .mem_alu_res_o(mem_wb_alu_res),
    .mem_rd_addr_o(mem_wb_rd_addr),
    .mem_wb_reg_en_o(mem_wb_w_reg_en),
    .mem_wb_wb_sel_o(mem_wb_wb_sel)
    );


    WB wb(
    .mem_alu_res(mem_wb_alu_res),
    .mem_mem_data(mem_wb_mem_data),
    
    //control
    .mem_wb_sel(mem_wb_wb_sel), //alu or mem_ram
    .mem_rd(mem_wb_rd_addr),
    .mem_wb_en(mem_wb_w_reg_en),

    .wb_reg_en(wb_reg_en_dp),
    .wb_reg_addr(wb_reg_addr_dp),
    .wb_reg_data(wb_reg_data_dp)
    );

endmodule
