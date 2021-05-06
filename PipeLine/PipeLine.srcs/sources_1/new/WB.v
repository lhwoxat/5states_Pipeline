`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/26 08:45:57
// Design Name: 
// Module Name: WB
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
module WB(
    input wire [31:0] mem_alu_res,
    input wire [31:0] mem_mem_data,
    
    //control
    input wire mem_wb_sel, //alu or mem_ram
    input wire [4:0] mem_rd,
    input wire mem_wb_en,

    output wire wb_reg_en,
    output wire [4:0] wb_reg_addr,
    output wire [31:0] wb_reg_data
    );

    assign wb_reg_en = mem_wb_en;
    assign wb_reg_addr = mem_rd;
    //if mem_wb_sel == 1'b0  then wb_reg_data == alu_res 
    //else wb_reg_data = mem_mem_data
    assign wb_reg_data = ({32{~mem_wb_sel}} & mem_alu_res)|
                         ({32{mem_wb_sel}} & mem_mem_data); 

endmodule
