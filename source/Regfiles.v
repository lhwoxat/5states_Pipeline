`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/27 14:34:50
// Design Name: 
// Module Name: Regfiles
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
module Regfiles(
    input wire clk,
    input wire rst,
    input wire [4:0] rs_addr,
    input wire [4:0] rt_addr,
    input wire w_en,
    input wire [4:0] w_addr,
    input wire [31:0] w_data,

    output reg [31:0] rs_data,
    output reg [31:0] rt_data 
    );
    reg[31:0] regfile[31:0];

    integer i;
    initial begin
        for(i = 0; i<32 ; i = i+1)begin
            regfile[i] = 32'h0000_0000;
        end
    end
//rs
    always @(*) begin
        if(rst) begin
            rs_data = {32{1'b0}}; 
        end else if (w_en == 1'b1 && w_addr == rs_addr) begin
            rs_data = w_data;
        end else begin
            rs_data = regfile[rs_addr];
        end
    end

//rt

    always @(*) begin
        if(rst) begin
            rt_data = {32{1'b0}}; 
        end else if (w_en == 1'b1 && w_addr == rt_addr) begin
            rt_data = w_data;
        end else begin
            rt_data = regfile[rt_addr];
        end
    end

//w
    always @(posedge clk) begin
        if(w_en) begin
            regfile[w_addr] = w_data;
        end
    end

endmodule
