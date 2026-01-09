TIME = $(shell date +%Y%m%d%H%M)
TARGET = riscv32-unknown-elf
#TARGET = riscv-nuclei-elf
AS = $(TARGET)-as 
CC = $(TARGET)-gcc 
LD = $(TARGET)-gcc 
OBJCOPY = $(TARGET)-objcopy 
OBJDUMP = $(TARGET)-objdump 
CFLAGS = -march=rv32e 
CFLAGS += -mabi=ilp32e 
CFLAGS += -static 
CFLAGS += $(shell find ../ -type d -name "include" | sed 's/^/-I/')
CFLAGS += -Os
#CFLAGS += -mstack-align=16
CFLAGS += -ffreestanding 
CFLAGS += -nostdlib -nostartfiles
CFLAGS += -g 
CFLAGS += -Wall 
#CFLAGS += -lc -lgcc 
#CFLAGS += -mpreferred-stack-boundary=2 
#CFLAGS += -misa-spec=2.2
LDFLAGS = -march=rv32e 
LDFLAGS += -mabi=ilp32e 
#LDFLAGS += -static
#LDFLAGS += --specs=nano.specs 
#LDFLAGS += -lc -lgcc 
#LDFLAGS += -mpreferred-stack-boundary=2 
#LDFLAGS += -misa-spec=2.2
#LDFLAGS += -static 
LDFLAGS += -nostdlib -nostartfiles
YOSYS = yosys
YOSYS += -v 4 
#YOSYS += -p
LISP = sbcl 
DESIGN = ../design
LISP += --eval '(progn (require "asdf") (require "cl-ppcre") (require "ieee-floats") (defparameter *prjroot* "$(DESIGN)"))' 
LISP += --load $(DESIGN)/script/flow.lisp
LISP += --load $(DESIGN)/script/afsm.lisp
LISP += --load $(DESIGN)/script/interconnect.lisp
ALLRTL = $(shell find $(DESIGN) -name "*.v")
ALLRTL += $(shell find $(DESIGN) -name "*.vh")
ALLRTL += $(shell find $(DESIGN) -name "*tb.sv")
IVERILOG = iverilog -g2012 
IVERILOG += -DSIM -DFST 
ROM_AWIDTH = 13
ROM_AOFFSET = 2
CLOCKS = clk 
PERIODS = 20 
#FPGA_ALTERA_PART = EP4CE22E22C8
FPGA_ALTERA_PART = EP4CE10E22C8
#FPGA_ALTERA_PART = EP4CE40F23C8
#FPGA_ALTERA_PART = EP4CE15F23C8
FPGA_XILINX_PART = xc7k325tffg676-1
ASIC_LIB =SAED32
#ASIC_LIB =SMIC55
ASIC_EDK = /mnt/nfs/0/a/SAED_Lib/32-28nm_EDK_12162019/
#ASIC_EDK = /data/home/be3/ING92000/ref/
ASIC_EDK_TT = '*nldm*rvt*tt1p05v25c*db' '*nldm*sram*tt1p05v25c*db' '*nldm*pll*tt1p05v25c*db' '*nldm*io*tt1p05v25c*db' 
#ASIC_EDK_TT = '*tt1p2v25c.db' '*r1p*tt*1p2v25c*.db' '*rom*tt*1p2v25c*.db' '*tt_1p2v_25c*db' '*tt_3p3v_1p2v_25c*db' 
ASIC_EDK_PM = '*1p9m*' 
#ASIC_EDK_PM = '*1p6m10005_RDL_mk*' 
V_SRCS  := $(shell find $(ASIC_EDK) -path '*/verilog/*.v')

