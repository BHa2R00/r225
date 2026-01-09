create_clock -name {CLK} -period 20.000 [get_ports {CLK}]
create_clock -period 10 [get_pins u_pll/lck -hierarchical ]
create_generated_clock -source [get_pins u_fast_clk/clk -hierarchical ] -divide_by 2 [get_pins u_fast_clk/lck -hierarchical ]
create_generated_clock -source [get_pins u_main_clk/clk -hierarchical ] -divide_by 2 [get_pins u_main_clk/lck -hierarchical ]
foreach icg_pin [get_pins -hierarchical u_*icg/clk] {
    set gclk_pin [string map {clk lck} $icg_pin]
    if {[llength [get_pins $gclk_pin]]} {
        create_generated_clock -source $icg_pin \
                               -add $gclk_pin
    }
}
set_input_delay -clock CLK 2.0 [get_ports {PAD[*]}]
set_output_delay -clock CLK 3.0 [get_ports {PAD[*]}]
set_false_path -from [get_ports RSTB]
