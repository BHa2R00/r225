module clkdiv #(
  parameter MSB = 7 
)(
  output             vld, 
  output             lck, 
  output reg [MSB:0] cnt, 
  input      [MSB:0] dvsr, dven, shr, 
  input              setb, ini, 
  input              rstb, clk, scan_mode 
);

reg lck0;
reg [1:0] setb_d;
assign vld = scan_mode ? rstb : &setb_d;
//clkmux u_vld (.lck(vld), .sel(scan_mode), .clk1(rstb), .clk(&setb_d));
always@(negedge rstb or posedge clk) begin
  if(~rstb) begin
    setb_d <= 2'b00;
    cnt <= {(MSB+1){1'b0}};
    lck0 <= 1'b0;
  end
  else begin
    setb_d <= {setb_d[0],setb};
    if(vld && (dven > dvsr)) begin
      if(cnt >= dven) begin
        cnt <= cnt - dven + dvsr;
        lck0 <= ini;
      end
      else begin
        cnt <= cnt + dvsr;
        if(cnt >= (dven >> 1)) lck0 <= ~ini;
      end
    end
    else begin
      lck0 <= ini;
      cnt <= (dven >> shr);
    end
  end
end
assign lck = scan_mode ? clk : lck0;
//clkmux u_lck (.lck(lck), .sel(scan_mode), .clk1(clk), .clk(lck0));

endmodule
