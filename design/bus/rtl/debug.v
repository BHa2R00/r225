`timescale 1ns/1ps

module debug (
   input            boot, 
   input     [31:0] in0, in1, 
  output reg [31:0] out0, out1, 
  output reg        ready, 
  output     [31:0] rdata, 
   input     [31:0] wdata, 
   input            write, 
   input     [31:0] addr, 
   input     [ 1:0] size, 
   input            valid, 
   input            rstb, clk
);

reg  [31:0] rdata1;
wire [31:0] wdata1 = wdata << (8*addr[1:0]);
assign rdata = rdata1 >> (8*addr[1:0]);
always@(negedge rstb or posedge clk) begin
  if(~rstb) begin
    ready <= 1'b0;
    out0 <= 0;
    out1 <= 0;
    rdata1 = 32'd0;
  end
  else begin
    ready <= valid;
    rdata1 = 32'd0;
    if(&{valid}) begin
      case(addr&~32'h3)
        'h00 : begin
          rdata1[31:0] = out0;
          if(write) out0 <= wdata1[31:0];
        end
        'h04 : begin
          rdata1[31:0] = in0;
        end
        'h08 : begin
          rdata1[31:0] = out1;
          if(write) out1 <= wdata1[31:0];
        end
        'h0c : begin
          rdata1[31:0] = in1;
        end
        'h10 : begin
          rdata1[0] = boot;
        end
      endcase
    end
  end
end

`ifdef SIM
always@(out0) $write("%0t %m out0=%0x\n",$time,out0);
always@(out1) $write("%0t %m out1=%0x\n",$time,out1);
`endif

endmodule
