create_clock -name {CLK} -period 20.000 [get_ports {CLK}]
set_input_delay -clock CLK 2.0 [get_ports {PAD[*]}]
set_output_delay -clock CLK 3.0 [get_ports {PAD[*]}]
set_false_path -from [get_ports RSTB]
