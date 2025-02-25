# Projet RISC-V Pipeline avec Gestion des Conflits

## Description

Ce projet implémente un cœur de processeur RISC-V avec un pipeline incluant des mécanismes de forwarding et de résolution des conflits.

## Fonctionnalités

- Pipeline 5 étapes : FETCH, DECODE, EXECUTE, MEMORY, WRITE_BACK
- Gestion des conflits :
  - Hazards structurels
  - Hazards de données avec forwarding
  - Hazards de contrôle
- Implémentation en VHDL
- Simulation et validation avec des jeux de tests

## Architecture du projet

- **asm/** : Initial revision
- **constraints/** : Initial revision
- **doc/** : Initial revision
- **implementation/** : Initial revision
- **scripts/** : Initial revision
- **simulation/** : Initial revision
- **sources/** : Updating final product
- **README.md** : Initial revision
- **setup.csh** : Initial revision
- **transcript** : 21 octobre

## Prérequis

- Vivado ou ModelSim pour la simulation
- Un environnement VHDL compatible

## Compilation et Simulation

1. Compiler les fichiers VHDL :
   ```bash
   vcom -work work src/*.vhd
   ```
2. Lancer la simulation avec le testbench :
   ```bash
   vsim -c -do "run -all" testbench/tb_processor
   ```

## Auteur

Zacharie E

Tony C

