module pulse #(
  parameter CYCLEMSB = 3, 
  parameter INIT = 1'b0, 
  parameter MSB = 7 
)(
  input haltena, halt, dummy, 
  input cki, ie, 
  output cs, 
  output [3:0] tap, 
  output reg [CYCLEMSB:0] cycle, 
  output setb_p, setb_n, err, 
  output reg cko, rise, fall, 
  input [MSB:0] td, tr, tf, pw, period, 
  input v1, invcs, 
  output reg [MSB:0] cnt, 
  input setb, 
  input rstb, clk 
);

wire cki_p = {cko,cki} == 2'b01;
wire cki_n = {cko,cki} == 2'b10;
wire cki_1 = {cko,cki} == 2'b11;
wire cki_0 = {cko,cki} == 2'b00;
wire v2 = ~v1;
wire [MSB:0] td_cnt = td - cnt;
wire [MSB:0] tr_cnt = (td + tr) - cnt;
wire [MSB:0] pw_cnt = (td + tr + pw) - cnt;
wire [MSB:0] tf_cnt = (td + tr + pw + tf) - cnt;
wire [MSB:0] period_cnt = (td + period) - cnt;
wire [MSB:0] period_tf = period - (tr + pw + tf);
assign err = (~|tr) || (~|tf) || tr[MSB] || tf[MSB] || period_tf[MSB];
always@(negedge rstb or posedge clk) begin
  if(~rstb) cnt <= {(MSB+1){1'b0}};
  else if(setb && (~err) && (~ie)) begin
    if(~(halt&&haltena)) cnt <= (~|period_cnt) ? (td + {{MSB{1'b0}},1'b1}) : (cnt + {{MSB{1'b0}},1'b1});
  end
  else cnt <= {(MSB+1){1'b0}};
end
wire rise0 = ie ? cki_p : (td_cnt[MSB] && (~tr_cnt[MSB]));
wire fall0 = ie ? cki_n : (pw_cnt[MSB] && (~tf_cnt[MSB]));
always@(*) begin
  rise = 1'b0;
  fall = 1'b0;
  if(setb && (~err)) begin
    rise = v1 ? fall0 : rise0;
    fall = v1 ? rise0 : fall0;
  end
end
always@(negedge rstb or posedge clk) begin
  if(~rstb) cko <= INIT;
  else if(setb && (~err) && (~ie)) begin
    case(1)
      ((~|tr_cnt) && (cko == v1)) : cko <= v2;
      ((~|tf_cnt) && (cko == v2)) : cko <= v1;
    endcase
  end
  else if(ie) cko <= cki;
  else cko <= v1;
end
reg [1:0] setb_d;
always@(negedge rstb or posedge clk) begin
  if(~rstb) setb_d <= 2'b00;
  else setb_d <= {setb_d[0],setb};
end
assign setb_p = setb_d == 2'b01;
assign setb_n = setb_d == 2'b10;
always@(negedge rstb or posedge clk) begin
  if(~rstb) cycle <= {(CYCLEMSB+1){1'b0}};
  else if(setb) begin
    if((~|period_cnt) && (~dummy) && (~(halt&&haltena))) cycle <= (cycle + {{CYCLEMSB{1'b0}},1'b1});
  end
  else cycle <= {(CYCLEMSB+1){1'b0}};
end
assign tap[0] = setb && ({cko,rise,fall} == 3'b000);
assign tap[1] = setb && ({cko,rise,fall} == 3'b010);
assign tap[2] = setb && ({cko,rise,fall} == 3'b100);
assign tap[3] = setb && ({cko,rise,fall} == 3'b101);
assign cs = invcs ? ~setb : setb;

endmodule
