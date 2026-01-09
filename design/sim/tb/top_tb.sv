`timescale 1ns/1ps

`ifdef SIM
module top_tb1;

//wire [15:0]  PAD;
wire PAD_15, PAD_14, PAD_13, PAD_12, PAD_11, PAD_10, PAD_9, PAD_8, PAD_7, PAD_6, PAD_5, PAD_4, PAD_3, PAD_2, PAD_1, PAD_0;
 reg        BOOT;
 reg        TEST;
 reg        RSTB, CLK;
wire        RSTB_w, CLK_w;
assign {RSTB_w, CLK_w} = {RSTB, CLK};
top u_top (
  .BOOT(BOOT),
  .TEST(TEST),
  .PAD({PAD_15, PAD_14, PAD_13, PAD_12, PAD_11, PAD_10, PAD_9, PAD_8, PAD_7, PAD_6, PAD_5, PAD_4, PAD_3, PAD_2, PAD_1, PAD_0}),
  .RSTB(RSTB_w), .CLK(CLK_w) 
);

initial CLK = 0;
always #10 CLK = ~CLK;

reg uclk;
initial uclk=0;
always #250 uclk = ~uclk;
//reg tx;
//always@(posedge uclk) tx <= $urandom_range(0,1);
//assign PAD_4 = tx;
wire tty_tx_tx;
reg clk_2m;
reg tty_tx_enable;
initial clk_2m = 0;
always #250 clk_2m = ~clk_2m;
tty_tx
#(
  .memhfile ("./flash.memh")
)
u_tty_tx
(
  .tx(tty_tx_tx),     // tx out 
  .stop(2'd1),   // 2 for 2 stop bits, 1 for 1 stop bit, 0 for 0 stop bits 
  .parity(2'd0), // 1 for odd, 2 for even, 0 for disable parity bit 
  .clk(clk_2m),    // baud clock input 
  .enable(tty_tx_enable)  // reset not, low for rest, high for enable  
);
assign PAD_4 = tty_tx_tx;
always@(negedge RSTB or posedge clk_2m) begin
  if(~RSTB) begin
    tty_tx_enable = 0;
    BOOT = 0;
  end
  else begin
    tty_tx_enable = 1;
    if($urandom_range(0,5) == 0) BOOT = ~BOOT;
  end
end

wire cpu0_ret = u_top.cpu0.ret;

W25Q128JVxIM u_flash (.CSn(PAD_8), .CLK(PAD_7), .DIO(PAD_10), .DO(PAD_9), .WPn(), .HOLDn() );
pullup u_pullup_PAD_8 (PAD_8 );
pullup u_pullup_PAD_7 (PAD_7 );
pullup u_pullup_PAD_10(PAD_10);
pullup u_pullup_PAD_9 (PAD_9 );


initial begin
  `ifdef FST
  $dumpfile("top_tb1.fst");
  $dumpvars(0,top_tb1);
  `endif
  `ifdef FSDB
  $fsdbDumpfile("top_tb1.fsdb");
  $fsdbDumpvars(0,top_tb1);
  `endif
  RSTB = 0;
  TEST = 0;
  repeat(2) begin
    repeat(3) @(posedge CLK); RSTB = 1;
    repeat(3) @(posedge CLK); @(posedge cpu0_ret);
    repeat(3) @(posedge CLK); RSTB = 0;
  end
  $finish;
end

endmodule
`endif
