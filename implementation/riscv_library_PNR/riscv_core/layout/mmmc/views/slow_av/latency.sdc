set_clock_latency -source -early -max -rise  -0.0283791 [get_ports {i_clk}] -clock clk 
set_clock_latency -source -early -max -fall  -0.0328792 [get_ports {i_clk}] -clock clk 
set_clock_latency -source -late -max -rise  -0.0283791 [get_ports {i_clk}] -clock clk 
set_clock_latency -source -late -max -fall  -0.0328792 [get_ports {i_clk}] -clock clk 
