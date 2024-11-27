# Fichier    : riscv_core_constraints.sdc
# Description: Contraintes temporelles pour le core RISC-V
# ------------------------------------------------

# Définition des unités par défaut
set_time_unit -picoseconds
set_load_unit -femtofarads

# Point de fonctionnement (1.1V, 25°C typique)
set_operating_conditions -max_library PVT_1P1V_25C -min_library PVT_0P9V_125C

# Définition de l'horloge principale
set clk "clk"
create_clock -period 10000 -name $clk [get_ports i_clk] ;# Période de 10 ns (100 MHz)

# Incertitudes sur l'horloge : setup = 200ps, hold = 50ps
set_clock_uncertainty -setup 200 [get_clocks $clk]
set_clock_uncertainty -hold 50  [get_clocks $clk]

# Contrainte de reset (faux chemin car reset asynchrone)
set_false_path -from [get_ports i_rstn]

# Contraintes d'entrée : Retard d'entrée par rapport à l'horloge
set_input_delay -max 300 -clock [get_clocks $clk] [all_inputs]
set_input_delay -min 100 -clock [get_clocks $clk] [all_inputs]

# Définition du driver externe pour les entrées
set_driving_cell -lib_cell BUFX20 [all_inputs]

# Contraintes de sortie : Retard de sortie par rapport à l'horloge
set_output_delay -max 300 -clock [get_clocks $clk] [all_outputs]
set_output_delay -min 100 -clock [get_clocks $clk] [all_outputs]

# Capacité de charge sur les sorties
set_load 500 [all_outputs] ;# 500 fF de charge capacitive externe

# Contraintes sur les chemins asynchrones et spécifiques
set_false_path -from [get_ports i_scan_en]
set_false_path -from [get_ports i_test_mode]
set_false_path -from [get_ports i_tdi]
