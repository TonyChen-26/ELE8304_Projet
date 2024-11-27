cd /export/tmp/8304_8/Labs/lab2/implementation



# Setup library and design variables
set init_oa_ref_lib [list gsclib045_tech gsclib045 gpdk045 giolib045]
set init_verilog $::env(SYN_NET_DIR)/riscv_core.syn.v
set init_design_settop 1
set init_top_cell riscv_core
set init_gnd_net VSS
set init_pwr_net VDD
set init_mmmc_file $::env(CONST_DIR)/mmmc.tcl

# Initialize the design
init_design

# Floorplan setup
floorPlan -site CoreSite -r 0.9 0.6 1 1 1 1

# Global net connections for power and ground
globalNetConnect VDD -type pgpin -pin VDD -inst * -override
globalNetConnect VSS -type pgpin -pin VSS -inst * -override
globalNetConnect VDD -type tiehi -inst * -override
globalNetConnect VSS -type tielo -inst * -override

# Add power stripes
addStripe -nets VDD -layer Metal1 -direction vertical -width 0.6 \
          -number_of_sets 1 -start_from left -start_offset -0.8
addStripe -nets VSS -layer Metal1 -direction vertical -width 0.6 \
          -number_of_sets 1 -start_from right -start_offset -0.8

# Route power nets to core and floating stripes
sroute -nets {VDD VSS} -connect {corePin floatingStripe}

# Pin assignment settings
setPinAssignMode -pinEditInBatch true

# Edit input and output pins
editPin -pin [list i_clk i_rstn i_scan_en] -edge 1 -layer 4 -spreadType SIDE \
        -offsetEnd 2 -offsetStart 2 -spreadDirection clockwise \
        -pinWidth 0.06 -pinDepth 0.335 -fixOverlap 1
editPin -pin [list o_imem_en o_dmem_en o_dmem_we] -edge 3 -layer 4 -spreadType SIDE \
        -offsetEnd 2 -offsetStart 2 -spreadDirection counterclockwise \
        -pinWidth 0.06 -pinDepth 0.335 -fixOverlap 1
editPin -pin [list o_imem_addr[0] o_imem_addr[1] o_imem_addr[2] o_imem_addr[3] o_imem_addr[4] \
                   o_imem_addr[5] o_imem_addr[6] o_imem_addr[7] o_imem_addr[8]] \
        -edge 0 -layer 3 -spreadType SIDE \
        -offsetEnd 2 -offsetStart 2 -spreadDirection clockwise \
        -pinWidth 0.06 -pinDepth 0.335 -fixOverlap 1
editPin -pin [list o_dmem_addr[0] o_dmem_addr[1] o_dmem_addr[2] o_dmem_addr[3] o_dmem_addr[4] \
                   o_dmem_addr[5] o_dmem_addr[6] o_dmem_addr[7] o_dmem_addr[8]] \
        -edge 0 -layer 3 -spreadType SIDE \
        -offsetEnd 2 -offsetStart 2 -spreadDirection clockwise \
        -pinWidth 0.06 -pinDepth 0.335 -fixOverlap 1
editPin -pin [list o_dmem_write[0] o_dmem_write[1] o_dmem_write[2] o_dmem_write[3] o_dmem_write[4] \
                   o_dmem_write[5] o_dmem_write[6] o_dmem_write[7] o_dmem_write[8] o_dmem_write[9] \
                   o_dmem_write[10] o_dmem_write[11] o_dmem_write[12] o_dmem_write[13] o_dmem_write[14] \
                   o_dmem_write[15] o_dmem_write[16] o_dmem_write[17] o_dmem_write[18] o_dmem_write[19] \
                   o_dmem_write[20] o_dmem_write[21] o_dmem_write[22] o_dmem_write[23] o_dmem_write[24] \
                   o_dmem_write[25] o_dmem_write[26] o_dmem_write[27] o_dmem_write[28] o_dmem_write[29] \
                   o_dmem_write[30] o_dmem_write[31]] \
        -edge 0 -layer 3 -spreadType SIDE \
        -offsetEnd 2 -offsetStart 2 -spreadDirection clockwise \
        -pinWidth 0.06 -pinDepth 0.335 -fixOverlap 1

# Pre-placement timing analysis
timeDesign -prePlace -outDir $::env(PNR_REP_DIR)/timing

# Design and placement settings
setDesignMode -process 45 -flowEffort standard
setPlaceMode -timingDriven true -place_global_cong_effort auto -place_global_reorder_scan true
setPlaceMode -place_global_reorder_scan false
deleteAllScanCells
place_opt_design

# Clock tree optimization
set_ccopt_property buffer_cells [list CLKBUFX20 CLKBUFX16 CLKBUFX12 CLKBUFX8 CLKBUFX6 CLKBUFX4 CLKBUFX3 CLKBUFX2]
set_ccopt_property inverter_cells [list CLKINVX20 CLKINVX6 CLKINVX8 CLKINVX16 CLKINVX12 CLKINVX4 CLKINVX3 CLKINVX2 CLKINVX1]
set_ccopt_property use_inverters true
set_ccopt_property clock_gating_cells TLATNTSCA*
ccopt_design
optDesign -postCTS

# Post-clock-tree synthesis (CTS) timing analysis
timeDesign -postCTS -outDir $::env(PNR_REP_DIR)/timing
timeDesign -hold -postCTS -outDir $::env(PNR_REP_DIR)/timing

# Add filler cells
addFiller -cell FILL32 FILL16 FILL8 FILL4 FILL2 FILL1 -prefix FILLER

# Routing settings and design routing
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -routeWithSIDriven true
routeDesign -globalDetail

# Post-route extraction and analysis
setExtractRCMode -engine postRoute
extractRC
setAnalysisMode -analysisType onChipVariation
setAnalysisMode -cppr both
optDesign -postRoute -setup -hold -outDir $::env(PNR_DIR)/opt
