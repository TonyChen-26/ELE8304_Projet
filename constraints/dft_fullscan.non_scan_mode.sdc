set_false_path -from [get_ports i_tdi]
set_false_path -to [get_ports o_tdo]    

set_case_analysis 0 [get_ports i_scan_en]
set_case_analysis 0 [get_ports i_test_mode]

set_input_delay 200 -clock [get_clocks clk] [list i_tdi i_scan_en i_test_mode]
set_db [get_ports [list i_tdi i_scan_en i_test_mode]] \
    .external_driver [vfind [vfind / -libcell BUFX20] -libpin Y]

set_output_delay 200 -clock [get_clocks clk] [get_ports o_tdo]
set_db [get_ports o_tdo] .external_pin_cap 500