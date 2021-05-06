`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/26 08:45:57
// Design Name: 
// Module Name: EX
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
module EX(
    input wire [31:0] id_rs_data,
    input wire [31:0] id_rt_data,
    input wire id_rt_imme_sel, //imme or rt
    input wire [3:0] id_alu_sel,
    input wire [15:0] id_imme_i,

    input wire  [1:0] W_forwardA,
    input wire  [1:0] W_forwardB,
    input wire  [31:0]  ex_mem_alu_res,
    input wire  [31:0]  wb_wb_data,
    // control
    input wire  [4:0]               id_rd,
    // mem
    input wire                      id_w_mem_ena,
    // wb
    input wire                      id_w_reg_en,
    input wire                      id_wb_sel,

    output wire [31:0] ex_alu_res,
    output wire [31:0] ex_rt_data,
    output wire [4:0] ex_rd,
    output wire ex_mem_en,
    output wire ex_w_reg_en,
    output wire ex_wb_sel
    );
    reg [31:0] temp_srca,temp_srcb;

    always @(*) begin
        case(W_forwardA)
            `Hzd_Sel_rs : temp_srca = id_rs_data;
            `Hzd_Sel_alu: temp_srca = ex_mem_alu_res;
            `Hzd_Sel_wb : temp_srca = wb_wb_data;
        endcase
    end

    always @(*) begin
        case(W_forwardB)
            `Hzd_Sel_rs : temp_srcb = id_rt_data;
            `Hzd_Sel_alu :temp_srcb = ex_mem_alu_res;
            `Hzd_Sel_wb : temp_srcb = wb_wb_data;
        endcase
    end

    wire [31:0] alu_src_a,alu_src_b,alu_res_temp;
    assign alu_src_a = temp_srca;
    assign alu_src_b = (id_rt_imme_sel == `RT_SEL_RT) ?
                temp_srcb : {{16{id_imme_i[15]}},id_imme_i};

    ALU alu(
    .src_a(alu_src_a),
    .src_b(alu_src_b),
    .alu_sel(id_alu_sel),
    .alu_res(alu_res_temp)
    );

    assign ex_rd = id_rd;
    assign ex_alu_res = alu_res_temp;
    assign ex_mem_en = id_w_mem_ena;
    assign ex_w_reg_en = id_w_reg_en;
    assign ex_wb_sel = id_wb_sel;
    assign ex_rt_data = temp_srcb;

endmodule
