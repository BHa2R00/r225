module clksw #(
  parameter INIT = 1'b0 
)(
  output reg [1:0] vld, 
  output lck, 
  input sel, 
  input [1:0] rstb, clk 
);

reg [1:0] d;
always@(negedge rstb[0] or posedge clk[0]) begin
  if(~rstb[0]) begin
    d[0] <= ~INIT;
    vld[0] <= ~INIT;
  end
  else begin
    d[0] <= &{~vld[1],~sel};
    vld[0] <= d[0];
  end
end
always@(negedge rstb[1] or posedge clk[1]) begin
  if(~rstb[1]) begin
    d[1] <= INIT;
    vld[1] <= INIT;
  end
  else begin
    d[1] <= &{~vld[0],sel};
    vld[1] <= d[1];
  end
end
assign lck = |(vld&clk);

endmodule
