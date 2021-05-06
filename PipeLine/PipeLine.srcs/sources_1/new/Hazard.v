`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/26 08:45:57
// Design Name: 
// Module Name: Hazard
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


module Hazard(
    input wire [4:0] id_rs_addr_hz,
    input wire [4:0] id_rt_addr_hz,
    input wire branch_op_hz,
    input wire j_op_hz,
    input wire id_ex_mem_r_hz,
    input wire ex_mem_mem_r_hz,
    input wire [4:0] id_ex_rt_addr_hz,
    input wire [4:0] id_ex_rs_addr_hz,
    input wire [4:0] id_ex_rd_addr_hz,
    input wire id_ex_reg_en_hz,
    input wire ex_mem_reg_en_hz,
    input wire [4:0] ex_mem_rd_addr_hz,
    input wire mem_wb_reg_en_hz,
    input wire [4:0] mem_wb_rd_addr_hz,

    output reg pc_stall_hz,
    output reg if_id_stall_hz,
    output reg if_id_flush_hz,

    output reg id_ex_flush_hz,

    output reg [1:0] ex_forwardA_hz,
    output reg [1:0] ex_forwardB_hz,
    output reg [1:0] id_forwardA_hz,
    output reg [1:0] id_forwardB_hz
    );
//ex

    always @(*) begin
        ex_forwardA_hz = 2'b00;
        if(ex_mem_reg_en_hz && (ex_mem_rd_addr_hz != 5'd0) && 
        (ex_mem_rd_addr_hz == id_ex_rs_addr_hz))
        begin
            ex_forwardA_hz = 2'b01;                
        end else if (mem_wb_reg_en_hz && (mem_wb_rd_addr_hz != 5'd0) &&
        (mem_wb_rd_addr_hz == id_ex_rs_addr_hz)) begin
            ex_forwardA_hz = 2'b10;
        end
    end

    always @(*) begin
        ex_forwardB_hz = 2'b00;
        if(ex_mem_reg_en_hz && (ex_mem_rd_addr_hz != 5'd0) &&
        (ex_mem_rd_addr_hz == id_ex_rt_addr_hz)) begin
            ex_forwardB_hz = 2'b01;
        end else if (mem_wb_reg_en_hz && (mem_wb_rd_addr_hz != 5'd0) &&
        (mem_wb_rd_addr_hz == id_ex_rt_addr_hz)) begin
            ex_forwardB_hz = 2'b10;
        end
    end

    always @(*) begin
        id_forwardA_hz = 2'b00;
        if(ex_mem_reg_en_hz && (ex_mem_rd_addr_hz!= 5'd0) &&
        (ex_mem_rd_addr_hz == id_rs_addr_hz)) begin
            id_forwardA_hz = 2'b01;
        end else if(mem_wb_reg_en_hz && (mem_wb_rd_addr_hz != 5'd0)&&
        (mem_wb_rd_addr_hz == id_rs_addr_hz)) begin
            id_forwardA_hz = 2'b10;
        end
    end

    always @(*) begin
        id_forwardB_hz = 2'b00;
        if(ex_mem_reg_en_hz && (ex_mem_rd_addr_hz!= 5'd0) && 
        (ex_mem_rd_addr_hz == id_rt_addr_hz)) begin
            id_forwardB_hz = 2'b01;
        end else if (mem_wb_reg_en_hz && (mem_wb_rd_addr_hz != 5'd0) &&
        (mem_wb_rd_addr_hz == id_rt_addr_hz))begin
            id_forwardB_hz = 2'b10;
        end
    end

    always @(*) begin
        if(j_op_hz) begin
           pc_stall_hz = 1'b0;
           if_id_stall_hz = 1'b0;   
           if_id_flush_hz = 1'b1;   //不是延迟槽 所以flush掉了
           id_ex_flush_hz = 1'b0; 
        end else if(branch_op_hz) begin //based on forward
        //stall and flush, then get forward
        // if lw 当指令类型为lw的时候  需要阻塞pc  阻塞id_if  清零id_ex
            if(id_ex_mem_r_hz && ((id_ex_rd_addr_hz == id_rs_addr_hz )||   
            (id_ex_rd_addr_hz == id_rt_addr_hz))) begin
                pc_stall_hz = 1'b1;
                if_id_stall_hz = 1'b1;
                if_id_flush_hz = 1'b0;
                id_ex_flush_hz = 1'b1;
            end else if(ex_mem_mem_r_hz && ((ex_mem_rd_addr_hz == id_rs_addr_hz)||
            (ex_mem_rd_addr_hz == id_rt_addr_hz))) begin  //此时同理需要清零 id_ex  阻塞if_id 和 pc
                pc_stall_hz = 1'b1;
                if_id_stall_hz = 1'b1;
                if_id_flush_hz = 1'b0;
                id_ex_flush_hz = 1'b1;
            end else if(id_ex_reg_en_hz && (id_ex_rd_addr_hz!=5'd0) &&
            ((id_ex_rd_addr_hz == id_rs_addr_hz)||    //需要回写情况 只需阻塞一次 当ex执行完 即可以在下一次上升沿后 在ex_mem得到alu_res
                (id_ex_rd_addr_hz == id_rt_addr_hz))) begin
                    pc_stall_hz = 1'b1;
                    if_id_stall_hz = 1'b1;
                    if_id_flush_hz = 1'b0;
                    id_ex_flush_hz = 1'b1;
            end else begin  //just beq or bne  此时等同于j指令 
                pc_stall_hz = 1'b0;
                if_id_stall_hz = 1'b0;
                if_id_flush_hz = 1'b1;
                id_ex_flush_hz = 1'b0;        
            end
        end else begin  //当不是分支指令时，出现ex_mem_r  一定为add或sub等指令前刚好有一条lw  需要阻塞一次
            if(id_ex_mem_r_hz && ((id_ex_rd_addr_hz == id_rs_addr_hz)|| //阻塞一次，然后之前的ex阶段的结果更新触发器到ex_mem 
            (id_ex_rd_addr_hz == id_rt_addr_hz))) begin                 //然后mem阶段执行ex_mem传来的新数据  得到读mem结果
                pc_stall_hz = 1'b1;                                    //然后在阻塞一次后的时钟上升沿，mem结果更新到mem_wb寄存器
                if_id_stall_hz = 1'b1;                                 //然后此时wb的值 就可以通过旁路的方式传给ex模块（之前阻塞在id）
                if_id_flush_hz = 1'b0;
                id_ex_flush_hz = 1'b1;  
            end else begin
                pc_stall_hz = 1'b0;
                if_id_stall_hz = 1'b0;
                if_id_flush_hz = 1'b0;
                id_ex_flush_hz = 1'b0;
            end
        end
    end
endmodule
