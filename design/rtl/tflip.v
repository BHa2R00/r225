module tflip
(
  output q, qb, 
  input rstb, clk 
);

reg r;
always@(negedge rstb or posedge clk) begin
  if(~rstb) r <= 1'b0;
  else r <= ~r;
end

assign q = r;
assign qb = ~r;

endmodule
