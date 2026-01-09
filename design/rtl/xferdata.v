module xferdata (rx,rmsb,re,empty,rstb,clk,cnt,full,tx,tmsb,te);
parameter RMSB = 7;
parameter TMSB = 31;
parameter AMSB = 6;
parameter SCANABLE = 0;
parameter INIT = 1'b1;
localparam RWD = RMSB+1;
localparam TWD = TMSB+1;
localparam AWD = AMSB+1;
localparam MWD = (1<<AWD);
localparam MMSB = MWD-1;
input [RMSB:0] rx;
input [AMSB:0] rmsb;
output [TMSB:0] tx;
input [AMSB:0] tmsb;
input re, rstb, clk, te;
output reg signed [AWD:0] cnt;
output empty, full;
wire [AWD:0] rwd = rmsb+1;
wire [AWD:0] twd = tmsb+1;
wire signed [AWD:0] cnt_next = 
  cnt + 
  (re ? rwd : {(AWD+1){1'b0}}) - 
  (te ? twd : {(AWD+1){1'b0}});
always@(negedge rstb or posedge clk) begin
  if(~rstb) cnt <= {(AWD+1){1'b0}};
  else if(|{re,te}) cnt <= cnt_next;
end
wire [MMSB:0] mem_sl;
wire [MMSB:0] mem_sr;
wire [MMSB:0] rx_masked = {{(MWD-RWD){1'b0}},rx} & ((1<<rwd)-1);
wire [MMSB:0] mem_next = mem_sl | rx_masked;
generate
if(SCANABLE) begin : scannable
reg [MMSB:0] mem;
assign mem_sl = mem<<rwd;
always@(negedge rstb or posedge clk) begin
  if(~rstb) mem <= {MWD{INIT}};
  else if(re) mem <= mem_next;
end
assign mem_sr = mem>>(cnt-twd-rwd);
end
else begin : unscannable
reg [MMSB:0] mem_dont_scan;
assign mem_sl = mem_dont_scan<<rwd;
always@(posedge clk) begin
  if(re) mem_dont_scan <= mem_next;
end
assign mem_sr = mem_dont_scan>>(cnt-twd-rwd);
end
endgenerate
assign empty = 0>=cnt;
assign full = cnt>=MMSB;
assign tx = mem_sr[TMSB:0];
endmodule
