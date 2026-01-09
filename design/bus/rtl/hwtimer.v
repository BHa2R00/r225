`timescale 1ns/1ps

module hwtimer (
  output irq, hit, 
  input frstb, fclk, 
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


reg [31:0] cnt;
reg enable;
reg enable_d;
reg [31:0] load;
reg update;
reg update_d;
reg oneshot;
assign hit = ~|cnt;
reg irq_enable, irq_clr;
intr #(.INIT(1'b0)) 
u_irq (
  .irq(irq), .src(&{enable_d,irq_enable,hit}), .clr(irq_clr), 
  .src_rstb(frstb), .clr_rstb(c_rstb) 
  );
always@(negedge frstb or posedge fclk) begin
  if(~frstb) begin
    cnt <= 32'h0;
    enable_d <= 2'b00;
    update_d <= 1'b0;
  end
  else begin
    if(update_d) cnt <= load;
    else if(enable_d) begin
      if(&{hit,~oneshot}) cnt <= load;
      else if(~hit) cnt <= cnt - 32'd1;
    end
    enable_d <= enable;
    update_d <= update;
  end
end

wire c_valid_ctrl  = (c_addr&~32'h3) == 'h0;
wire c_valid_load  = (c_addr&~32'h3) == 'h4;
wire c_valid_store = (c_addr&~32'h3) == 'h8;
reg  [31:0] c_rdata1;
wire [31:0] c_wdata1 = c_wdata << (8*c_addr[1:0]);
assign c_rdata = c_rdata1 >> (8*c_addr[1:0]);
always@(negedge c_rstb or posedge c_clk) begin
  if(~c_rstb) begin
    c_ready <= 1'b0;
    enable <= 1'b0;
    load <= 32'd0;
    update <= 1'b0;
    oneshot <= 1'b0;
    irq_enable <= 1'b0;
    irq_clr <= 1'b0;
    c_rdata1 <= 32'h0;
  end
  else begin
    c_ready <= c_valid;
    enable     <=                      &{c_valid,c_valid_ctrl,c_write} ? c_wdata1[    0] : enable    ;
    load       <=                      &{c_valid,c_valid_load,c_write} ? c_wdata1[31: 0] : load      ;
    update     <= update ? ~update_d : &{c_valid,c_valid_ctrl,c_write} ? c_wdata1[    1] : update    ;
    oneshot    <=                      &{c_valid,c_valid_ctrl,c_write} ? c_wdata1[    2] : oneshot   ;
    irq_enable <=                      &{c_valid,c_valid_ctrl,c_write} ? c_wdata1[    3] : irq_enable;
    irq_clr    <=                      &{c_valid,c_valid_ctrl,c_write} ? c_wdata1[    4] : 1'b0      ;
    if(&{c_valid}) begin
      case(1)
        c_valid_ctrl : begin
          c_rdata1[0] <= enable_d  ;
          c_rdata1[1] <= update_d  ;
          c_rdata1[2] <= oneshot   ;
          c_rdata1[3] <= irq_enable;
          c_rdata1[4] <= hit       ;
        end
        c_valid_load : c_rdata1 <= load;
        c_valid_store : c_rdata1 <= cnt;
      endcase
    end
  end
end
`ifdef SIM
always@(posedge enable) $write("%0t: %m.enable posedge\n",$time);
always@(negedge enable) $write("%0t: %m.enable negedge\n",$time);
always@(posedge hit) $write("%0t: %m.hit posedge\n",$time);
always@(negedge hit) $write("%0t: %m.hit negedge\n",$time);
`endif

endmodule
