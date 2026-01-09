`timescale 1ns/1ps


module pll 
(
  input scan_mode, 
  output lck, 
  input rstb, clk 
);

wire next_lck;

`ifdef SMIC55
wire        EN_PLL = rstb;         //Enable pll
wire        CKIN = clk;           //Reference clock
wire  [5:0] DIV_PRE = 6'd1;        //Pre-divider, 6'd0 is forbidden
wire  [7:0] DIV_LOOP = 8'd1;       //Loop-divider, 8'd0 is forbidden
wire  [5:0] DIV_OUT = 6'd1;        //Output-divider, 6'd0 is forbidden
wire  [2:0] SW_VCO = 3'd0;         //The VCO oscillating frequncy adjust signals
wire  [1:0] SW_ICP = 2'd0;         //The register used to controlling the current of charge pump
wire        SW_LP = 1'b0;          //Low power mode enable signal
wire        SW_LOCK = 1'd0;        //Low bypass signal for PLL lock detection
wire  [1:0] SW_VREG = 2'd0;        //Internal regulator output voltage control

//Digital pins output
wire       CLK_OUT;        //Output clock of PLL
//wire       CLK_HF;         //Output clock of VCO bypass DIV_OUT
wire       CLK_OUT_DIV4;   //Div4 Output clock of CLK_OUT
wire       LOCK;           //PLL lock signal

XRS55NEFLCLKPLL_LPMFC 
u_pll 
(
//Power
  //VCC12_PLL,      //1.2V
  //VDD12_PLL,      //1.2V
  //AGND1_PLL,      //1.2V
  //AGND2_PLL,      //1.2V
  //VSS12_PLL,      //1.2V
//Digital pins input
 . EN_PLL   ( EN_PLL   ),         //Enable pll
 . CKIN     ( CKIN     ),           //Reference clock
 . DIV_PRE  ( DIV_PRE  ),        //Pre-divider, 6'd0 is forbidden
 . DIV_LOOP ( DIV_LOOP ),       //Loop-divider, 8'd0 is forbidden
 . DIV_OUT  ( DIV_OUT  ),        //Output-divider, 6'd0 is forbidden
 . SW_VCO   ( SW_VCO   ),         //The VCO oscillating frequncy adjust signals
 . SW_ICP   ( SW_ICP   ),         //The register used to controlling the current of charge pump
 . SW_LP    ( SW_LP    ),          //Low power mode enable signal
 . SW_LOCK  ( SW_LOCK  ),        //Low bypass signal for PLL lock detection
 . SW_VREG  ( SW_VREG  ),        //Internal regulator output voltage control
//Digital pins output
 . CLK_OUT  ( CLK_OUT ),        //Output clock of PLL
//  CLK_HF,         //Output clock of VCO bypass DIV_OUT
 . CLK_OUT_DIV4 ( CLK_OUT_DIV4 ),   //Div4 Output clock of CLK_OUT
 . LOCK     ( LOCK )       //PLL lock signal
);

assign next_lck = CLK_OUT_DIV4;

