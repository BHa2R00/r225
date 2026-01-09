module clkinv (
  output lck, 
  input clk 
);
assign lck = ~clk;
endmodule
/*
create_generated_clock \
  -source [get_pins *fill_generated_clock_comb_inv/clk -hierarchical] \
  -combinational -invert  \
  [get_pins *fill_generated_clock_comb_inv/lck -hierarchical]


 */
