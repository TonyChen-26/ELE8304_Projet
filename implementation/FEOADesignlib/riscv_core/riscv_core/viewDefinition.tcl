if {![namespace exists ::IMEX]} { namespace eval ::IMEX {} }
set ::IMEX::dataVar [file dirname [file normalize [info script]]]
set ::IMEX::libVar ${::IMEX::dataVar}/libs

create_library_set -name fast_libset\
   -timing\
    [list ${::IMEX::libVar}/mmmc/fast_vdd1v0_basicCells.lib]\
   -si\
    [list ${::IMEX::libVar}/mmmc/fast.cdb]
create_library_set -name slow_libset\
   -timing\
    [list ${::IMEX::libVar}/mmmc/slow_vdd1v0_basicCells.lib]\
   -si\
    [list ${::IMEX::libVar}/mmmc/slow.cdb]
create_op_cond -name fast_opcond -library_file ${::IMEX::libVar}/mmmc/fast_vdd1v0_basicCells.lib -P 1 -V 1 -T 0
create_op_cond -name slow_opcond -library_file ${::IMEX::libVar}/mmmc/slow_vdd1v0_basicCells.lib -P 1 -V 0.9 -T 125
create_rc_corner -name rc\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0\
   -qx_tech_file ${::IMEX::libVar}/mmmc/rc/gpdk045.tch
create_delay_corner -name slow_corner\
   -library_set slow_libset\
   -rc_corner rc
create_delay_corner -name fast_corner\
   -library_set fast_libset\
   -rc_corner rc
create_constraint_mode -name const\
   -sdc_files\
    [list ${::IMEX::libVar}/mmmc/const.sdc]
create_analysis_view -name slow_av -constraint_mode const -delay_corner slow_corner -latency_file ${::IMEX::dataVar}/mmmc/views/slow_av/latency.sdc
create_analysis_view -name fast_av -constraint_mode const -delay_corner fast_corner -latency_file ${::IMEX::dataVar}/mmmc/views/fast_av/latency.sdc
set_analysis_view -setup [list slow_av] -hold [list fast_av]
