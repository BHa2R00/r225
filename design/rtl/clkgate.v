module clkgate (input clk, en, output lck, input scan_mode);
`ifdef SMIC55
GCKESFB8LEHMX1 u_clkgate (.TE(scan_mode),.E(en),.CK(clk),.Q(lck));
`elsif SAED32
CGLNPRX2_RVT u_clkgate (.SE(scan_mode),.EN(en),.CLK(clk),.GCLK(lck));
`elsif ALTERA
assign lck = scan_mode ? clk : en ? clk : 1'b0;
`else
reg latch;
always@(*) if(~clk) latch <= en;
assign lck = scan_mode ? clk : &{latch,clk};
`endif
endmodule
