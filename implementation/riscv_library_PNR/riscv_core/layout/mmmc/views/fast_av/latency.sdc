set_clock_latency -source -early -min -rise  -0.0221857 [get_ports {i_clk}] -clock clk 
set_clock_latency -source -early -min -fall  -0.0261857 [get_ports {i_clk}] -clock clk 
set_clock_latency -source -late -min -rise  -0.0221857 [get_ports {i_clk}] -clock clk 
set_clock_latency -source -late -min -fall  -0.0261857 [get_ports {i_clk}] -clock clk 
