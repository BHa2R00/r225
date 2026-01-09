module sram1k (
  output reg        ready, 
  output     [31:0] rdata, 
   input     [31:0] wdata, 
   input            write, 
   input     [31:0] addr, 
   input     [ 1:0] size, 
   input            valid, 
   input            rstb, clk
);

`ifdef SMIC55
  wire     [31:0]     DO;                 
  wire     [31:0]     DI = wdata << (8*addr[1:0]);                 
  wire     [31:0]    A = ((addr>>2)&((1<<8)-1));                  
  wire     DVSE = 1'd0;                                    
  wire     [2:0]         DVS = 3'd0;                
  wire     [3:0]          WEB = ~({4{write}} & ((size==2 ? 4'b1111 : size==1 ? 4'b0011 : 4'b0001) << addr[1:0]));                
  wire     CK = clk;                                      
  wire     CSB = valid;                                     
  wire     SLP = 1'd0;                                     
  wire     RET = 1'd0;            
 r1p_256x8x4 u_sram (.A(A[7:0]),.DO(DO),.DI(DI),.DVSE(DVSE),.DVS(DVS),.WEB(WEB),.CK(CK),.CSB(CSB),.SLP(SLP),.RET(RET));
assign rdata = DO >> (8*addr[1:0]);
`elsif SAED32
wire [31:0] A = ((addr>>2)&((1<<8)-1));
wire CE = valid;
wire [3:0] WEB = ~({4{write}} & ((size==2 ? 4'b1111 : size==1 ? 4'b0011 : 4'b0001) << addr[1:0]));
wire OEB = 1'b1;
wire CSB = valid;
wire [31:0] I = wdata << (8*addr[1:0]);
wire [31:0] O;
SRAM1RW256x8 u_sram_b0 (.A(A[7:0]),.CE(CE),.WEB(WEB[0]),.OEB(OEB),.CSB(CSB),.I(I[ 7: 0]),.O(O[ 7: 0]));
SRAM1RW256x8 u_sram_b1 (.A(A[7:0]),.CE(CE),.WEB(WEB[1]),.OEB(OEB),.CSB(CSB),.I(I[15: 8]),.O(O[15: 8]));
SRAM1RW256x8 u_sram_b2 (.A(A[7:0]),.CE(CE),.WEB(WEB[2]),.OEB(OEB),.CSB(CSB),.I(I[23:16]),.O(O[23:16]));
SRAM1RW256x8 u_sram_b3 (.A(A[7:0]),.CE(CE),.WEB(WEB[3]),.OEB(OEB),.CSB(CSB),.I(I[31:24]),.O(O[31:24]));
assign rdata = O >> (8*addr[1:0]);
`elsif ALTERA
wire [3:0] be = (size==2 ? 4'b1111 : size==1 ? 4'b0011 : 4'b0001) << addr[1:0];
wire [31:0] q;
wire [31:0] wdata1 = wdata << (8*addr[1:0]);
altsyncram	altsyncram_component (
			.address_a ((addr>>2)&((1<<8)-1)),
			.clock0 (clk),
			.q_a (q),
			.aclr0 (1'b0),
			.addressstall_a (1'b0),
      .byteena_a (be),
			.clocken0 (1'b1),
			.data_a (wdata1),
			.rden_a (valid),
			.wren_a (valid && write)
      );
defparam
  altsyncram_component.byte_size = 8,
  altsyncram_component.width_byteena_a = 4,
  altsyncram_component.address_aclr_a = "NONE",
  altsyncram_component.clock_enable_input_a = "BYPASS",
  altsyncram_component.clock_enable_output_a = "BYPASS",
	altsyncram_component.intended_device_family = "Cyclone IV E",
	altsyncram_component.lpm_type = "altsyncram",
	altsyncram_component.numwords_a = 256,
	altsyncram_component.operation_mode = "SINGLE_PORT",
  altsyncram_component.outdata_aclr_a = "NONE",
	altsyncram_component.outdata_reg_a = "UNREGISTERED",
	//altsyncram_component.outdata_reg_a = "CLOCK0",
	altsyncram_component.widthad_a = 8,
	altsyncram_component.width_a = 32;
assign rdata = q >> (8*addr[1:0]);
`else
(* ram_style="block" *) reg [31:0] mem[0:(1<<8)-1];
wire [3:0] be = (size==2 ? 4'b1111 : size==1 ? 4'b0011 : 4'b0001) << addr[1:0];
wire [31:0] wdata1 = wdata << (8*addr[1:0]);
always@(posedge clk) begin
  if(valid) begin
    if(write) begin
      if(be[0]) mem[(addr>>2)&((1<<8)-1)][ 7: 0] <= wdata1[ 7: 0];
      if(be[1]) mem[(addr>>2)&((1<<8)-1)][15: 8] <= wdata1[15: 8];
      if(be[2]) mem[(addr>>2)&((1<<8)-1)][23:16] <= wdata1[23:16];
      if(be[3]) mem[(addr>>2)&((1<<8)-1)][31:24] <= wdata1[31:24];
    end
  end
end
reg [31:0] q;
always@(negedge rstb or posedge clk) begin
  if(~rstb) begin
    q <= 0;
  end
  else if(&{valid}) begin
    q <= mem[(addr>>2)&((1<<8)-1)] >> (8*addr[1:0]);
  end
end
assign rdata = q;
//assign rdata = mem[(addr>>2)&((1<<8)-1)] >> (8*addr[1:0]);
`endif

always@(negedge rstb or posedge clk) begin
  if(~rstb) begin
    ready <= 1'b0;
  end
  else begin
    ready <= valid;
  end
end

endmodule
