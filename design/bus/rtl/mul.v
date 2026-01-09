`timescale 1ns/1ps

module mul 
(
  input  wire        scan_mode,
  input  wire        fclk,
  output reg         c_ready,
  output      [31:0] c_rdata,
  input  wire [31:0] c_wdata,
  input  wire        c_write,
  input  wire [31:0] c_addr,
  input       [ 1:0] c_size, 
  input  wire        c_valid,
  input  wire        c_rstb,
  input  wire        c_clk
);

wire frstb;
rvld u_frstb (frstb, c_rstb, fclk, scan_mode);

reg setb, uns;
reg [5:0] cnt;
reg [31:0] a, b;
reg [31:0] x;
wire [31:0] x_load = uns ? a : (a[31] ? (32'd0-a) : a);
reg [63:0] y;
wire [63:0] y_load = uns ? b : (b[31] ? (64'd0-b) : b);
reg [63:0] p;

always@(negedge frstb or posedge fclk) begin
  if(~frstb) begin
    //x <= $urandom_range(0,{32{1'b1}});
    //y <= $urandom_range(0,{64{1'b1}});
    cnt <= 6'd0;
  end
  else begin
    if(cnt==6'd0) begin
      if(setb) begin
        cnt <= 6'd33;
        x <= x_load;
        y <= y_load;
        p <= 64'd0;
      end                                  
    end
    else if(cnt>6'd1) begin
      cnt <= |x ? cnt - 6'd1 : 6'd1;
      if(x[0]) begin
        p <= p + y;
      end
      x <= x >> 1;
      y <= y << 1;
    end
    else if(cnt==6'd1) begin
      if(~setb) cnt <= 6'd0;
    end
  end
end

wire busy = cnt > 6'd1;
wire done = cnt == 6'd1;
wire [63:0] m = (~uns && (a[31] ^ b[31])) ? (64'd0-p) : p;

wire c_addr_a   = (c_addr&~32'h3) == 32'h00 ;
wire c_addr_b   = (c_addr&~32'h3) == 32'h04 ;
wire c_addr_p_l = (c_addr&~32'h3) == 32'h08 ;
wire c_addr_p_h = (c_addr&~32'h3) == 32'h0c ;
wire c_addr_ctl = (c_addr&~32'h3) == 32'h10 ;

reg  [31:0] c_rdata1;
wire [31:0] c_wdata1 = c_wdata << (8*c_addr[1:0]);
assign c_rdata = c_rdata1 >> (8*c_addr[1:0]);
always @(negedge c_rstb or posedge c_clk) begin
    if (!c_rstb) begin
      c_ready   <= 1'b0;
      c_rdata1 <= 32'h0;
      setb    <= 1'b0;
    end 
    else begin
      c_ready <= c_valid;
      c_rdata1 <= 32'h0;
      if(&{c_valid}) begin
        case(1'b1)
          c_addr_a : begin
            c_rdata1[31:0] <= a;
            if(c_write) begin
            a <= c_wdata1;
            end
          end
          c_addr_b : begin
            c_rdata1[31:0] <= b;
            if(c_write) begin
            b <= c_wdata1;
            end
          end
          c_addr_p_l: c_rdata1[31:0]  <= m[31:0];
          c_addr_p_h: c_rdata1[31:0]  <= m[31:0];
          c_addr_ctl: begin
            c_rdata1[0] <= busy;
            c_rdata1[1] <= uns;
            if (c_write) begin
            setb <= c_wdata1[0];
            uns  <= c_wdata1[1];
            end
          end
        endcase
      end
    end
end

`ifdef SIM
always @(posedge setb) $display("%0t: %m start a=%0d b=%0d uns=%0b", $time, (uns ? a : $signed(a)), (uns ? b : $signed(b)), uns);
always @(negedge busy) $display("%0t: %m done  p=%0d (0x%016x)", $time, (uns ? m : $signed(m)), m);
`endif

endmodule
