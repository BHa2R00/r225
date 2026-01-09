`timescale 1ns/1ps

module crc (
  output            req, 
   input            ack, 
  output reg        c_ready, 
  output     [31:0] c_rdata, 
   input     [31:0] c_wdata, 
   input            c_write, 
   input     [31:0] c_addr, 
   input     [ 1:0] c_size, 
   input            c_valid, 
   input            c_rstb, c_clk
);

localparam AMSB = 5;
localparam MSB = (1<<AMSB)-1;
reg bitmode;
reg [2:0] ldb;
reg [4:0] bth;
wire c_addr_dat = (c_addr&~32'h3) == 'h00;
wire c_addr_tap = (c_addr&~32'h3) == 'h04;
wire c_addr_sum = (c_addr&~32'h3) == 'h08;
wire c_addr_ctl = (c_addr&~32'h3) == 'h0c;
wire c_addr_xor = (c_addr&~32'h3) == 'h10;
wire signed [AMSB:0] msb = {ldb,3'b000}-6'd1;
reg [MSB:0] tap;
reg [MSB:0] sum;
reg [MSB:0] chk;
reg [MSB:0] check;
reg [31:0] dat;
wire x = bitmode ? dat[msb[4:0]] : dat[0];
reg [AMSB:0] k;
reg cst;
reg dma;
reg [15:0] cnt;

always@(negedge c_rstb or posedge c_clk) begin
  if(~c_rstb) begin
    bth <= 5'd0;
    sum <= {(MSB+1){1'b0}};
    cst <= 1'b0;
  end
  else if(dma ? ack : &{c_addr_dat,c_valid,~c_ready,c_write}) begin
    dat <= c_wdata;
    bth <= msb[4:0];
    cst <= 1'b0;
    cnt <= cnt + 16'd1;
  end
  else if(&{c_addr_sum,c_valid,~c_ready,c_write}) begin
    sum <= c_wdata;
    cnt <= 16'd0;
  end
  else if(bth > 0) begin
    dat <= bitmode ? (dat<<1) : (dat>>1);
    bth <= bth - 5'd1;
    check = {(MSB+1){1'b0}};
    for(k=0;MSB>=k;k=k+1) begin
      if(msb>k) begin
        if(tap[msb[AMSB-1:0]-k[AMSB-1:0]]) begin
          sum[msb[AMSB-1:0]-k[AMSB-1:0]] <= 
            sum[msb[AMSB-1:0]] 
            ^ x ^ 
            sum[msb[AMSB-1:0]-k[AMSB-1:0]-1];
        end
        else begin
          sum[msb[AMSB-1:0]-k[AMSB-1:0]] <= sum[msb[AMSB-1:0]-k[AMSB-1:0]-1];
        end
        check[k] = chk[k] ^ sum[k];
      end
    end
    sum[0] <= sum[msb[AMSB-1:0]] ^ x;
  end
  else begin
    cst <= 1'b1;
  end
end
assign req = dma && cst;

reg  [31:0] c_rdata1;
wire [31:0] c_wdata1 = c_wdata << (8*c_addr[1:0]);
assign c_rdata = c_rdata1 >> (8*c_addr[1:0]);
always@(negedge c_rstb or posedge c_clk) begin
  if(~c_rstb) begin
    c_ready <= 1'b0;
    c_rdata1 <= 32'h0;
    bitmode <= 1'd0;
    ldb <= 3'd4;
    tap <= {(MSB+1){1'b0}};
    dma <= 1'b0;
    chk <= {(MSB+1){1'b0}};
  end 
  else begin
    c_ready <= c_valid;
    c_rdata1 <= 32'h0;
  if(&{c_valid,~c_ready}) begin
    case(1'b1)
      c_addr_dat : begin
          c_rdata1[31: 0] <= dat;
      end
      c_addr_tap : begin
          c_rdata1[31: 0] <= tap;
        if(c_write) begin
          tap <= c_wdata1[31: 0];
        end
      end
      c_addr_sum : begin
          c_rdata1[31: 0] <= sum;
      end
      c_addr_ctl : begin
          c_rdata1[ 0]    <= bitmode;
          c_rdata1[ 3: 1] <= ldb    ;
          c_rdata1[ 8: 4] <= bth    ;
          c_rdata1[ 9]    <= dma    ;
          c_rdata1[10]    <= cst    ;
          c_rdata1[31:16] <= cnt    ;
        if(c_write) begin
          bitmode <= c_wdata1[ 0]   ;
          ldb     <= c_wdata1[ 3: 1];
          dma     <= c_wdata1[ 9]   ;
        end
      end
      c_addr_xor : begin
          c_rdata1[31: 0] <= check;
        if(c_write) begin
          chk   <= c_wdata1[31: 0];
        end
      end
    endcase
  end
  end
end

`ifdef SIM
always@(tap) $write("%0t %m sum=%0x\n",$time,tap);
always@(sum) $write("%0t %m sum=%0x\n",$time,sum);
`endif

endmodule
