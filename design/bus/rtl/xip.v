module xipif (
  output reg        mosie, 
  output reg        mosi, 
  output reg        misoe, 
  input             miso, 
  output            cs, 
  output            scl, 
  output reg        ready, 
  output reg [31:0] rdata, 
  input      [31:0] wdata, 
  input             write, 
  input      [31:0] addr, 
  input      [ 1:0] size, 
  input             valid, 
  input             rstb, clk 
);

wire [6:0] cycle;
wire [3:0] tap;
pulse #(
  .CYCLEMSB(6), 
  .INIT(1'b0), 
  .MSB(7) 
) u_scl (
  .haltena(1'b0), .halt(1'b0), .dummy(1'b0), 
  .cki(1'b0), .ie(1'b0), 
  .cs(cs), 
  .tap(tap), 
  .cycle(cycle), 
  .setb_p(), .setb_n(), .err(), 
  .cko(scl), .rise(), .fall(), 
  .td(8'd1), .tr(8'd1), .tf(8'd1), .pw(8'd1), .period(8'd4), 
  .v1(1'b0), .invcs(1'b1), 
  .cnt(), 
  .setb(&{valid,~ready,rstb}), 
  .rstb(rstb), .clk(clk) 
);

wire [3:0] launchmask  = 4'b0111;
wire [3:0] capturemask = 4'b1000;
wire [3:0] oemask      = 4'b0110;
wire [3:0] iemask      = 4'b1001;
wire [3:0] readymask   = 4'b0001;
wire bytemode = 1'b1;
wire [15:0] cmd = 16'h03;
wire  [6:0] cmdmsb = 'd7;
wire  [6:0] addrwd = 'd24;
wire  [6:0] dummywd = 'd0;
wire launch  = |(tap & launchmask);
wire capture = |(tap & capturemask);
wire selcmd   = valid && (cycle < (cmdmsb + 'd1));
wire seladdr  = valid && (cycle < (cmdmsb + 'd1 + addrwd)) && (~selcmd);
wire seldummy = valid && (cycle < (cmdmsb + 'd1 + addrwd + dummywd)) && (~selcmd) && (~seladdr);
wire seldata  = valid && (cycle[6:5]!=2'b11) && (~selcmd) && (~seladdr) && (~seldummy);
wire [3:0] selbitcmd  = cmdmsb[3:0] - cycle[3:0];
wire [4:0] selbitaddr = 5'd31 - cycle[4:0];
wire [4:0] selbitdata = 5'd31 -(cycle[4:0] - dummywd[4:0]);
wire [1:0] selbitbyte =(2'b11 - selbitdata[4:3]);
wire [4:0] bth = bytemode ? {selbitbyte,selbitdata[2:0]} : selbitdata;
always@(*) begin
  //mosi = miso;
  mosi = 1'b1;
  //if(launch) begin
    case(1)
      selcmd  : mosi = cmd[selbitcmd];
      seladdr : mosi = addr[selbitaddr];
    endcase
  //end
end
always@(negedge rstb or posedge clk) begin
  if(~rstb) rdata <= 32'd0;
  else if(capture) begin
    if(seldata) rdata[bth] <= miso;
  end
end
always@(*) begin
  misoe = |(tap & oemask);
  mosie = |(tap & iemask);
end
always@(negedge rstb or posedge clk) begin
  if(~rstb) begin
    ready <= 1'b0;
  end
  else begin
    ready <= (|(tap & readymask)) && seldata && (selbitdata[4:0] == 5'd0);
  end
end

endmodule




module xip (
  output        mosie, 
  output        mosi, 
  output        misoe, 
  input         miso, 
  output        cs, 
  output        scl, 
  output        ready, 
  output [31:0] rdata, 
  input  [31:0] wdata, 
  input         write, 
  input  [31:0] addr, 
  input  [ 1:0] size, 
  input         valid, 
  input         rstb, clk 
);

wire        mem_valid;
wire        mem_ready;
wire [31:0] mem_addr;
wire [ 1:0] mem_size;
wire [31:0] mem_rdata;
wire [31:0] mem_wdata = 32'd0;
wire        mem_write = 1'b0;

xipif u_mem (
  mosie, 
  mosi, 
  misoe, 
  miso, 
  cs, 
  scl, 
  mem_ready, 
  mem_rdata, 
  mem_wdata, 
  mem_write, 
  mem_addr, 
  mem_size, 
  mem_valid, 
  rstb, clk 
);

cache u_cache (
  valid,      
  ready,      
  addr,       
  size,       
  rdata,      

  mem_valid,      
  mem_ready,      
  mem_addr,       
  mem_size,       
  mem_rdata,      

  clk,         
  rstb         
);

endmodule
