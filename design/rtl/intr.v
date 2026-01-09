`timescale 1ns/1ps
`ifndef CK2Q
`define CK2Q #1
`endif

/*
 * src_clk |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |   |
 * clr_clk |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
 *                  _______________             ___     _______________
 * src     ________|               |___________|   |___|               |____
 *                            _   ___     _________         ________________
 * clr     __________________| |_|   |___|         |_______|              
 *                          ___                         _____
 * irq     ________________|   |_______________________|     |______________
 */

module intr #(parameter INIT=1'b0)(output irq, input src, clr, src_rstb, src_clk, clr_rstb, clr_clk);

/*reg [1:0] src_d, clr_d;
reg q,r;
wire flip = &{~irq,src_d[1]};
wire flop = &{ irq,clr_d[1]};
always@(negedge src_rstb or posedge src_clk) begin
  if(~src_rstb) begin
    src_d <= 2'b11;
    q <= INIT;
  end
  else begin
    src_d <= {src_d[0],src};
    if(flip) q <= ~q;
  end
end
always@(negedge clr_rstb or posedge clr_clk) begin
  if(~clr_rstb) begin
    clr_d <= 2'b11;
    r <= 1'b0;
  end
  else begin
    clr_d <= {clr_d[0],clr};
    if(flop) r <= ~r;
  end
end
assign irq = ^{q,r};*/

/*reg q;
assign irq = q;
wire clk = q ? clr : src;
wire rstb = src_rstb || clr_rstb;
always@(negedge rstb or posedge clk) begin
  if(~rstb) q <= INIT;
  else q <= ~q;
end*/

/*reg p,q;
always@(negedge src_rstb or posedge src) if(~src_rstb) p <= 1'b0; else p <= ~p;
always@(negedge clr_rstb or posedge clr) if(~clr_rstb) q <= INIT; else q <= ~q;
assign irq = ^{p,q};*/

reg q;
wire rstb = src_rstb || clr_rstb;
wire nst_set = INIT ? clr : src;
wire nst_rst = ~rstb || (INIT ? src : clr);
//`ifdef SAED32
//DFFARX1_RVT u_ff_dont_touch (.D(!INIT),.CLK(nst_set),.RSTB(~nst_rst),.Q(q),.QN());
//`else
always@(posedge nst_rst or posedge nst_set) if(nst_rst) `CK2Q q <= INIT; else `CK2Q q <= (!INIT);
//`endif
assign irq = q;

endmodule
