module dma
(
  // data 
   input     [31:0] d_rdata, 
   input            d_ready, 
  output            d_valid, 
  output     [31:0] d_wdata, 
  output            d_write, 
  output     [31:0] d_addr, 
  output     [ 1:0] d_size, 
  input             d_rstb, d_clk,
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

reg [31:0] src_addr;
reg [31:0] src_addr0;
reg [31:0] src_addr1;
reg [31:0] dst_addr;
reg [31:0] dst_addr0;
reg [31:0] dst_addr1;
reg [1:0] size;
reg [1:0] count;
reg [31:0] data;

reg  [31:0] c_rdata1;
wire [31:0] c_wdata1 = c_wdata << (8*c_addr[1:0]);
assign c_rdata = c_rdata1 >> (8*c_addr[1:0]);
always@(negedge c_rstb or posedge c_clk) begin
  if(~c_rstb) begin
    c_ready <= 1'b0;
  end
  else begin
    c_ready <= c_valid;
    c_rdata1 <= 32'h0;
  end
end

endmodule
