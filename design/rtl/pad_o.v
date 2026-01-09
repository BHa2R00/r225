module pad_o (pad, di, oe, pu, pd);
inout pad;
input di, oe, pu, pd;
`ifdef SAED32
D4I1025_NS u_o (.PADIO(pad),.EN(oe),.DIN(di));
`else 
assign pad = oe ? di : pu ? 1'b1 : pd ? 1'b0 : 1'bz;

`endif
endmodule
