`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/26 08:45:57
// Design Name: 
// Module Name: Controller
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
module Controller(
    input wire [5:0] inst_op,
    input wire [5:0] inst_funct,

    //id
    output reg c_rt_rd_sel,
    output reg c_wb_reg_en,
    output reg [1:0] c_branch_sel,
    output reg [1:0] c_branch_j,
    //ex
    output reg c_rt_imme_sel,
    output reg [3:0] c_alu_sel,
    //mem
    output reg c_w_mem_en,
    //wb
    output reg c_wb_sel
    );

    always @(*) begin
        case(inst_op)
            `ARITH_OP_CODE:begin
                case(inst_funct)
                    `ADD_FUNCT:begin
                        c_rt_rd_sel = `W_TD_SEL_RD;
                        c_wb_reg_en = `W_REG_ENABLE;
                        c_branch_sel = `BRANCH_SEL_NOP;
                        c_branch_j = `J_SEL_NOP;
                        c_rt_imme_sel = `RT_SEL_RT;
                        c_alu_sel = `ALU_SEL_ADD;
                        c_w_mem_en = `W_MEM_DISABLE;
                        c_wb_sel = `WB_SEL_ALU;
                    end

                    `SUB_FUNCT:begin
                        c_rt_rd_sel = `W_TD_SEL_RD;
                        c_wb_reg_en = `W_REG_ENABLE;
                        c_branch_sel = `BRANCH_SEL_NOP;
                        c_branch_j = `J_SEL_NOP;
                        c_rt_imme_sel = `RT_SEL_RT;
                        c_alu_sel = `ALU_SEL_SUB;
                        c_w_mem_en = `W_MEM_DISABLE;
                        c_wb_sel = `WB_SEL_ALU;
                    end

                    `AND_FUNCT:begin
                        c_rt_rd_sel = `W_TD_SEL_RD;
                        c_wb_reg_en = `W_REG_ENABLE;
                        c_branch_sel = `BRANCH_SEL_NOP;
                        c_branch_j = `J_SEL_NOP;
                        c_rt_imme_sel = `RT_SEL_RT;
                        c_alu_sel = `ALU_SEL_AND;
                        c_w_mem_en = `W_MEM_DISABLE;
                        c_wb_sel = `WB_SEL_ALU;
                    end

                    `OR_FUNCT:begin
                        c_rt_rd_sel = `W_TD_SEL_RD;
                        c_wb_reg_en =`W_REG_ENABLE;
                        c_branch_sel =`BRANCH_SEL_NOP;
                        c_branch_j =`J_SEL_NOP;
                        c_rt_imme_sel =`RT_SEL_RT;
                        c_alu_sel =`ALU_SEL_OR;
                        c_w_mem_en =`W_MEM_DISABLE;
                        c_wb_sel =`WB_SEL_ALU;
                    end

                    `SLT_FUNCT:begin
                        c_rt_rd_sel = `W_TD_SEL_RD;
                        c_wb_reg_en =`W_REG_ENABLE;
                        c_branch_sel =`BRANCH_SEL_NOP;
                        c_branch_j =`J_SEL_NOP;
                        c_rt_imme_sel =`RT_SEL_RT;
                        c_alu_sel =`ALU_SEL_SLT;
                        c_w_mem_en =`W_MEM_DISABLE;
                        c_wb_sel =`WB_SEL_ALU;
                    end

                    default:begin
                        c_rt_rd_sel =`W_TD_SEL_NOP;
                        c_wb_reg_en = `W_REG_NOP;
                        c_branch_sel = `BRANCH_SEL_NOP;
                        c_branch_j = `J_SEL_NOP;
                        c_rt_imme_sel = `RT_SEL_NOP;
                        c_alu_sel = `ALU_SEL_NOP;
                        c_w_mem_en = `W_MEM_NOP;
                        c_wb_sel = `WB_SEL_NOP;
                    end

                endcase
            end
            `ADDI_OP_CODE:begin
                        c_rt_rd_sel = `W_TD_SEL_RT;
                        c_wb_reg_en =  `W_REG_ENABLE;
                        c_branch_sel = `BRANCH_SEL_NOP;
                        c_branch_j =`J_SEL_NOP;
                        c_rt_imme_sel = `RT_SEL_IMME;
                        c_alu_sel = `ALU_SEL_ADD;
                        c_w_mem_en = `W_MEM_DISABLE;
                        c_wb_sel = `WB_SEL_ALU;
            end

            `LW_OP_CODE:begin
                        c_rt_rd_sel = `W_TD_SEL_RT;
                        c_wb_reg_en = `W_REG_ENABLE;
                        c_branch_sel = `BRANCH_SEL_NOP;
                        c_branch_j = `J_SEL_NOP;
                        c_rt_imme_sel = `RT_SEL_IMME;
                        c_alu_sel = `ALU_SEL_ADD;
                        c_w_mem_en = `W_MEM_DISABLE;
                        c_wb_sel = `WB_SEL_MEM;
            end

            `SW_OP_CODE:begin
                        c_rt_rd_sel = `W_TD_SEL_NOP;
                        c_wb_reg_en =`W_REG_DISABLE;
                        c_branch_sel =`BRANCH_SEL_NOP;
                        c_branch_j =`J_SEL_NOP;
                        c_rt_imme_sel =`RT_SEL_IMME;
                        c_alu_sel =`ALU_SEL_ADD;
                        c_w_mem_en =`W_MEM_ENABLE;
                        c_wb_sel =`WB_SEL_NOP;
            end

            `BEQ_OP_CODE:begin
                        c_rt_rd_sel = `W_TD_SEL_NOP;
                        c_wb_reg_en =`W_REG_NOP;
                        c_branch_sel =`BRANCH_SEL_BEQ;
                        c_branch_j =`J_SEL_NOP;
                        c_rt_imme_sel =`RT_SEL_NOP;
                        c_alu_sel =`ALU_SEL_NOP;
                        c_w_mem_en =`W_MEM_NOP;
                        c_wb_sel =`WB_SEL_NOP;
            end

            `J_OP_CODE:begin
                        c_rt_rd_sel = `W_TD_SEL_NOP;
                        c_wb_reg_en = `W_REG_NOP;
                        c_branch_sel = `BRANCH_SEL_NOP;
                        c_branch_j = `J_SEL_J;
                        c_rt_imme_sel = `RT_SEL_NOP;
                        c_alu_sel = `ALU_SEL_NOP;
                        c_w_mem_en = `W_MEM_NOP;
                        c_wb_sel = `WB_SEL_NOP;
            end

            default:begin
                        c_rt_rd_sel = `W_TD_SEL_NOP;
                        c_wb_reg_en =`W_REG_NOP;
                        c_branch_sel =`BRANCH_SEL_NOP;
                        c_branch_j =`J_SEL_NOP;
                        c_rt_imme_sel =`RT_SEL_NOP;
                        c_alu_sel =`ALU_SEL_NOP;
                        c_w_mem_en =`W_MEM_NOP;
                        c_wb_sel =`WB_SEL_NOP;
            end
        endcase
    
    end
endmodule
