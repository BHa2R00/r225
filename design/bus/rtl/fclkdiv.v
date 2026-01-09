`timescale 1ns/1ps

module fclkdiv (
  output             frstb, 
  output             fclk, 
  input              rstb, clk, scan_mode,
  // configure 
  output reg        c_ready, 
  output     [31:0] c_rdata, 
   input     [31:0] c_wdata, 
   input            c_write, 
   input     [31:0] c_addr, 
   input     [ 1:0] c_size, 
   input            c_valid, 
   input            c_rstb, c_clk
);
wire [31:0] cnt;
reg  [31:0] dvsr, dven, shr;
reg         setb, ini;
clkdiv #(
  .MSB (31) 
) u_generated_clock (
   .vld(frstb), 
   .lck(fclk), 
   .cnt(cnt), 
   .dvsr(dvsr), .dven(dven), .shr(shr), 
   .setb(setb), .ini(ini), 
   .rstb(rstb), .clk(clk), .scan_mode(scan_mode) 
);
reg  [31:0] c_rdata1;
wire [31:0] c_wdata1 = c_wdata << (8*c_addr[1:0]);
assign c_rdata = c_rdata1 >> (8*c_addr[1:0]);
always@(negedge c_rstb or posedge c_clk) begin
  if(~c_rstb) begin
    c_ready <= 1'b0;
    c_rdata1 <= 0;
    setb <= 1'b0;
    ini <= 1'b0;
    shr <= 0;
    dven <= 0;
    dvsr <= 0;
  end
  else begin
    c_ready <= c_valid;
    if(&{c_valid}) begin
      case(c_addr&~32'h3)
        'h0 : begin
          c_rdata1[0] <= frstb;
          c_rdata1[1] <= ini;
          c_rdata1[7:2] <= shr[5:0];
          if(c_write) begin
            setb <= c_wdata1[0];
            ini <= c_wdata1[1];
            shr <= {{32-6{1'b0}},c_wdata1[7:2]};
          end
        end
        'h4 : begin
          c_rdata1 <= dven;
          if(c_write) dven <= c_wdata1;
        end
        'h8 : begin
          c_rdata1 <= dvsr;
          if(c_write) dvsr <= c_wdata1;
        end
        'hc : begin
          c_rdata1 <= cnt;
        end
      endcase
    end
  end
end
`ifdef SIM
initial begin
$monitor("%t: %m.setb=%b,dven=%x,dvsr=%x", $time,setb, dven, dvsr);
end
`endif
endmodule
