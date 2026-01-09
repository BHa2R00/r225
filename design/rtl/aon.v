module aon
(
  output     [47:0] rtc, 
  input             clk_32768, 
  output reg        pd_sys, 
  output reg        pd_io, 
  input             rstb, clk 
);

wire [47:0] rtc_b;
genvar k;
generate
tflip u_rtc (.q(rtc[0]), .qb(rtc_b[0]), .rstb(rstb), .clk(clk_32768));
for(k=1;k<=47;k=k+1) begin : rtc_bit
tflip u_rtc_next (.q(rtc[k]), .qb(rtc_b[k]), .rstb(rstb), .clk(rtc_b[k-1]));
end
endgenerate

always@(negedge rstb or posedge clk) begin
  if(~rstb) begin
    pd_sys <= 1'b0;
    pd_io <= 1'b0;
  end
  else begin
    pd_sys <= 1'b0;
    pd_io <= 1'b0;
  end
end

endmodule
