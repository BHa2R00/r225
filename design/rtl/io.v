module io (pad, dc, di, ie, oe, pu, pd);
inout pad;
output dc;
input di, ie, oe, pu, pd;
`ifdef SMIC55

//Input&Inout
wire        POC = 1'd1;
wire        VDDAON_OK_HV = 1'd1;
wire        IOLATCH_HV = 1'd1;
wire        DS_HV = 1'd0;
wire        DI = di;
wire        OE = oe;
wire        IE = ie;
wire        IS = 1'd0;
wire        PE = 1'd1;
wire        PS = 1'd1;
wire  [1:0] DR = 2'd2;
//Output
wire       DC;

GPIO1RT_33_5T_XR
u_io
(
//Input&Inout
 . POC ( POC ),
 . VDDAON_OK_HV ( VDDAON_OK_HV ),
 . IOLATCH_HV ( IOLATCH_HV ),
 . DS_HV ( DS_HV ),
 . DI ( DI ),
 . OE ( OE ),
 . IE ( IE ),
 . IS ( IS ),
 . PE ( PE ),
 . PS ( PS ),
 . DR ( DR ),
 . YAR (),
 . YA (),
 . PAD (pad),
//Output
 . DC (dc)
);

`elsif SAED32
B4I1025_NS u_io (.PADIO(pad),.PULL_UP(pu),.EN(oe),.DOUT(dc),.DIN(di),.PULL_DOWN(pd),.R_EN(ie));
`else 
assign dc = ie ? pad : pu ? 1'b1 : pd ? 1'b0 : 1'bz;
assign pad = oe ? di : pu ? 1'b1 : pd ? 1'b0 : 1'bz;
`endif
endmodule
