`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/26 08:45:57
// Design Name: 
// Module Name: PipeLine
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


module PipeLine(
    input wire clk,
    input wire rst
    );

    wire [5:0] op_top,funct_top;
    wire rt_rd_sel_top;
    wire wb_reg_en_top;
    wire [1:0] branch_sel_top;
    wire [1:0] j_sel_top; 
    wire [3:0] alu_sel_top;
    wire rt_imme_sel_top;
    wire mem_en_top;
    wire wb_sel_top;

    Controller controller(
        .inst_op(op_top),
        .inst_funct(funct_top),
        .c_rt_rd_sel(rt_rd_sel_top),
        .c_wb_reg_en(wb_reg_en_top),
        .c_branch_sel(branch_sel_top),
        .c_branch_j(j_sel_top),
        .c_rt_imme_sel(rt_imme_sel_top),
        .c_alu_sel(alu_sel_top),
        .c_w_mem_en(mem_en_top),
        .c_wb_sel(wb_sel_top)
    );

    wire pc_stall_top, if_id_stall_top, if_id_flush_top, id_ex_flush_top;
    wire [1:0] id_forwardA_top, id_forwardB_top, ex_forwardA_top, ex_forwardB_top;
    wire [4:0] id_rs_addr_top, id_rt_addr_top;
    wire branch_op_top, j_op_top, id_ex_mem_r_top, ex_mem_mem_r_top;
    wire [4:0] id_ex_rt_addr_top, id_ex_rs_addr_top, id_ex_rd_addr_top, ex_mem_rt_addr_top,
               ex_mem_rs_addr_top, ex_mem_rd_addr_top, mem_wb_rd_addr_top;
    wire id_ex_wb_reg_en_top, ex_mem_w_reg_en_top, mem_wb_w_reg_en_top;
    Datapath datapath(
        .clk(clk),
        .rst(rst),
        //controller
        .dp_rt_rd_sel(rt_rd_sel_top),
        .dp_wb_reg_en(wb_reg_en_top),
        .dp_branch_sel(branch_sel_top),
        .dp_branch_j(j_sel_top),
        .dp_rt_imme_sel(rt_imme_sel_top),
        .dp_alu_sel(alu_sel_top),
        .dp_w_mem_en(mem_en_top),
        .dp_wb_sel(wb_sel_top),
        //hazard unit
        .pc_stall(pc_stall_top),
        .if_id_stall(if_id_stall_top),
        .if_id_flush(if_id_flush_top),
        //input wire id_ex_flush
        .id_ex_flush(id_ex_flush_top),
        // input wire EX_MEM_stall,
        // input wire EX_MEM_flush,
        // input wire MEM_WB_stall,
        // input wire MEM_WB_flush,
        .ex_forwardA(ex_forwardA_top),
        .ex_forwardB(ex_forwardB_top),
        .id_forwardA(id_forwardA_top),
        .id_forwardB(id_forwardB_top),


        .dp_op(op_top),
        .dp_funct(funct_top),
        //to hazard unti
        .id_rs_addr(id_rs_addr_top),
        .id_rt_addr(id_rt_addr_top),
        .id_branch_op(branch_op_top),
        .id_j_op(j_op_top),
        .id_ex_mem_r(id_ex_mem_r_top),
        .ex_mem_mem_r(ex_mem_mem_r_top),

        .id_ex_rt_addr(id_ex_rt_addr_top),
        .id_ex_rs_addr(id_ex_rs_addr_top),
        .id_ex_rd_addr(id_ex_rd_addr_top),
        .ex_mem_rt_addr(ex_mem_rt_addr_top), //not used 
        .ex_mem_rs_addr(ex_mem_rs_addr_top), //not used 

        .id_ex_wb_reg_en(id_ex_wb_reg_en_top),
        .ex_mem_w_reg_en(ex_mem_w_reg_en_top),
        .ex_mem_rd_addr(ex_mem_rd_addr_top),
        
        .mem_wb_w_reg_en(mem_wb_w_reg_en_top),
        .mem_wb_rd_addr(mem_wb_rd_addr_top)

    );

    Hazard hazard(
        .id_rs_addr_hz(id_rs_addr_top),
        .id_rt_addr_hz(id_rt_addr_top),
        .branch_op_hz(branch_op_top),
        .j_op_hz(j_op_top),
        .id_ex_mem_r_hz(id_ex_mem_r_top),
        .ex_mem_mem_r_hz(ex_mem_mem_r_top),
        .id_ex_rt_addr_hz(id_ex_rt_addr_top),
        .id_ex_rs_addr_hz(id_ex_rs_addr_top),
        .id_ex_rd_addr_hz(id_ex_rd_addr_top),
        //input wire [4:0] ex_mem_rt_addr_hz,
        //input wire [4:0] ex_mem_rs_addr_hz,
        .id_ex_reg_en_hz(id_ex_wb_reg_en_top),
        .ex_mem_reg_en_hz(ex_mem_w_reg_en_top),
        .ex_mem_rd_addr_hz(ex_mem_rd_addr_top),
        .mem_wb_reg_en_hz(mem_wb_w_reg_en_top),
        .mem_wb_rd_addr_hz(mem_wb_rd_addr_top),

        .pc_stall_hz(pc_stall_top),
        .if_id_stall_hz(if_id_stall_top),
        .if_id_flush_hz(if_id_flush_top),

        .id_ex_flush_hz(id_ex_flush_top),

        .ex_forwardA_hz(ex_forwardA_top),
        .ex_forwardB_hz(ex_forwardB_top),
        .id_forwardA_hz(id_forwardA_top),
        .id_forwardB_hz(id_forwardB_top)
    );
    
endmodule
