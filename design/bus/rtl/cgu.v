module cgu (
   input            scan_mode, 
  output     [ 3:0] lrb, 
  output     [ 3:0] lck, 
   input     [31:0] rtc, 
   input     [ 3:0] fclk, 
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

wire [35:0] clk_src = {rtc,fclk};
reg [4:0] sel[0:3];
assign lck[0] = scan_mode ? c_clk : clk_src[sel[0]];
assign lck[1] = scan_mode ? c_clk : clk_src[sel[1]];
assign lck[2] = scan_mode ? c_clk : clk_src[sel[2]];
assign lck[3] = scan_mode ? c_clk : clk_src[sel[3]];
rvld u_lrb0 (lrb[0], c_rstb, lck[0], scan_mode);
rvld u_lrb1 (lrb[1], c_rstb, lck[1], scan_mode);
rvld u_lrb2 (lrb[2], c_rstb, lck[2], scan_mode);
rvld u_lrb3 (lrb[3], c_rstb, lck[3], scan_mode);

reg  [31:0] c_rdata1;
wire [31:0] c_wdata1 = c_wdata << (8*c_addr[1:0]);
assign c_rdata = c_rdata1 >> (8*c_addr[1:0]);
always@(negedge c_rstb or posedge c_clk) begin
  if(~c_rstb) begin
    c_ready <= 1'b0;
    c_rdata1 <= 0;
    sel[0] <= 5'd0;
    sel[1] <= 5'd1;
    sel[2] <= 5'd2;
    sel[3] <= 5'd3;
  end
  else begin
    c_ready <= c_valid;
    if(&{c_valid}) begin
      case(c_addr&~32'h3)
        'h0 : begin
          c_rdata1[31:0] <= rtc;
        end
        'h4 : begin
          c_rdata1[ 4: 0] <= sel[0];
          c_rdata1[ 9: 5] <= sel[1];
          c_rdata1[14:10] <= sel[2];
          c_rdata1[19:15] <= sel[3];
          if(c_write) begin
          sel[0] <= c_wdata1[ 4: 0];
          sel[1] <= c_wdata1[ 9: 5];
          sel[2] <= c_wdata1[14:10];
          sel[3] <= c_wdata1[19:15];
          end
        end
      endcase
    end
  end
end

endmodule
