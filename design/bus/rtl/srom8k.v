module srom8k (
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
`include "rom_comb.vh"
assign A = (addr>>2)&((1<<11)-1);
assign rdata = Q >> (8*addr[1:0]);
`elsif SAED32
`include "rom_comb.vh"
assign A = (addr>>2)&((1<<11)-1);
assign rdata = Q >> (8*addr[1:0]);
`elsif ALTERA
wire [31:0] q;
altsyncram	altsyncram_component (
			.address_a ((addr>>2)&((1<<11)-1)),
			.clock0 (clk),
			.q_a (q),
			.aclr0 (1'b0),
			.addressstall_a (1'b0),
			.clocken0 (1'b1),
			.data_a (),
			.rden_a (1'b1),
			.wren_a (1'b0)
      );
defparam
  altsyncram_component.address_aclr_a = "NONE",
  altsyncram_component.clock_enable_input_a = "BYPASS",
  altsyncram_component.clock_enable_output_a = "BYPASS",
  altsyncram_component.init_file = "rom.mif",
	altsyncram_component.intended_device_family = "Cyclone IV E",
	altsyncram_component.lpm_type = "altsyncram",
	altsyncram_component.numwords_a = 2048,
	altsyncram_component.operation_mode = "ROM",
  altsyncram_component.outdata_aclr_a = "NONE",
	altsyncram_component.outdata_reg_a = "UNREGISTERED",
	altsyncram_component.widthad_a = 11,
	altsyncram_component.width_a = 32;
/*lpm_rom rom (
		.address		((addr>>2)&((1<<11)-1)),
		.inclock		(clk),
		.q				(q)
	);
	defparam rom.lpm_width = 32;
	defparam rom.lpm_widthad = 11;
	defparam rom.lpm_outdata = "UNREGISTERED";
	defparam rom.lpm_file = "rom.mif";*/
assign rdata = q >> (8*addr[1:0]);
/*`elsif XILINX
`include "rom_comb.vh"
assign A = (addr>>2)&((1<<11)-1);
assign rdata = Q >> (8*addr[1:0]);*/
`else
(* ram_style="block" *) reg [31:0] mem[0:(1<<11)-1];
initial begin
  $readmemh("rom.memh",mem);
end
reg [31:0] q;

always@(negedge rstb or posedge clk) begin
  if(~rstb) begin
    q <= 0;
  end
  else begin
    if(&{valid}) q <= mem[(addr>>2)&((1<<11)-1)] >> (8*addr[1:0]);
  end
end
assign rdata = q;
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
