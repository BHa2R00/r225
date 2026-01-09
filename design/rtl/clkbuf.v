module clkbuf (
  input clk, 
  output lck 
);
`ifdef SAED32
NBUFFX2_RVT u_clk_lck_dont_touch (.A(clk),.Y(lck));
`else
wire clk_inv;
clkinv u_clk_inv (.clk(clk),.lck(clk_inv));
clkinv u_lck (.clk(clk_inv),.lck(lck));
`endif
endmodule
