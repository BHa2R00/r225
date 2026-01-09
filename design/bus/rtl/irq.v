module irq 
#(
  parameter MSB = 4
)(
  output reg out, 
  input [MSB:0] in, 
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
reg [31:0] mask;
wire next_out = |(mask[MSB:0] & in[MSB:0]);
reg  [31:0] c_rdata1;
wire [31:0] c_wdata1 = c_wdata << (8*c_addr[1:0]);
assign c_rdata = c_rdata1 >> (8*c_addr[1:0]);
always@(negedge c_rstb or posedge c_clk) begin
  if(~c_rstb) begin
    c_ready <= 1'b0;
    mask <= 32'h0;
    out <= 1'b0;
  end
  else begin
    c_ready <= c_valid;
    if(&{c_valid}) begin
      case(c_addr&~32'h3)
        'h0 : begin
          c_rdata1 <= mask;
          if(c_write) mask <= c_wdata1;
        end
      endcase
    end
    out <= next_out;
  end
end
endmodule
