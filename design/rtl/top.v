module top
(
  input         BOOT, 
  input         TEST, 
  inout [15:0]  PAD,
  input         RSTB, CLK 
);
wire rstb, clk, test, boot;
pad_i u_clk (CLK, clk, 1'b1, 1'b0, 1'b0);
pad_i u_rstb (RSTB, rstb, 1'b1, 1'b0, 1'b0);
pad_i u_test (TEST, test, 1'b1, 1'b0, 1'b0);
pad_i u_boot (BOOT, boot, 1'b1, 1'b0, 1'b0);

wire [47:0] rtc;
wire pd_sys;
wire pd_io;
aon
u_aon_dont_scan 
(
  .rtc(rtc),
  .clk_32768(clk),
  .pd_sys(), 
  .pd_io(), 
  .rstb(rstb), .clk(clk) 
);

`ifdef SCAN
wire scan_mode = test;
`else
wire scan_mode = 1'b0;
`endif

wire pll_clk;
wire pll_rstb;
pll u_pll_clk (scan_mode, pll_clk, rstb, clk);
rvld u_pll_rstb (pll_rstb, rstb, pll_clk, scan_mode);
wire fast_clk;
wire fast_rstb;
clkdiv 
#(
  .MSB(7) 
)
u_fast_clk
(
  .vld(fast_rstb), 
  .lck(fast_clk), 
  .cnt(), 
  .dvsr(8'd1), .dven(8'd2), .shr(8'd0), 
  .setb(1'b1), .ini(1'b0), 
  .rstb(pll_rstb), .clk(pll_clk), .scan_mode(scan_mode) 
  //.rstb(rstb), .clk(clk), .scan_mode(scan_mode) 
);
//rvld u_fast_rstb (fast_rstb, rstb, fast_clk, scan_mode);
wire main_clk;
wire main_rstb;
clkdiv 
#(
  .MSB(7) 
)
u_main_clk
(
  .vld(main_rstb), 
  .lck(main_clk), 
  .cnt(), 
  .dvsr(8'd1), .dven(8'd2), .shr(8'd0), 
  .setb(1'b1), .ini(1'b0), 
  .rstb(fast_rstb), .clk(fast_clk), .scan_mode(scan_mode) 
);
//rvld u_main_rstb (main_rstb, rstb, main_clk, scan_mode);
`include "interconnect.vh"
assign cpu0_hwsetb = 1'b1;
assign cpu1_hwsetb = 1'b0;
assign irq0_in[0] = hwtimer0_irq;
//assign irq0_in[1] = hwtimer1_irq;
//assign irq0_in[2] = hwtimer2_irq;
//assign irq0_in[3] = hwtimer3_irq;
assign irq0_in[4] = uart_tx0_irq;
assign irq0_in[5] = uart_rx0_irq;
assign cpu0_wakeup = irq0_out;
assign uart_tx0_frstb = rstb;
assign uart_tx0_fclk = clk;
assign uart_rx0_frstb = rstb;
assign uart_rx0_fclk = clk;
assign fclkdiv0_rstb = fast_rstb;
assign fclkdiv0_clk = fast_clk;
assign fclkdiv0_scan_mode = scan_mode;
//assign fclkdiv1_rstb = fclkdiv0_frstb;
//assign fclkdiv1_clk = fclkdiv0_fclk;
//assign fclkdiv1_scan_mode = scan_mode;
//assign fclkdiv2_rstb = fclkdiv1_frstb;
//assign fclkdiv2_clk = fclkdiv1_fclk;
//assign fclkdiv2_scan_mode = scan_mode;
//assign fclkdiv3_rstb = fclkdiv2_frstb;
//assign fclkdiv3_clk = fclkdiv2_fclk;
//assign fclkdiv3_scan_mode = scan_mode;
//assign hwtimer0_fclk = fclkdiv0_fclk;
//assign hwtimer0_frstb = fclkdiv0_frstb;
//assign hwtimer1_fclk = fclkdiv1_fclk;
//assign hwtimer1_frstb = fclkdiv1_frstb;
//assign hwtimer2_fclk = fclkdiv2_fclk;
//assign hwtimer2_frstb = fclkdiv2_frstb;
//assign hwtimer3_fclk = fclkdiv3_fclk;
//assign hwtimer3_frstb = fclkdiv3_frstb;
assign cgu0_rtc = rtc[47:16];
//assign cgu0_fclk = {fclkdiv3_fclk,fclkdiv2_fclk,fclkdiv1_fclk,fclkdiv0_fclk};
assign cgu0_fclk = {3'b000,fclkdiv0_fclk};
assign cgu0_scan_mode = scan_mode;
assign hwtimer0_fclk = cgu0_lck[0];
assign hwtimer0_frstb = cgu0_lrb[0];
//assign hwtimer1_fclk = cgu0_lck[1];
//assign hwtimer1_frstb = cgu0_lrb[1];
//assign hwtimer2_fclk = cgu0_lck[2];
//assign hwtimer2_frstb = cgu0_lrb[2];
//assign hwtimer3_fclk = cgu0_lck[3];
//assign hwtimer3_frstb = cgu0_lrb[3];
assign mul0_scan_mode = scan_mode;
assign mul0_fclk = fast_clk;
assign mul1_scan_mode = scan_mode;
assign mul1_fclk = fast_clk;
assign mul2_scan_mode = scan_mode;
assign mul2_fclk = fast_clk;
assign mul3_scan_mode = scan_mode;
assign mul3_fclk = fast_clk;
assign div0_scan_mode = scan_mode;
assign div0_fclk = fast_clk;
assign div1_scan_mode = scan_mode;
assign div1_fclk = fast_clk;
assign div2_scan_mode = scan_mode;
assign div2_fclk = fast_clk;
assign div3_scan_mode = scan_mode;
assign div3_fclk = fast_clk;
assign crc0_ack = 1'b0;
wire [15:0] dc, di, ie, oe, pu, pd, sie, soe, si, so;
genvar pad_k;
generate 
for(pad_k=0;pad_k<=15;pad_k=pad_k+1) begin : pad
pad_io u_PAD (
  .pad(PAD[pad_k]), 
  .dc(dc[pad_k]), .di(di[pad_k]), 
  .ie(ie[pad_k]), .oe(oe[pad_k]), 
  .pu(pu[pad_k]), .pd(pd[pad_k]), 
  .sie(sie[pad_k]), .soe(soe[pad_k]), 
  .si(si[pad_k]), .so(so[pad_k]) 
  );
if(pad_k>6) begin : pad_binding
assign ie[pad_k] = 1'b0;
assign oe[pad_k] = 1'b0;
assign pu[pad_k] = 1'b1;
assign pd[pad_k] = 1'b0;
assign di[pad_k] = debug0_out1[pad_k];
assign sie[pad_k] = 1'b0;
assign soe[pad_k] = 1'b0;
assign si[pad_k] = 1'b0;
assign debug0_in0[pad_k] = dc[pad_k];
assign debug0_in1[pad_k] = dc[pad_k];
end
end
endgenerate 
assign debug0_boot = boot;
assign di[0] = uart_tx0_tx;
assign ie[0] = 1'b0;
assign oe[0] = 1'b1;
assign pu[0] = 1'b0;
assign pd[0] = 1'b0;
assign sie[0] = 1'b0;
assign soe[0] = scan_mode;
assign di[1] = uart_tx0_cs;
assign ie[1] = 1'b0;
assign oe[1] = 1'b1;
assign pu[1] = 1'b0;
assign pd[1] = 1'b0;
assign sie[1] = scan_mode;
assign soe[1] = 1'b0;
assign di[2] = uart_tx0_cl;
assign ie[2] = 1'b0;
assign oe[2] = 1'b1;
assign pu[2] = 1'b0;
assign pd[2] = 1'b0;
assign sie[2] = 1'b0;
assign soe[2] = scan_mode;
assign di[3] = uart_tx0_tx;
assign ie[3] = 1'b0;
assign oe[3] = 1'b1;
assign pu[3] = 1'b0;
assign pd[3] = 1'b0;
assign sie[3] = 1'b0;
assign soe[3] = scan_mode;
assign di[4] = 1'b0;
assign uart_rx0_rx = dc[4];
assign ie[4] = 1'b1;
assign oe[4] = 1'b0;
assign pu[4] = 1'b0;
assign pd[4] = 1'b0;
assign sie[4] = 1'b0;
assign soe[4] = scan_mode;
assign di[5] = uart_rx0_cs;
assign ie[5] = 1'b0;
assign oe[5] = 1'b1;
assign pu[5] = 1'b0;
assign pd[5] = 1'b0;
assign sie[5] = 1'b0;
assign soe[5] = scan_mode;
assign di[6] = uart_rx0_cl;
assign ie[6] = 1'b0;
assign oe[6] = 1'b1;
assign pu[6] = 1'b0;
assign pd[6] = 1'b0;
assign sie[6] = 1'b0;
assign soe[6] = scan_mode;
/*assign di[7] = rom1_scl;
assign ie[7] = 1'b0;
assign oe[7] = 1'b1;
assign pu[7] = 1'b0;
assign pd[7] = 1'b0;
assign sie[7] = 1'b0;
assign soe[7] = scan_mode;
assign di[8] = rom1_cs;
assign ie[8] = 1'b0;
assign oe[8] = 1'b1;
assign pu[8] = 1'b0;
assign pd[8] = 1'b0;
assign sie[8] = 1'b0;
assign soe[8] = scan_mode;
assign di[9] = 1'b0;
assign rom1_miso = dc[9];
assign ie[9] = 1'b1;
assign oe[9] = 1'b0;
assign pu[9] = 1'b0;
assign pd[9] = 1'b0;
assign sie[9] = 1'b0;
assign soe[9] = scan_mode;
assign di[10] = rom1_mosi;
assign ie[10] = 1'b0;
assign oe[10] = 1'b1;
assign pu[10] = 1'b0;
assign pd[10] = 1'b0;
assign sie[10] = 1'b0;
assign soe[10] = scan_mode;*/







endmodule
