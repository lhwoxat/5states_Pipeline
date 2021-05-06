Just for practising

Thx lzz so much for his warm help.

In this lab, I finish a 5-stages pipeline. A explicit summary is given below.

**Special**: In this **lab**, thx to the help of Liu, I solved the data hazard and branch hazard in a simple way.



IF: 

```verilog
input  wire                            clk,
input  wire                             en,
input  wire                            rst,
input  wire [1:0]               branch_sel, //determine the branch type and whether a branch is needed
input  wire [1:0]                    j_sel,//determine the j type
input  wire [`BRANCH_I_IMME-1:0]    i_imme,//to calculate next_pc
input  wire [`INSTR_WIDTH-1 : 0]   rs_data, //to get pc_sel
input  wire [`INSTR_WIDTH-1 : 0]   rt_data,// to get_pc_sel
input  wire [`BRANCH_J_IMME- 1:0]   j_imme, // next_pc
input  wire [`INSTR_WIDTH-1 :0] id_rs_data, // next_pc
input  wire [`INSTR_WIDTH -1 :0]     id_pc, // next_pc
output wire [`INSTR_WIDTH-1 :0]      instr,  // instruction	
output wire [`INSTR_WIDTH-1 :0]      pc_if   //to update reg if_id
```

In this part, I mainly encountered the following points:

Firstly, I have a better understanding of how triggers work.

When the posedge clk comes, pc will update the value of next_pc. Then, next_pc will be calculated quickly.

The triggers will update the previous value to the new value.

For example, instr_rom will use next_pc(before calculating with new pc)  to get new instr.

And the next point is, I noticed a small bug, which means the first instruction will be executed twice. But now, this bug is solved by setting enable signal to the opposite number of rst.



REG IF_ID:

```verilog
    input  wire 	clk,
    input  wire 	en,
    input  wire 	rst,
    input  wire 	clear,
    input  wire [`INSTR_WIDTH-1 :0] instr_if_i,
	input  wire [`INSTR_WIDTH-1 :0]    pc_if_i,
    output wire [`INSTR_WIDTH-1 :0] instr_if_o,
	output wire [`INSTR_WIDTH-1 :0]      pc_if_o
```

register if_id is just used to 'flow water' instruction.



ID:

```verilog
    input wire clk,
    input wire rst,
    input wire [`INSTR_WIDTH-1 :0] instr_if,
    //wb
    input wire wb_reg_en, //from wb
    input wire [4:0] wb_reg_addr, //from wb to update regfile
    input wire [`INSTR_WIDTH-1 :0] wb_reg_data, // from wb

    //output & sel
    output wire [5:0] op_out, //to control
    output wire [5:0] funct_out,  //to control
    
    //from control
    input wire rt_rd_sel, //to choose next pos to update wbs
    input wire reg_en,
    input wire rt_sel,
    input wire [3:0] alu_sel,
    input wire mem_en,
    input wire wb_sel,
    
    output wire [15:0] id_imme_i,
    output wire [25:0] id_imme_j,
    output wire [4:0] id_rs, 
    output wire [4:0] id_rt, 
	output wire [4:0] id_rd, //writeback addr

    output wire [`INSTR_WIDTH-1:0] id_rs_data_out,
    output wire [`INSTR_WIDTH-1:0] id_rt_data_out,
    //control

    //id
    output wire id_branch_op,
    output wire id_j_op,
    output wire id_mem_r_en, 
    
    //control  ex
    output wire id_rt_sel,
    output wire [3:0] id_alu_sel,
    //mem   
    output wire id_mem_en,
    //wb
    output wire id_w_reg_en,
    output wire id_wb_sel
```

In this part, I decode the instruction from the if_id register, and get control signal from controller.



ID_EX:

```verilog
        input wire clk,en,rst,clear,
        input wire [15:0] id_immei_i,
        input wire [4:0] id_rs_addr_i,
        input wire [4:0] id_rt_addr_i,
        input wire [4:0] id_rd_addr_i,
        input wire [31:0] id_rs_data_i,
        input wire [31:0] id_rt_data_i,

        input wire id_rt_imme_sel_i,
        input wire [3:0] id_alu_sel_i,
        input wire id_mem_en_i,
        input wire id_wb_reg_en_i,
        input wire id_wb_sel_i,
        input wire id_mem_r_i,

        output wire [15:0] id_immei_o,
        output wire [4:0] id_rs_addr_o,
        output wire [4:0] id_rt_addr_o,
        output wire [4:0] id_rd_addr_o,
        output wire [31:0] id_rs_data_o,
        output wire [31:0] id_rt_data_o,

        output wire id_rt_imme_sel_o,
        output wire [3:0] id_alu_sel_o,
        output wire id_mem_en_o,
        output wire id_wb_reg_en_o,
        output wire id_wb_sel_o,
        output wire id_mem_r_o
```

In this part, I have to pass the control signal for module ex,mem,wb. And pass the rs/rt addr and data for ex module.



EX:

```VERILOG
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

//to solve data hazard
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
```

W_forwadrA and W_forwardB are used to solve data hazard (this method called 旁路). And block is controlled in Hazard module.



EX_MEM:

```VERILOG
    input wire clk, en, rst, clear,
    
    input wire [31:0] ex_alu_res_i,
    input wire [31:0] ex_rt_data_i, //to write mem

    input wire [4:0] ex_rd_i,
    input wire ex_mem_en_i,
    input wire ex_reg_en_i,
    input wire ex_reg_sel_i,

    input wire ex_mem_r_i,
    input wire [4:0] ex_rs_addr_i,
    input wire [4:0] ex_rt_addr_i,
    //output
    output wire [31:0] ex_alu_res_o,
    output wire [31:0] ex_rt_data_o, //to write mem
    output wire [4:0] ex_rd_o,
    output wire ex_mem_en_o,
    output wire ex_reg_en_o,
    output wire ex_reg_sel_o,
    output wire ex_mem_r_o,
	output wire [4:0] ex_rs_addr_o, //not used
	output wire [4:0] ex_rt_addr_o // not used 
```

Pass control signal and ex_Data to mem.



Mem:

```verilog
    input wire clk,
    input wire mem_mem_en,
    input wire [31:0] mem_alu_res,
    input wire [31:0] mem_memdata,
    input wire [4:0] mem_rd_addr,
    input wire mem_wb_reg_en,
    input wire mem_wb_wb_sel,

    output wire [31:0] wb_mem_data,
    output wire [31:0] wb_alu_res,
    output wire [4:0] wb_wb_rd_addr,
    output wire wb_reg_en,
    output wire wb_wb_sel
```

Mem part.



Mem_WB:

```verilog
    input wire clk,en,rst,clear,

    input wire [31:0] mem_mem_data_i,
    input wire [31:0] mem_alu_res_i,
    input wire [4:0] mem_rd_addr_i,
    input wire mem_wb_reg_en_i,
    input wire mem_wb_wb_sel_i,

    output wire [31:0] mem_mem_data_o,
    output wire [31:0] mem_alu_res_o,
    output wire [4:0] mem_rd_addr_o,
    output wire mem_wb_reg_en_o,
    output wire mem_wb_wb_sel_o
```

To pass data for wb and control signal to control wb.



Wb:

```verilog
    input wire [31:0] mem_alu_res,
    input wire [31:0] mem_mem_data,
    
    //control
    input wire mem_wb_sel, //alu or mem_ram
    input wire [4:0] mem_rd,
    input wire mem_wb_en,

    output wire wb_reg_en,
    output wire [4:0] wb_reg_addr,
    output wire [31:0] wb_reg_data
```

Hazard:

```verilog
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
```