clean : 
	mv Makefile ..
	rm -rfv ./*
	rm -rfv ./.Xil*
	mv ../Makefile .
backup : 
	cd ../.. && rm 225.7z && 7za a 225.7z 225 
rtl.list :
	../design/script/flow.sh rtl $(DESIGN) rtl.list 
#	$(LISP) --eval '(formverilogfilelist "$(DESIGN)" "$@")' --quit
tb.list :
	../design/script/flow.sh tb $(DESIGN) tb.list 
interconnect : $(DESIGN)/script/top.lisp 
	$(LISP) --script $<
start.o : $(DESIGN)/src/start.S interconnect
	$(CC) $(CFLAGS) -c $< -o $@

test1.o : $(DESIGN)/sim/src/test1.c interconnect
	$(CC) $(CFLAGS) -c $< -o $@
test1.elf : $(DESIGN)/bus/script/bus.ld start.o test1.o 
	$(LD) -T $^ -o $@ $(LDFLAGS) 
test1.bin : test1.elf 
	$(OBJCOPY) -O binary $< $@
	du -b $@

debug.o : $(DESIGN)/sim/src/debug.c interconnect
	$(CC) $(CFLAGS) -c $< -o $@
debug.elf : $(DESIGN)/bus/script/bus.ld start.o debug.o 
	$(LD) -T $^ -o $@ $(LDFLAGS) 
debug.bin : debug.elf 
	$(OBJCOPY) -O binary $< $@
	du -b $@

objdump : test1.elf
	$(OBJDUMP) -S $<
rom.bin : test1.bin objdump
	cp test1.bin rom.bin
	du -b $@
rom.memh : rom.bin
	$(LISP) --eval '(bin2memh "rom.bin" "rom.memh" $(ROM_AWIDTH) $(ROM_AOFFSET))' --quit
flash.memh : rom.bin
	$(LISP) --eval '(bin2memh "rom.bin" "flash.memh" $(ROM_AWIDTH) 0)' --quit
rom.mif : rom.bin
	$(LISP) --eval '(bin2memh "rom.bin" "rom.mif" $(ROM_AWIDTH) $(ROM_AOFFSET) :type "mif")' --quit
../design/inc/rom_comb.vh : rom.bin
	$(LISP) --eval '(bin2memh "rom.bin" "../design/inc/rom_comb.vh" $(ROM_AWIDTH) $(ROM_AOFFSET) :type "verilog")' --quit
top_tb1.vvp : tb.list rom.memh flash.memh 
	$(IVERILOG) -f tb.list -s top_tb1 -o $@ 
top_tb1.fst : top_tb1.vvp
	./top_tb1.vvp -fst
top_tb1_simv: tb.list rom.memh flash.memh 
	vcs -f tb.list -top top_tb1 -o $@ -full64 -sverilog +v2k -debug_access+all -kdb +sdfverbos -timescale=1ns/1ps +define+SIM+FSDB
top_tb1.fsdb: top_tb1_simv
	./top_tb1_simv
verdi: tb.list 
	verdi -f tb.list $< -top top_tb1 +define+SIM+FSDB &

quartus.tcl : $(ALLRTL) rom.mif
	$(LISP) --eval '(formverilogfilelist "$(DESIGN)" "quartus.tcl" :type "quartus" :part "$(FPGA_ALTERA_PART)" :top "top" :clocks "$(CLOCKS)" :periods "$(PERIODS)")' --quit
vivado.tcl: $(ALLRTL) rom.memh
	$(LISP) --eval '(formverilogfilelist "../" "vivado.tcl" :type "vivado" :part "$(FPGA_XILINX_PART)" :top "top" :clocks "$(CLOCKS)" :periods "$(PERIODS)")' --quit
top.sof : quartus.tcl
	quartus_sh -t quartus.tcl
	cp -rfv quartus_output_files/*.sof .
top.jic : top.sof
	quartus_cpf -c $(DESIGN)/fpga/script/top_$(FPGA_ALTERA_PART).cof 

dc_read.tcl : rtl.list
	../design/script/flow.sh dc_shell rtl.list dc_read.tcl $(ASIC_LIB) 
db_lib_tt.tcl : 
	../design/script/flow.sh db_lib db_lib_tt.tcl $(ASIC_EDK) $(ASIC_EDK_TT) 

mw_lib.tcl : 
	../design/script/flow.sh mw_lib mw_lib.tcl $(ASIC_EDK) $(ASIC_EDK_PM) 

top.dc.ddc : rtl.list dc_read.tcl db_lib_tt.tcl 
	dc_shell -f ../design/asic/script/dc_$(ASIC_LIB).tcl 

tessent.atpg : 
	libcomp -verilog $(V_SRCS) -dof ../design/asic/script/tessent.atpg.do -rep -no_define 

libcomp.atpglib : 
	libcomp -verilog $(V_SRCS) -dof -no_define 
#	libcomp -verilog $(V_SRCS) -dof -FASTscan
#	libcomp -verilog $(V_SRCS) -dof -UDP_ATTRibutes 
#	libcomp -verilog $(V_SRCS) -dof -NO_DEFine_simple_views 
#	libcomp $(V_SRCS) -dof -NAME_INStances -NO_DEFine_simple_views 

verilog_lib.tcl : 
	../design/script/flow.sh verilog_lib verilog_lib.tcl $(ASIC_EDK) '*/verilog/*.v'

top.icc.ddc : top.dc.ddc mw_lib.tcl 
	icc_shell -f ../design/asic/script/icc_$(ASIC_LIB).tcl 