`elsif SAED32
wire       REF_CLK = clk;
wire       FB_CLK = 1'b0;
wire       FB_MODE = 1'b0;
wire       PLL_BYPASS = 1'b0;


wire        CLK_4X,CLK_2X,CLK_1X;

PLL
u_pll 
(
  .REF_CLK(REF_CLK),
  .FB_CLK(FB_CLK),
  .FB_MODE(FB_MODE),
  .PLL_BYPASS(PLL_BYPASS),

  .CLK_4X(CLK_4X),
  .CLK_2X(CLK_2X),
  .CLK_1X(CLK_1X)
  );

assign next_lck = CLK_4X;
`elsif ALTERA
	wire [0:0] sub_wire2 = 1'h0;
	wire [4:0] sub_wire3;
	wire  sub_wire0 = clk;
	wire [1:0] sub_wire1 = {sub_wire2, sub_wire0};
	wire [0:0] sub_wire4 = sub_wire3[0:0];
	assign  next_lck = sub_wire4;

  altpll	altpll_component (
				.inclk (sub_wire1),
				.clk (sub_wire3),
				.activeclock (),
				.areset (1'b0),
				.clkbad (),
				.clkena ({6{1'b1}}),
				.clkloss (),
				.clkswitch (1'b0),
				.configupdate (1'b0),
				.enable0 (),
				.enable1 (),
				.extclk (),
				.extclkena ({4{1'b1}}),
				.fbin (1'b1),
				.fbmimicbidir (),
				.fbout (),
				.fref (),
				.icdrclk (),
				.locked (),
				.pfdena (1'b1),
				.phasecounterselect ({4{1'b1}}),
				.phasedone (),
				.phasestep (1'b1),
				.phaseupdown (1'b1),
				.pllena (1'b1),
				.scanaclr (1'b0),
				.scanclk (1'b0),
				.scanclkena (1'b1),
				.scandata (1'b0),
				.scandataout (),
				.scandone (),
				.scanread (1'b0),
				.scanwrite (1'b0),
				.sclkout0 (),
				.sclkout1 (),
				.vcooverrange (),
				.vcounderrange ());
	defparam
		altpll_component.bandwidth_type = "AUTO",
		altpll_component.clk0_duty_cycle = 50,
		altpll_component.clk0_multiply_by = 4,
		altpll_component.clk0_divide_by = 1,
		altpll_component.clk0_phase_shift = "0",
		altpll_component.compensate_clock = "CLK0",
		altpll_component.inclk0_input_frequency = 50000,
		altpll_component.intended_device_family = "Cyclone IV E",
		altpll_component.lpm_hint = "CBX_MODULE_PREFIX=altpll_50_1",
		altpll_component.lpm_type = "altpll",
		altpll_component.operation_mode = "NORMAL",
		altpll_component.pll_type = "AUTO",
		altpll_component.port_activeclock = "PORT_UNUSED",
		altpll_component.port_areset = "PORT_UNUSED",
		altpll_component.port_clkbad0 = "PORT_UNUSED",
		altpll_component.port_clkbad1 = "PORT_UNUSED",
		altpll_component.port_clkloss = "PORT_UNUSED",
		altpll_component.port_clkswitch = "PORT_UNUSED",
		altpll_component.port_configupdate = "PORT_UNUSED",
		altpll_component.port_fbin = "PORT_UNUSED",
		altpll_component.port_inclk0 = "PORT_USED",
		altpll_component.port_inclk1 = "PORT_UNUSED",
		altpll_component.port_locked = "PORT_UNUSED",
		altpll_component.port_pfdena = "PORT_UNUSED",
		altpll_component.port_phasecounterselect = "PORT_UNUSED",
		altpll_component.port_phasedone = "PORT_UNUSED",
		altpll_component.port_phasestep = "PORT_UNUSED",
		altpll_component.port_phaseupdown = "PORT_UNUSED",
		altpll_component.port_pllena = "PORT_UNUSED",
		altpll_component.port_scanaclr = "PORT_UNUSED",
		altpll_component.port_scanclk = "PORT_UNUSED",
		altpll_component.port_scanclkena = "PORT_UNUSED",
		altpll_component.port_scandata = "PORT_UNUSED",
		altpll_component.port_scandataout = "PORT_UNUSED",
		altpll_component.port_scandone = "PORT_UNUSED",
		altpll_component.port_scanread = "PORT_UNUSED",
		altpll_component.port_scanwrite = "PORT_UNUSED",
		altpll_component.port_clk0 = "PORT_USED",
		altpll_component.port_clk1 = "PORT_UNUSED",
		altpll_component.port_clk2 = "PORT_UNUSED",
		altpll_component.port_clk3 = "PORT_UNUSED",
		altpll_component.port_clk4 = "PORT_UNUSED",
		altpll_component.port_clk5 = "PORT_UNUSED",
		altpll_component.port_clkena0 = "PORT_UNUSED",
		altpll_component.port_clkena1 = "PORT_UNUSED",
		altpll_component.port_clkena2 = "PORT_UNUSED",
		altpll_component.port_clkena3 = "PORT_UNUSED",
		altpll_component.port_clkena4 = "PORT_UNUSED",
		altpll_component.port_clkena5 = "PORT_UNUSED",
		altpll_component.port_extclk0 = "PORT_UNUSED",
		altpll_component.port_extclk1 = "PORT_UNUSED",
		altpll_component.port_extclk2 = "PORT_UNUSED",
		altpll_component.port_extclk3 = "PORT_UNUSED",
		altpll_component.width_clock = 5;
`elsif XILINX
/*wire clkfb, locked;
wire clkfbout, clkfboutb_unused;
wire clkout0, clkout0b_unused;
wire clkout1, clkout1b_unused;
wire clkout2_unused, clkout2b_unused;
wire clkout3_unused, clkout3b_unused;
wire clkout4_unused, clkout5_unused, clkout6_unused;
wire locked, clkinstopped_unused, clkfbstopped_unused;
wire do_unused, drdy_unused, psdone_unused;
MMCME2_ADV #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT4_CASCADE("FALSE"),
    .COMPENSATION("ZHOLD"),
    .STARTUP_WAIT("FALSE"),
    .DIVCLK_DIVIDE(1),
    .CLKFBOUT_MULT_F(96.000),
    .CLKFBOUT_PHASE(0.000),
    .CLKFBOUT_USE_FINE_PS("FALSE"),
    .CLKOUT0_DIVIDE_F(50.000),
    .CLKOUT0_PHASE(0.000),
    .CLKOUT0_DUTY_CYCLE(0.500),
    .CLKOUT0_USE_FINE_PS("FALSE"),
    .CLKOUT1_DIVIDE(5),
    .CLKOUT1_PHASE(0.000),
    .CLKOUT1_DUTY_CYCLE(0.500),
    .CLKOUT1_USE_FINE_PS("FALSE"),
    .CLKIN1_PERIOD(6.666)  // 输入时钟周期 (150 MHz)
) pll_inst (
    .CLKFBOUT(clkfbout),
    .CLKFBOUTB(clkfboutb_unused),
    .CLKOUT0(),
    .CLKOUT0B(clkout0b_unused),
    .CLKOUT1(clkout1),
    .CLKOUT1B(clkout1b_unused),
    .CLKOUT2(clkout2_unused),
    .CLKOUT2B(clkout2b_unused),
    .CLKOUT3(clkout3_unused),
    .CLKOUT3B(clkout3b_unused),
    .CLKOUT4(clkout4_unused),
    .CLKOUT5(clkout5_unused),
    .CLKOUT6(clkout6_unused),
    .CLKFBIN(clkfbout),
    .CLKIN1(clk),
    .CLKIN2(1'b0),
    .CLKINSEL(1'b1),
    .DADDR(7'h0),
    .DCLK(1'b0),
    .DEN(1'b0),
    .DI(16'h0),
    .DO(do_unused),
    .DRDY(drdy_unused),
    .DWE(1'b0),
    .PSCLK(1'b0),
    .PSEN(1'b0),
    .PSINCDEC(1'b0),
    .PSDONE(psdone_unused),
    .LOCKED(locked),
    .CLKINSTOPPED(clkinstopped_unused),
    .CLKFBSTOPPED(clkfbstopped_unused),
    .PWRDWN(1'b0),
    .RST(rstb)
);
assign next_lck = clkout0;*/
assign next_lck = clk;

`elsif SIM
reg on, pll_clk;
initial pll_clk = 0;
always #2.5 pll_clk = ~(pll_clk && on);
always@(negedge rstb or posedge clk) begin
  if(~rstb) on <= 0;
  else on <= 1;
end
assign next_lck = pll_clk;
`else
assign next_lck = clk;
`endif

//assign lck = scan_mode ? clk : next_lck;
clkmux u_lck (.lck(lck), .sel(scan_mode), .clk1(clk), .clk(next_lck));

endmodule
