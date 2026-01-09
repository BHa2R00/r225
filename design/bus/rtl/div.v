`timescale 1ns/1ps

module div
(
  input  wire        scan_mode,
  input  wire        fclk,
  output  reg        c_ready,
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
reg signed [31:0] a, b;  // a = dividend, b = divisor
wire [31:0] dven = uns ? a : (a[31] ? (32'd0 - a) : a);
wire [31:0] dvsr = uns ? b : (b[31] ? (32'd0 - b) : b);
reg [63:0] rq;
wire sign = ~uns & (a[31] ^ b[31]);
wire signed [31:0] q = sign ? (32'd0 - rq[31:0]) : rq[31:0];
wire signed [31:0] r = sign ? (32'd0 - rq[63:32]) : rq[63:32];
reg [31:0] a_last, b_last;

always @(negedge frstb or posedge fclk) begin
  if (~frstb) begin
    cnt <= 6'd0;
    a_last <= 32'd0;
    b_last <= 32'd0;
  end
  else begin
    if (cnt == 6'd0) begin
      if (setb) begin
        if(a==a_last && b==b_last) begin
          cnt <= 6'd1;
        end
        else begin
          cnt <= 6'd33;
          rq <= {32'd0,dven};
        end
      end
    end
    else if (cnt > 6'd1) begin
      cnt <= cnt - 6'd1;
      rq <= 
        (rq[62:31] >= dvsr) ? {(rq[62:31] - dvsr),rq[30:0],1'b1} : 
        rq << 1;
    end
    else if (cnt == 6'd1) begin
      if (~setb) begin
        cnt <= 6'd0;
        a_last <= a;
        b_last <= b;
      end
    end
  end
end

wire busy = cnt > 6'd1;
wire done = cnt == 6'd1;

// bus address decode (identical to multiplier)
wire c_addr_a   = (c_addr&~32'h3) == 32'h00 ;
wire c_addr_b   = (c_addr&~32'h3) == 32'h04 ;
wire c_addr_q   = (c_addr&~32'h3) == 32'h08 ;
wire c_addr_r   = (c_addr&~32'h3) == 32'h0c ;
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
    if (&{c_valid}) begin
      case (1'b1)
        c_addr_a : begin
          c_rdata1[31:0] <= a;
          if (c_write) a <= c_wdata1;
        end
        c_addr_b : begin
          c_rdata1[31:0] <= b;
          if (c_write) b <= c_wdata1;
        end
        c_addr_q : c_rdata1[31:0] <= q;
        c_addr_r : c_rdata1[31:0] <= r;
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
//always @(posedge setb) $write("%0t: %m start a=%0d b=%0d uns=%0b\n", $time, (uns ? a : $signed(a)), (uns ? b : $signed(b)), uns);
//always @(negedge busy) $write("%0t: %m done  q=%0d r=%0d (0x%016x)\n", $time, (uns ? q : $signed(q)), (uns ? r : $signed(r)), rq);
`endif

endmodule
