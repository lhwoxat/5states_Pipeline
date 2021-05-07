`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/26 09:09:06
// Design Name: 
// Module Name: defines
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
//instr
`define INSTR_WIDTH 32
`define BRANCH_I_IMME 16
`define BRANCH_J_IMME 26

//forward
`define Hzd_Sel_rs 2'b00
`define Hzd_Sel_alu 2'b01
`define Hzd_Sel_wb  2'b10


//controller
`define W_TD_SEL_NOP 1'b0
`define W_TD_SEL_RT 1'b1
`define W_TD_SEL_RD 1'b0

`define W_REG_NOP       1'b0
`define W_REG_ENABLE    1'b1
`define W_REG_DISABLE   1'b0

`define BRANCH_SEL_NOP  2'b00
`define BRANCH_SEL_BEQ  2'b01
`define BRANCH_SEL_BNE  2'b10

`define RT_SEL_NOP      1'b0
`define RT_SEL_RT       1'b0
`define RT_SEL_IMME     1'b1

`define J_SEL_NOP       2'b00
`define J_SEL_J         2'b01
`define J_SEL_JR        2'b10
`define J_SEL_JAL       2'b11

`define ALU_SEL_NOP     4'h0
`define ALU_SEL_ADD     4'h0
`define ALU_SEL_SUB     4'h1
`define ALU_SEL_AND     4'h2
`define ALU_SEL_OR      4'h3
`define ALU_SEL_SLT     4'h4

`define W_MEM_NOP       1'b0
`define W_MEM_ENABLE    1'b1
`define W_MEM_DISABLE   1'b0

`define WB_SEL_NOP      1'b0
`define WB_SEL_ALU      1'b0
`define WB_SEL_MEM      1'b1

//pc_sel
`define PC_SEL_ADD4 3'b000
`define PC_SEL_BRANCH 3'b001
`define PC_SEL_J 3'b010
`define PC_SEL_JR 3'b011
`define PC_SEL_JAL 3'b100




//OP-CODES
`define LW_OP_CODE 6'b100_011
`define BEQ_OP_CODE 6'b000_100
`define J_OP_CODE 6'b000_010
`define ARITH_OP_CODE 6'b000_000
`define ADDI_OP_CODE 6'b001_000
`define SW_OP_CODE 6'b101_011

//funct
`define ADD_FUNCT 6'b100_000
`define SUB_FUNCT 6'b100_010
`define AND_FUNCT 6'b100_100
`define OR_FUNCT  6'b100_101
`define SLT_FUNCT 6'b101_010


//ALU
`define ALU_ADD 4'h0
`define ALU_SUB 4'h1
`define ALU_AND 4'h2
`define ALU_OR  4'h3
`define ALU_SLT 4'h4

//next_pc
//j_imme 高四位置0 ?
//rom 选择global 还是ooc
//pc的en 为什么是~en
//包括之后if_id流水线寄存器中的en使能端为什么也是 ~en

//MEM_WB 是否考虑了旁路的情况

//notes
//从一开始，第一个pc上升沿开始，取得第一条pc的值
//随后，第二个时钟上升沿到来，根据IF取得的Instr更新
//if_id寄存器，然后id组合逻辑电路迅速进行译码操作，
//将op与funct传到controller 以更新控制信号传到if
//从而得到下一条pc

//进而实现了多条指令的 “流水进行”

//Hazard注解：
//最后的情况是 当在不是分支的情况下 有mem_r指令存在 
//就代表着 必定为add(sub)等指令前有一条lw指令
//此时一定要阻塞，等待流水线中上一条lw指令的进行，且只阻塞一次就够了
//当阻塞结束后，就可以在ex_mem流水线中得到需要的值
//这种情况下 id_ex_flush_hz 应该为1 让接下来alu不再去执行