
module mcrc #
(
  parameter MAX_WIDTH = 32   // maximum supported CRC width
)(
  input                    clk,
  input                    rstb,
  input                    setb, halt, 
  input                    x,               // serial input bit
  input      [MAX_WIDTH-1:0] ini,           // initial value
  input      [MAX_WIDTH-1:0] tap,           // runtime polynomial taps
  input      [$clog2(MAX_WIDTH):0] msb,     // active width-1
  output reg [MAX_WIDTH-1:0] sum
);

reg [MAX_WIDTH-1:0] next_sum;
reg feedback;

always@(*) begin
  // feedback comes from the "active" MSB bit
  feedback = sum[msb] ^ x;

  // default: shift left
  next_sum = (sum << 1);

  // insert feedback at LSB
  next_sum[0] = feedback;

  // conditionally XOR taps if MSB was set
  if (sum[msb])
    next_sum = next_sum ^ tap;

  // mask off unused bits above msb
  next_sum = next_sum & ((1 << (msb+1)) - 1);
end

always @(posedge clk or negedge rstb) begin
  if (!rstb) begin
    sum <= ini;
  end
  else if(setb) begin
    if(!halt) sum <= next_sum;
  end
end

endmodule

/*
module mcrc 
#(
  parameter AMSB = 4, 
  parameter  MSB = (1<<(AMSB-1))-1 
)(
   input     [ MSB:0] ini, 
  output reg [ MSB:0] sum, 
   input              x, 
   input     [ MSB:0] tap, 
   input     [AMSB:0] msb, 
   input              setb, halt, 
   input              rstb, clk 
);

reg signed [AMSB:0] k;
always@(negedge rstb or posedge clk) begin
  if(~rstb) sum <= ini;
  else if(setb) begin
    if(~halt) begin
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
        end
      end
      sum[0] <= sum[msb[AMSB-1:0]] ^ x;
    end
  end
  else sum <= {(MSB+1){1'b0}};
end

endmodule
*/
