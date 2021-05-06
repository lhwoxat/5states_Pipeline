`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/26 08:45:57
// Design Name: 
// Module Name: IF
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

module IF(
    input wire                            clk,
    input wire                             en,
    input wire                            rst,
    input wire [1:0]               branch_sel,
    input wire [1:0]                    j_sel,
    input wire [`BRANCH_I_IMME-1:0]    i_imme,
    input wire [`INSTR_WIDTH-1 : 0]   rs_data,
    input wire [`INSTR_WIDTH-1 : 0]   rt_data,
    input wire [`BRANCH_J_IMME- 1:0]   j_imme,

    input wire [`INSTR_WIDTH-1 :0] id_rs_data,
    input wire [`INSTR_WIDTH -1 :0]     id_pc,
    output wire [`INSTR_WIDTH-1 :0]     instr,
    output wire [`INSTR_WIDTH-1 :0]     pc_if
    );

    reg [2:0] pc_sel;
    wire [`INSTR_WIDTH-1 :0] W_pc,W_next_pc;
    always @(*) begin
        if(j_sel == `J_SEL_NOP)begin
            case(branch_sel)
                `BRANCH_SEL_NOP :begin
                    pc_sel = `PC_SEL_ADD4;
                end
                `BRANCH_SEL_BEQ :begin
                    if(rs_data == rt_data)
                        pc_sel = `PC_SEL_BRANCH;
                    else  pc_sel = `PC_SEL_ADD4;
                end
                `BRANCH_SEL_BNE: begin
                    if(rs_data != rt_data)
                        pc_sel = `PC_SEL_BRANCH;
                    else pc_sel = `PC_SEL_ADD4;
                end

                default :begin
                    pc_sel = `PC_SEL_ADD4;
                end
            endcase
        end else begin
            case(j_sel)
                `J_SEL_J:begin
                    pc_sel = `PC_SEL_J;
                end
                `J_SEL_JR:begin
                    pc_sel =`PC_SEL_JR;
                end
                `J_SEL_JAL:begin
                    pc_sel = `PC_SEL_JAL;
                end

                default:begin
                    pc_sel = `PC_SEL_ADD4;
                end
            endcase
        end
    end

    PC pc(
    .clk(clk),
    .en(~en),
    .rst(rst),
    .next_pc(W_next_pc),
    .pc(W_pc) 
    );

    NEXT_PC next_pc(
    .pc(W_pc),
    .pc_sel(pc_sel),
    .i_imme(i_imme),
    .j_imme(j_imme),
    .rs_data(id_rs_data),
    .id_pc(id_pc),  //其中id_pc用来求当beq等指令类型时候的next_pc
    .next_pc(W_next_pc)
    );

    Instr_ROM instr_rom (
        .clka(clk), //上升沿取指
        .ena(~rst),
        .addra(W_next_pc),//next_pc  *
        .douta(instr) //在上升沿一瞬间  pc更新为pc_next   Next_pc的组合电路迅速根据新的pc计算出pc_next的值
    );
    assign pc_if = W_next_pc;
endmodule
