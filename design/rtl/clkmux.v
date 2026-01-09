module clkmux (
  output lck,
  input sel, clk1, 
  input clk
);
assign lck = sel ? clk1 : clk;
endmodule
