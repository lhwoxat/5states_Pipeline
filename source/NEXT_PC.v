`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/26 09:07:57
// Design Name: 
// Module Name: NEXT_PC
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

module NEXT_PC(
    input wire [`INSTR_WIDTH-1:0] pc,
    input wire [2:0] pc_sel,
    input wire [`BRANCH_I_IMME-1 :0] i_imme,
    input wire [`BRANCH_J_IMME-1 :0] j_imme,
    input wire [`INSTR_WIDTH-1:0] rs_data,
    input wire [`INSTR_WIDTH-1 :0]  id_pc,
    output reg [`INSTR_WIDTH-1:0] next_pc
    );

    wire [`INSTR_WIDTH -1 : 0] pc_add_4;
    assign pc_add_4 = pc + 32'd4;
    always @(*) begin
        case(pc_sel)
                `PC_SEL_ADD4: begin
                    next_pc = pc_add_4;
                end
                `PC_SEL_BRANCH :begin
                    next_pc = id_pc + {{14{i_imme[15]}},i_imme[15:0],2'b00};
                end
                `PC_SEL_J : begin
                    next_pc = id_pc + {id_pc[31:28],j_imme[25:0],2'b00};
                end
                `PC_SEL_JR :begin
                    next_pc = rs_data;
                end
                `PC_SEL_JAL:begin
                    next_pc = id_pc + {4'b0000,j_imme[25:0],2'b00};
                end
                default: begin
                    next_pc = 32'h0000_0000;
                end
        endcase
    end
endmodule
