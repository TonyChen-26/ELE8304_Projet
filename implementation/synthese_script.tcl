# Set verbosity level and VHDL standard version
set_db information_level     9
set_db hdl_vhdl_read_version 2008

# Set search paths for HDL and libraries
set_db init_hdl_search_path $::env(SRC_DIR)
set_db init_lib_search_path [list $::env(FE_TIM_LIB) $::env(BE_QRC_LIB) $::env(BE_LEF_LIB)]

# Read library and physical files
read_libs -max_libs slow_vdd1v0_basicCells.lib -min_libs fast_vdd1v0_basicCells.lib
read_physical -lef gsclib045_tech.lef
read_qrc gpdk045.tch

# Set interconnect mode
set_db interconnect_mode ple

set_db hdl_vhdl_read_version 2008
read_hdl -vhdl riscv_pkg.vhd riscv_halfadder.vhd riscv_adder.vhd riscv_alu.vhd riscv_pc.vhd riscv_rf.vhd riscv_decoder.vhd riscv_DMEM.vhd riscv_ex.vhd riscv_fetch.vhd riscv_me.vhd riscv_predecode.vhd riscv_id.vhd riscv_wb.vhd
read_hdl -vhdl riscv_core.vhd

# Elaborate design
elaborate riscv_core

# Perform design checks
check_design -unresolved

# Read SDC constraints
read_sdc $::env(CONST_DIR)/timing.sdc

# Generate timing and clock reports
report_timing -lint > $::env(SYN_REP_DIR)/riscv_core.timing_lint.rpt
report_clocks > $::env(SYN_REP_DIR)/riscv_core.clk.rpt
report_clocks -generated > $::env(SYN_REP_DIR)/riscv_core.clk.rpt

# Synthesis: Generic mapping
set_db syn_generic_effort high
syn_generic riscv_core
write_hdl > $::env(SYN_NET_DIR)/riscv_core.syn_gen.v

# Synthesis: Mapping
set_db syn_map_effort high
syn_map riscv_core
write_hdl > $::env(SYN_NET_DIR)/riscv_core.syn_map.v

# Synthesis: Optimization
set_db syn_opt_effort high
syn_opt riscv_core
write_hdl > $::env(SYN_NET_DIR)/riscv_core.syn_opt.v

# Final outputs
write_hdl > $::env(SYN_NET_DIR)/riscv_core.syn.v
write_sdf -nonegchecks -setuphold split -version 2.1 > $::env(SYN_NET_DIR)/riscv_core.syn.sdf
write_sdc > $::env(CONST_DIR)/riscv_core.syn.sdc

# Generate reports
report_timing > $::env(SYN_REP_DIR)/riscv_core.syn.timing.rpt
report_area > $::env(SYN_REP_DIR)/riscv_core.syn.area.rpt
report_gates > $::env(SYN_REP_DIR)/riscv_core.syn.gates.rpt
report_power > $::env(SYN_REP_DIR)/riscv_core.syn.power.rpt
