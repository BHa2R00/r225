`timescale 1ns/1ps


module rv32e 
#(
  parameter main=1 
)
(
  output            halt, 
   input            wakeup, 
  output            ret, 
   input            hwsetb, 
  // data 
   input     [31:0] d_rdata, 
   input            d_ready, 
  output            d_valid, 
  output     [31:0] d_wdata, 
  output            d_write, 
  output     [31:0] d_addr, 
  output     [ 1:0] d_size, 
  input             d_rstb, d_clk,
  // instruction 
   input     [31:0] i_rdata, 
   input            i_ready, 
  output            i_valid, 
  output     [31:0] i_wdata, 
  output            i_write, 
  output     [31:0] i_addr, 
  output     [ 1:0] i_size, 
   input            i_rstb, i_clk,
  // configure 
  output reg        c_ready, 
  output     [31:0] c_rdata, 
   input     [31:0] c_wdata, 
   input            c_write, 
   input     [31:0] c_addr, 
   input     [ 1:0] c_size, 
   input            c_valid, 
   input            c_rstb, c_clk 
);

reg [30:0] pc, entry;
reg [31:0] mem[1:15];
wire [31:0] ra  = mem[01];
wire [31:0] sp  = mem[02];
wire [31:0] gp  = mem[03];
wire [31:0] tp  = mem[04];
wire [31:0] t0  = mem[05];
wire [31:0] t1  = mem[06];
wire [31:0] t2  = mem[07];
wire [31:0] s0  = mem[08];
wire [31:0] s1  = mem[09];
wire [31:0] a0  = mem[10];
wire [31:0] a1  = mem[11];
wire [31:0] a2  = mem[12];
wire [31:0] a3  = mem[13];
wire [31:0] a4  = mem[14];
wire [31:0] a5  = mem[15];
reg [31:0] ra_next;
reg [31:0] sp_next;
reg [31:0] gp_next;
reg [31:0] tp_next;
reg [31:0] t0_next;
reg [31:0] t1_next;
reg [31:0] t2_next;
reg [31:0] s0_next;
reg [31:0] s1_next;
reg [31:0] a0_next;
reg [31:0] a1_next;
reg [31:0] a2_next;
reg [31:0] a3_next;
reg [31:0] a4_next;
reg [31:0] a5_next;
//`endif
reg [31:0] i_inst;
wire [6:0] i_opcode = i_inst[6:0];
wire i_3 = i_opcode[1:0]==2'b11;
wire [2:0] i_funct3 = i_inst[14:12];
wire [6:0] i_funct7 = i_inst[31:25];
wire i_add    = &{i_3,(i_opcode[6:2]==5'b01100),(i_funct3==3'h0),(i_funct7==7'h00)};
wire i_sub    = &{i_3,(i_opcode[6:2]==5'b01100),(i_funct3==3'h0),(i_funct7==7'h20)};
wire i_xor    = &{i_3,(i_opcode[6:2]==5'b01100),(i_funct3==3'h4),(i_funct7==7'h00)};
wire i_or     = &{i_3,(i_opcode[6:2]==5'b01100),(i_funct3==3'h6),(i_funct7==7'h00)};
wire i_and    = &{i_3,(i_opcode[6:2]==5'b01100),(i_funct3==3'h7),(i_funct7==7'h00)};
wire i_sll    = &{i_3,(i_opcode[6:2]==5'b01100),(i_funct3==3'h1),(i_funct7==7'h00)};
wire i_srl    = &{i_3,(i_opcode[6:2]==5'b01100),(i_funct3==3'h5),(i_funct7==7'h00)};
wire i_sra    = &{i_3,(i_opcode[6:2]==5'b01100),(i_funct3==3'h5),(i_funct7==7'h20)};
wire i_slt    = &{i_3,(i_opcode[6:2]==5'b01100),(i_funct3==3'h2),(i_funct7==7'h00)};
wire i_sltu   = &{i_3,(i_opcode[6:2]==5'b01100),(i_funct3==3'h3),(i_funct7==7'h00)};
wire i_nop    = &{i_3,(~|i_inst[31:7])};
wire i_addi   = &{i_3,(i_opcode[6:2]==5'b00100),(i_funct3==3'h0)};
wire i_xori   = &{i_3,(i_opcode[6:2]==5'b00100),(i_funct3==3'h4)};
wire i_ori    = &{i_3,(i_opcode[6:2]==5'b00100),(i_funct3==3'h6)};
wire i_andi   = &{i_3,(i_opcode[6:2]==5'b00100),(i_funct3==3'h7)};
wire i_slli   = &{i_3,(i_opcode[6:2]==5'b00100),(i_funct3==3'h1),(i_inst[31:25]==7'h00)};
wire i_srli   = &{i_3,(i_opcode[6:2]==5'b00100),(i_funct3==3'h5),(i_inst[31:25]==7'h00)};
wire i_srai   = &{i_3,(i_opcode[6:2]==5'b00100),(i_funct3==3'h5),(i_inst[31:25]==7'h20)};
wire i_slti   = &{i_3,(i_opcode[6:2]==5'b00100),(i_funct3==3'h2)};
wire i_sltiu  = &{i_3,(i_opcode[6:2]==5'b00100),(i_funct3==3'h3)};
wire i_lb     = &{i_3,(i_opcode[6:2]==5'b00000),(i_funct3==3'h0)};
wire i_lh     = &{i_3,(i_opcode[6:2]==5'b00000),(i_funct3==3'h1)};
wire i_lw     = &{i_3,(i_opcode[6:2]==5'b00000),(i_funct3==3'h2)};
wire i_lbu    = &{i_3,(i_opcode[6:2]==5'b00000),(i_funct3==3'h4)};
wire i_lhu    = &{i_3,(i_opcode[6:2]==5'b00000),(i_funct3==3'h5)};
wire i_sb     = &{i_3,(i_opcode[6:2]==5'b01000),(i_funct3==3'h0)};
wire i_sh     = &{i_3,(i_opcode[6:2]==5'b01000),(i_funct3==3'h1)};
wire i_sw     = &{i_3,(i_opcode[6:2]==5'b01000),(i_funct3==3'h2)};
wire i_beq    = &{i_3,(i_opcode[6:2]==5'b11000),(i_funct3==3'h0)};
wire i_bne    = &{i_3,(i_opcode[6:2]==5'b11000),(i_funct3==3'h1)};
wire i_blt    = &{i_3,(i_opcode[6:2]==5'b11000),(i_funct3==3'h4)};
wire i_bge    = &{i_3,(i_opcode[6:2]==5'b11000),(i_funct3==3'h5)};
wire i_bltu   = &{i_3,(i_opcode[6:2]==5'b11000),(i_funct3==3'h6)};
wire i_bgeu   = &{i_3,(i_opcode[6:2]==5'b11000),(i_funct3==3'h7)};
wire i_jal    = &{i_3,(i_opcode[6:2]==5'b11011)};
wire i_jalr   = &{i_3,(i_opcode[6:2]==5'b11001),(i_funct3==3'h0)};
wire i_lui    = &{i_3,(i_opcode[6:2]==5'b01101)};
wire i_auipc  = &{i_3,(i_opcode[6:2]==5'b00101)};
wire i_ecall  = &{i_3,(i_opcode[6:2]==5'b11100),(i_funct3==3'h0),(i_inst[31:20]==12'h0)};
wire i_ebreak = &{i_3,(i_opcode[6:2]==5'b11100),(i_funct3==3'h0),(i_inst[31:20]==12'h1)};
wire i_wfi    = &{i_3,(i_opcode[6:2]==5'b11100),(i_funct3==3'h0),(i_funct7==7'h08),(i_inst[24:20]==5'h5),(i_inst[19:15]==5'h0)};
wire i_fmt_r = |{i_add,i_sub,i_xor,i_or,i_and,i_sll,i_srl,i_sra,i_slt,i_sltu};
wire i_fmt_i = |{i_nop,i_addi,i_xori,i_ori,i_andi,i_slli,i_srli,i_srai,i_slti,i_sltiu,i_lb,i_lh,i_lw,i_lbu,i_lhu,i_jalr,i_ecall,i_ebreak};
wire i_fmt_s = |{i_sb,i_sh,i_sw};
wire i_fmt_b = |{i_beq,i_bne,i_blt,i_bge,i_bltu,i_bgeu};
wire i_fmt_j = |{i_jal};
wire i_fmt_u = |{i_lui,i_auipc};
wire signed [31:0] imm = 
  i_fmt_i ? {{20{i_inst[31]}},i_inst[31:20]} : 
  i_fmt_s ? {{20{i_inst[31]}},i_inst[31:25],i_inst[11:7]} : 
  i_fmt_b ? {{19{i_inst[31]}},i_inst[31],i_inst[7],i_inst[30:25],i_inst[11:8],1'h0} : 
  i_fmt_u ? {i_inst[31:12],12'h0} : 
  i_fmt_j ? {{12{i_inst[31]}},i_inst[19:12],i_inst[20],i_inst[30:21],1'b0} : 
  32'h0;
wire [4:0] rd = |{i_fmt_r,i_fmt_i,i_fmt_u,i_fmt_j} ? i_inst[11:7] : 5'h0;
wire [4:0] rs1 = |{i_fmt_r,i_fmt_i,i_fmt_s,i_fmt_b} ? i_inst[19:15] : 5'h0;
wire [4:0] rs2 = |{i_fmt_r,i_fmt_s,i_fmt_b} ? i_inst[24:20] : 5'h0;
wire i_instp = &{|i_inst[31:0],i_3};
wire signed [31:0] xrs1 = (rs1==5'd0) ? 32'h0 : mem[rs1[3:0]];
wire signed [31:0] xrs2 = (rs2==5'd0) ? 32'h0 : mem[rs2[3:0]];
wire xrs1s = xrs1[31];
wire xrs2s = xrs2[31];
wire imms = imm[31];
wire [31:0] xrs1u = {1'h0,xrs1[30:0]};
wire [31:0] xrs2u = {1'h0,xrs2[30:0]};
wire [31:0] immu = {1'h0,imm[30:0]};
wire [31:0] ilp32i = 
  i_add   ? (xrs1 +  xrs2) :
  i_xor   ? (xrs1 ^  xrs2) :
  i_or    ? (xrs1 |  xrs2) :
  i_and   ? (xrs1 &  xrs2) :
  i_sll   ? (xrs1 << xrs2[4:0]) :
  i_srl   ? (xrs1 >> xrs2[4:0]) :
  i_sra   ? (xrs1s ? (~((~xrs1) >> xrs2[4:0])):(xrs1 >> xrs2[4:0])) :
  i_addi  ? (xrs1 +  imm) :
  i_xori  ? (xrs1 ^  imm) :
  i_ori   ? (xrs1 |  imm) :
  i_andi  ? (xrs1 &  imm) :
  i_slli  ? (xrs1 << imm[4:0]) :
  i_srli  ? (xrs1 >> imm[4:0]) :
  i_srai  ? (xrs1s ? (~((~xrs1) >> imm[4:0])):(xrs1 >> imm[4:0])) :
  i_jal   ? (pc + 32'd4) :
  i_jalr  ? (pc + 32'd4) :
  i_lui   ? ({32{1'b1}} & imm) :
  i_auipc ? (pc + imm) :
  i_bgeu  ? (xrs1u - xrs2u) : 
  i_bltu  ? (xrs1u - xrs2u) : 
  i_sltiu ? (xrs1u -  immu) :
  i_slti  ? (xrs1 -  imm) : 
  (xrs1 -  xrs2);
wire lt = ilp32i[31];
wire ge = ~lt;
wire ne = |ilp32i;
wire eq = ~ne;
wire branch = |{&{i_bgeu,ge},&{i_bltu,lt},&{i_bge,ge},&{i_blt,lt},&{i_bne,ne},&{i_beq,eq}};
wire [31:0] next_pc = ((i_jalr ? xrs1 : {1'h0,pc}) + (|{i_jal,branch,i_jalr} ? imm : 32'h4));
wire instp = |{i_instp};
wire load = |{i_lb,i_lh,i_lw,i_lbu,i_lhu};
wire store = |{i_fmt_s};
reg setb;
wire set = ~|{setb,hwsetb};

reg FETCH, EXEC, LOAD, STORE, MOVE;
wire FETCH_SET, EXEC_SET, LOAD_SET, STORE_SET, MOVE_SET;
wire FETCH_RST, EXEC_RST, LOAD_RST, STORE_RST, MOVE_RST;
assign FETCH_SET = &{MOVE,i_ready,~set,~FETCH};
assign LOAD_SET = &{FETCH,instp,load,~LOAD};
assign STORE_SET = &{FETCH,instp,store,~STORE};
assign EXEC_SET = &{FETCH,instp,~load,~store,~EXEC};
assign MOVE_SET = &{(EXEC ? 1'b1 : STORE ? d_ready : LOAD ? d_ready : 1'b0),~MOVE};
assign FETCH_RST = |{LOAD_SET,STORE_SET,EXEC_SET};
assign LOAD_RST = MOVE_SET;
assign STORE_RST = MOVE_SET;
assign EXEC_RST = MOVE_SET;
assign MOVE_RST = FETCH_SET;
always@(negedge i_rstb or posedge i_clk) begin
  if(~i_rstb) begin
    FETCH <= 1'b0;
    LOAD <= 1'b0;
    STORE <= 1'b0;
    EXEC <= 1'b0;
    MOVE <= 1'b1;
  end
  else begin
    if(FETCH) FETCH <= ~FETCH_RST; else FETCH <= FETCH_SET;
    if(LOAD) LOAD <= ~LOAD_RST; else LOAD <= LOAD_SET;
    if(STORE) STORE <= ~STORE_RST; else STORE <= STORE_SET;
    if(EXEC) EXEC <= ~EXEC_RST; else EXEC <= EXEC_SET;
    if(MOVE) MOVE <= ~MOVE_RST; else MOVE <= MOVE_SET;
  end
end
wire idle = ~|{FETCH, EXEC, LOAD, STORE};
integer mem_i;
always@(negedge i_rstb or posedge i_clk) begin
  if(~i_rstb) begin
    i_inst <= 32'h0;
    //for(mem_i=1;15>=mem_i;mem_i=mem_i+1) mem[mem_i] <= 32'd0;
    if(main) pc <= 31'd0;
    else pc <= 31'd0;
  end
  else begin
    if(FETCH_SET) i_inst <= i_rdata;
    if(set) pc <= entry;
    else if(FETCH_RST) begin
      pc <= next_pc[30:0];
    end
    if(set && !main) begin
      mem[01] <= ra_next;
      mem[02] <= sp_next;
      mem[03] <= gp_next;
      mem[04] <= tp_next;
      mem[05] <= t0_next;
      mem[06] <= t1_next;
      mem[07] <= t2_next;
      mem[08] <= s0_next;
      mem[09] <= s1_next;
      mem[10] <= a0_next;
      mem[11] <= a1_next;
      mem[12] <= a2_next;
      mem[13] <= a3_next;
      mem[14] <= a4_next;
      mem[15] <= a5_next;
    end
    else if(|{EXEC_SET,LOAD}) begin
      if(&{(rd!=5'd0),~i_nop}) begin
        case(1'b1)
          |{i_slt, i_sltu, i_slti, i_sltiu} : mem[rd[3:0]] <= {31'h0,lt};
          i_lbu : mem[rd[3:0]] <= {{24{1'b0}},d_rdata[7:0]};
          i_lb : mem[rd[3:0]] <= {{24{d_rdata[7]}},d_rdata[7:0]};
          i_lhu : mem[rd[3:0]] <= {{16{1'b0}},d_rdata[15:0]};
          i_lh : mem[rd[3:0]] <= {{16{d_rdata[15]}},d_rdata[15:0]};
          |{i_lw} : mem[rd[3:0]][31:0] <= d_rdata[31:0];
          default : mem[rd[3:0]] <= ilp32i;
        endcase
      end
    end
  end
end
assign halt = i_wfi;
//assign i_valid = &{((halt && ~wakeup) ? 1'b0 : MOVE),~set,~i_ready};
assign i_valid = &{((halt && ~wakeup) ? 1'b0 : MOVE),~set};
assign i_addr = {1'h0,pc[30:0]};
assign i_size = 2'b10;
assign i_write = 1'b0;
assign i_wdata = 32'h0;
//assign d_valid = &{|{STORE,LOAD},~d_ready};
assign d_valid = |{STORE,LOAD};
assign d_addr = xrs1 + imm;
assign d_size = i_sb ? 'b00 : i_sh ? 'b01 : 'b10;
assign d_write = STORE;
assign d_wdata = xrs2;
assign ret = &{~set,(ra==32'hffffffff)};

reg  [31:0] c_rdata1;
wire [31:0] c_wdata1 = c_wdata << (8*c_addr[1:0]);
assign c_rdata = c_rdata1 >> (8*c_addr[1:0]);
always@(negedge c_rstb or posedge c_clk) begin
  if(~c_rstb) begin
    c_ready <= 1'b0;
    c_rdata1 <= 0;
    setb <= 1'b0;
    entry <= 31'h0;
  end
  else begin
    c_ready <= c_valid;
    if(c_valid) begin
      case(c_addr)
        'h00 : begin
          c_rdata1[30: 0] <= pc[30:0];
          c_rdata1[   31] <= idle    ;
          if(c_write) begin
            entry[30:0] <= c_wdata1[30: 0];
            setb        <= c_wdata1[   31];
          end
        end
        'h04 : begin c_rdata1 <= ra ; if(c_write && !main) ra_next <= c_wdata1; end
        'h08 : begin c_rdata1 <= sp ; if(c_write && !main) sp_next <= c_wdata1; end
        'h10 : begin c_rdata1 <= gp ; if(c_write && !main) gp_next <= c_wdata1; end
        'h14 : begin c_rdata1 <= tp ; if(c_write && !main) tp_next <= c_wdata1; end
        'h18 : begin c_rdata1 <= t0 ; if(c_write && !main) t0_next <= c_wdata1; end
        'h1c : begin c_rdata1 <= t1 ; if(c_write && !main) t1_next <= c_wdata1; end
        'h20 : begin c_rdata1 <= t2 ; if(c_write && !main) t2_next <= c_wdata1; end
        'h24 : begin c_rdata1 <= s0 ; if(c_write && !main) s0_next <= c_wdata1; end
        'h28 : begin c_rdata1 <= s1 ; if(c_write && !main) s1_next <= c_wdata1; end
        'h2c : begin c_rdata1 <= a0 ; if(c_write && !main) a0_next <= c_wdata1; end
        'h30 : begin c_rdata1 <= a1 ; if(c_write && !main) a1_next <= c_wdata1; end
        'h34 : begin c_rdata1 <= a2 ; if(c_write && !main) a2_next <= c_wdata1; end
        'h38 : begin c_rdata1 <= a3 ; if(c_write && !main) a3_next <= c_wdata1; end
        'h3c : begin c_rdata1 <= a4 ; if(c_write && !main) a4_next <= c_wdata1; end
        'h40 : begin c_rdata1 <= a5 ; if(c_write && !main) a5_next <= c_wdata1; end
      endcase
    end
  end
end

`ifdef SIM
always@(posedge hwsetb) $write("%0t: %m.hwsetb posedge\n",$time);
always@(negedge hwsetb) $write("%0t: %m.hwsetb negedge\n",$time);
always@(posedge ret) $write("%0t: %m.ret posedge\n",$time);
always@(negedge ret) $write("%0t: %m.ret negedge\n",$time);
`endif

endmodule
