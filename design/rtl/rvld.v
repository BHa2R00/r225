module rvld (output vld, input rstb, clk, scan_mode);

reg q;
always@(negedge rstb or posedge clk) begin
  if(~rstb) q <= 1'b0;
  else q <= 1'b1;
end
//assign vld = scan_mode ? rstb : q;
clkmux u_vld (.lck(vld), .sel(scan_mode), .clk1(rstb), .clk(q));
//assign vld = q;

endmodule
