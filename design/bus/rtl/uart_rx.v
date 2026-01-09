`timescale 1ns/1ps


module uart_rx
(
  output            irq, 
   input            rx, 
  output            cl, cs,
   input            frstb, fclk,
  output reg        ready, 
  output     [31:0] rdata, 
   input     [31:0] wdata, 
   input            write, 
   input     [31:0] addr, 
   input     [ 1:0] size, 
   input            valid, 
   input            rstb, clk
);

reg setb;
wire busy;
reg trans;
reg signed [ 5:0] sb;
reg [31:0] data;
reg [31:0] data_b;
reg [ 5:0] width;
wire [ 5:0] msb = width - 1;
reg check;
reg [4:0] crc_width;
reg [15:0] crc_ini;
wire [15:0] crc_sum;
reg [15:0] crc_tap;
wire [4:0] crc_msb = crc_width - 1'd1;
wire idle = ~((sb >= 6'd0) && (sb <= (msb + {1'd0,crc_width})));
intr #(.INIT(1'b0)) 
u_busy_dont_scan (
  .irq(busy), .src(~rx), .clr(&{valid,((addr&~32'h3)=='h0),~write}), 
  .src_rstb(frstb), .clr_rstb(frstb) 
  );

wire vld;
reg [31:0] dvsr, dven;
clkdiv 
#(
  .MSB(31) 
)
u_cl 
(
  .vld(vld), 
  .lck(cl), 
  .cnt(), 
  .dvsr(dvsr), .dven(dven), .shr(32'd0), 
  .setb(busy), .ini(1'b0), 
  .rstb(frstb), .clk(fclk), .scan_mode(1'b0) 
);
assign cs = ~vld;

always@(negedge vld or negedge cl) begin
  if(~vld) begin
    sb <= 6'd0;
    trans <= 1'b0;
    check <= 1'b0;
  end
  else if(~idle) begin
    trans <= 1'b1;
    sb <= sb + 6'd1;
    if(~(check && |crc_width)) data_b <= {rx,data_b[31:1]};
    if(sb==msb && |crc_width) check <= 1'b1;
  end
end
mcrc 
#(
  .MAX_WIDTH (16) 
  //.AMSB (5) 
) 
u_crc 
(
  .ini(crc_ini), 
  .sum(crc_sum), 
  .x(rx), 
  .tap(crc_tap), 
  .msb(crc_msb), 
  .setb(trans), .halt(check), 
  .rstb(vld), .clk(cl) 
);

reg  irq_enable_idle;
wire irq_status_idle;
reg  irq_clear_idle;
reg  irq_unmask_idle;

intr #(.INIT(1'b0)) 
u_irq_status_idle_dont_scan (
  .irq(irq_status_idle), .src(&{irq_enable_idle,idle,|width}), .clr(irq_clear_idle), 
  .src_rstb(rstb), .clr_rstb(rstb) 
  );

assign irq =
  (irq_unmask_idle && irq_status_idle) || 
  1'b0;

reg  [31:0] rdata1;
wire [31:0] wdata1 = wdata << (8*addr[1:0]);
assign rdata = rdata1 >> (8*addr[1:0]);
always@(negedge rstb or posedge clk) begin
  if(~rstb) begin
    setb <= 1'b0;
    ready <= 1'b0;
    dven <= 32'd24;
    dvsr <= 32'd2;
    irq_enable_idle <= 1'b0;
    irq_clear_idle <= 1'b0;
    irq_unmask_idle <= 1'b0;
    width <= 6'd8;
    crc_width <= 5'd0;
    crc_tap <= 16'd0;
    crc_ini <= 16'b0;
  end
  else begin
    if(idle) data <= data_b >> (32-(msb+1));
    ready <= valid;
    rdata1 <= 32'h0;
    irq_clear_idle <= 1'b0;
    if(&{valid}) begin
      case(addr&~32'h3)
        'h00 : begin
          rdata1[31: 0] <= data;
        end
        'h04 : begin
          rdata1[31: 0] <= dven;
          if(write) begin
          dven <= wdata1[31: 0];
          end
        end
        'h08 : begin
          rdata1[31: 0] <= dvsr;
          if(write) begin
          dvsr <= wdata1[31: 0];
          end
        end
        'h0c : begin
          rdata1[ 5: 0] <= sb              ;
          rdata1[11: 6] <= width           ;
          rdata1[12]    <= idle            ;
          rdata1[13]    <= irq_enable_idle ;
          rdata1[14]    <= irq_status_idle ;
          rdata1[15]    <= irq_unmask_idle ;
          rdata1[20:16]    <= crc_width    ;
          if(write) begin
          width           <= wdata1[11: 6] ;
          irq_enable_idle <= wdata1[13]    ;
          irq_clear_idle  <= wdata1[14]    ;
          irq_unmask_idle <= wdata1[15]    ;
          crc_width       <= wdata1[20:16] ;
          end
        end
        'h10 : begin
          rdata1[15: 0]    <= crc_sum      ;
          rdata1[31:16]    <= crc_tap      ;
          if(write) begin
          crc_ini         <= wdata1[15: 0] ;
          crc_tap         <= wdata1[31:16] ;
          end
        end
      endcase
    end
  end
end
`ifdef SIM
always@(posedge &{valid,(addr=='h0),~write}) $write("%x\n",data);
`endif

endmodule
