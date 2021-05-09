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

A copy of icache, and i start to get it now.

icache:

```verilog
module yamp32_icache
#(
    parameter P_WAYS = -1, // 2^ways
    parameter P_SETS = -1, // 2^sets
    parameter P_LINE = -1, // 2^P_LINE bytes per line (= busrt length of SRAM)
    parameter SRAM_AW = 20
)
(
    input wire            i_clk,
    input wire            i_rst_n,
    // CPU interface
    input wire [31:0]     i_pc_paddr,
    input wire            i_req,
    output wire           o_stall,
    output wire [31:0]    o_insn,
    
    // SRAM interface
    input wire [31:0]     i_sram_dout,
    output wire           o_sram_br_req,
    input wire            i_sram_br_ack,
    output wire [SRAM_AW-1:0] o_sram_br_addr
);
    localparam TAG_ADDR_DW = SRAM_AW+2-P_SETS-P_LINE;
    
    reg mmreq_r;
    reg [31:0] maddr_r;
    wire mmreq = o_stall ? mmreq_r : i_req;
    wire [31:0] maddr = o_stall ? maddr_r : i_pc_paddr;
    
    always @(posedge i_clk or negedge i_rst_n)
        if (~i_rst_n) begin
            mmreq_r <= 1'b0;
        end else if (~o_stall) begin // When stalling we don't accept incoming request and address
            mmreq_r <= i_req;
            maddr_r <= i_pc_paddr;
        end
    
    reg                 nl_rd_r;            // Read from next level cache/memory ?
    reg [SRAM_AW+2-P_LINE-1:0] nl_baddr_r;
    wire                slow_nl_r_pending;  // Is cache line reading from SRAM ?
    wire [31:0]         slow_nl_dout;
    
    // Main FSM states
    localparam S_BOOT = 3'b000;
    localparam S_IDLE = 3'b001;
    localparam S_READ_PENDING_1 = 3'b011;
    localparam S_READ_PENDING_2 = 3'b010;
    
    reg [2:0] status_r;
    wire ch_idle = (status_r == S_IDLE);
    reg [P_LINE-2-1:0] slow_line_adr_cnt;
    reg [P_SETS-1:0] clear_cnt;

    wire [P_SETS-1:0] entry_idx = (status_r==S_BOOT) ? clear_cnt : maddr[P_LINE+P_SETS-1:P_LINE];

    // Read
    wire                    cache_v     [0:(1<<P_WAYS)-1];
    wire [TAG_ADDR_DW-1:0]  cache_addr  [0:(1<<P_WAYS)-1];
    wire [P_WAYS-1:0]       cache_lru   [0:(1<<P_WAYS)-1];
    
    // Write
    reg                     w_cache_v_prv       [0:(1<<P_WAYS)-1];
    reg [TAG_ADDR_DW-1:0]   w_cache_addr_prv    [0:(1<<P_WAYS)-1];
    reg [P_WAYS-1:0]        w_lru_prv           [0:(1<<P_WAYS)-1];
    
    reg [P_SETS-1:0] entry_idx_prv;
    
    always @(posedge i_clk)
        entry_idx_prv <= entry_idx;
    
    localparam TAG_DW = 1+TAG_ADDR_DW;
    
    // Cache entries
generate
    genvar i;
    for(i=0;i<(1<<P_WAYS);i=i+1) begin
        wire [TAG_DW-1:0] tag_dina, tag_doutb;
        wire [P_SETS-1:0] addr_prv = (status_r == S_BOOT) ? entry_idx : entry_idx_prv;
        
        assign tag_dina = {w_cache_v_prv[i], w_cache_addr_prv[i]};
        assign {cache_v[i], cache_addr[i]} = tag_doutb;

        // Tags
        xpm_sdpram_bypass #(
            .ADDR_WIDTH(P_SETS),
            .DATA_WIDTH(TAG_DW)
        )
        cache_tags (
            .clk    (i_clk),
            .rst_n  (i_rst_n),
            // Port A (Write)
            .addra  (addr_prv),
            .dina   (tag_dina),
            .ena    (1'b1),
            .wea    (1'b1),
            // Port B (Read)
            .doutb  (tag_doutb),
            .addrb  (entry_idx),
            .enb    (1'b1)
        );
        
        // LRU
        xpm_sdpram_bypass #(
            .ADDR_WIDTH(P_SETS),
            .DATA_WIDTH(P_WAYS)
        )
        cache_lru (
            .clk    (i_clk),
            .rst_n  (i_rst_n),
            // Port A (Write)
            .addra  (addr_prv),
            .dina   (w_lru_prv[i]),
            .ena    (1'b1),
            .wea    (1'b1),
            // Port B (Read)
            .doutb  (cache_lru[i]),
            .addrb  (entry_idx),
            .enb    (1'b1)
        );
    end
endgenerate
    
    wire [(1<<P_WAYS)-1:0] match;
    wire [(1<<P_WAYS)-1:0] free;
    wire [P_WAYS-1:0] lru[(1<<P_WAYS)-1:0];
generate
    for(i=0; i<(1<<P_WAYS); i=i+1) begin : entry_wires
      assign match[i] = cache_v[i] & (cache_addr[i] == maddr_r[SRAM_AW+2-1:P_LINE+P_SETS]);
      assign free[i] = ~|cache_lru[i];
      assign lru[i] = {P_WAYS{match[i]}} & cache_lru[i];
    end
endgenerate

    wire hit = |match;

    wire [P_WAYS-1:0] match_way;
    wire [P_WAYS-1:0] free_way_idx;
    wire [P_WAYS-1:0] lru_thresh;
    
generate
    if (P_WAYS==2) begin : p_ways_2
        // 4-to-2 binary encoder.
        assign match_way = {|match[3:2], match[3] | match[1]};
        // 4-to-2 binary encoder
        assign free_way_idx = {|free[3:2], free[3] | free[1]};
        // LRU threshold
        assign lru_thresh = lru[0] | lru[1] | lru[2] | lru[3];
    end else if (P_WAYS==1) begin : p_ways_1
        // 1-to-2 binary encoder.
        assign match_way = match[1];
        // 1-to-2 binary encoder
        assign free_way_idx = free[1];
        // LRU threshold
        assign lru_thresh = lru[0] | lru[1];
    end
endgenerate

    // Slow side
    // Maintain the line addr counter,
    // when burst transmitting while cache line filling or writing back
    always @(posedge i_clk or negedge i_rst_n)
        if(~i_rst_n)
            slow_line_adr_cnt <= {P_LINE-2{1'b0}};
        else if(slow_nl_r_pending)
            slow_line_adr_cnt <= slow_line_adr_cnt + 1'b1;

    localparam CH_AW = P_WAYS+P_SETS+P_LINE-2;
    
    wire ch_mem_en_a = slow_nl_r_pending;
    wire ch_mem_we_a = slow_nl_r_pending;
    wire [CH_AW-1:0] ch_mem_addr_a = {match_way, ~entry_idx[P_SETS-1:0], slow_line_adr_cnt[P_LINE-3:0]};
    wire [31:0] ch_mem_din_a = slow_nl_dout;
    wire ch_mem_en_b = mmreq & ch_idle;
    wire [CH_AW-1:0] ch_mem_addr_b = {match_way, ~entry_idx[P_SETS-1:0], maddr[P_LINE-1:2]};
    wire [31:0] ch_mem_dout_b;
    
    // IMPORTANT! regenerate this core after parameters changed
    // Write-First
    blk_mem_icache cache_mem(
        // Slow side (SRAM)
        .clka    (i_clk),
        .addra   (ch_mem_addr_a[CH_AW-1:0]),
        .wea     (ch_mem_we_a),
        .dina    (ch_mem_din_a[31:0]),
        .ena     (ch_mem_en_a),
        // Fast side (CPU)
        .clkb    (i_clk),
        .addrb   (ch_mem_addr_b[CH_AW-1:0]),
        .doutb   (ch_mem_dout_b[31:0]),
        .enb     (ch_mem_en_b)
    );

    assign o_insn = ch_mem_dout_b;

generate
    for(i=0; i<(1<<P_WAYS); i=i+1) begin : gen_wyas
        always @(*) begin
            if(ch_idle & (mmreq_r & hit)) begin
                // Update LRU priority
                w_lru_prv[i] = match[i] ? {P_WAYS{1'b1}} : cache_lru[i] - (cache_lru[i] > lru_thresh); 
            end else if(status_r == S_BOOT) begin
                // Set the initial value of LRU
                w_lru_prv[i] = i;
            end else begin
                w_lru_prv[i] = cache_lru[i];
            end
        end
        
        always @(*) begin
            if (ch_idle & (mmreq_r & ~hit) & (free_way_idx==i)) begin
                // Refill info when cache miss
                w_cache_v_prv[i] = 1'b1;
                w_cache_addr_prv[i] = maddr_r[SRAM_AW+2-1:P_LINE+P_SETS];
            end else if(status_r==S_BOOT) begin
                w_cache_v_prv[i] = 1'b0;
                w_cache_addr_prv[i] = {TAG_ADDR_DW{1'b0}};
            end else begin
                w_cache_v_prv[i] = cache_v[i];
                w_cache_addr_prv[i] = cache_addr[i];
            end
        end
         
    end
endgenerate

    wire line_adr_cnt_msb = slow_line_adr_cnt[P_LINE-3];

    reg s_stall_r;
    assign o_stall = (ch_idle & mmreq_r & ~hit) | s_stall_r;
    
    // Main FSM
    always @(posedge i_clk or negedge i_rst_n) begin
      if(~i_rst_n) begin
         status_r <= S_BOOT;
         clear_cnt <= {P_SETS{1'b1}};
         s_stall_r <= 1'b1;
      end else begin
         // Main FSM
         case(status_r)
            S_BOOT: begin
                // Invalidate cache lines by hardware
                clear_cnt <= clear_cnt - 1'b1;
                if (clear_cnt == {P_SETS{1'b0}}) begin
                    status_r <= S_IDLE;
                    s_stall_r <= 1'b0;
                end
            end
            
            S_IDLE: begin
                nl_baddr_r <= maddr_r[SRAM_AW+2-1:P_LINE];
                if(mmreq_r & ~hit) begin
                  // Cache missed
                  // Fill a free entry.
                  nl_rd_r <= 1'b1;
                  status_r <= S_READ_PENDING_1;
                  s_stall_r <= 1'b1;
                end else begin
                  // Cache hit or idle
                  s_stall_r <= 1'b0;
                end
            end
            // Pending for reading
            S_READ_PENDING_1: begin 
                if(line_adr_cnt_msb)
                  status_r <= S_READ_PENDING_2;
            end
            S_READ_PENDING_2: begin
                nl_rd_r <= 1'b0;
                if(~line_adr_cnt_msb) begin
                  status_r <= S_IDLE;
                end
            end
         endcase
      end
    end

    // Receive signals from nl_*

    assign o_sram_br_req = nl_rd_r;
    assign o_sram_br_addr  = {nl_baddr_r[SRAM_AW+2-P_LINE-1:0], {P_LINE-2{1'b0}}}; // Aligned at 4 bytes
    assign slow_nl_r_pending = i_sram_br_ack;
    assign slow_nl_dout = i_sram_dout;
    
endmodule
    
```



