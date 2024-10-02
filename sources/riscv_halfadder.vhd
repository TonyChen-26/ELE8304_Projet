-------------------------------------------------------------------------------
-- Project  ELE8304 : Circuits intÃ©grÃ©s Ã  trÃ¨s grande Ã©chelle
-- Polytechnique MontrÃ©al
-------------------------------------------------------------------------------
-- File     riscv_adder.vhd
-- Author   ThÃ©o Dupuis  <theo.dupuis@polymtl.ca>
-- Date     2022-08-27
-------------------------------------------------------------------------------
-- Description 	Half Adder
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity riscv_halfadder is

  port (
        in_a    : in  std_logic;
        in_b    : in  std_logic;
        o_carry : out std_logic;
	out_sum : out std_logic
  );
end entity riscv_halfadder;

architecture beh of riscv_halfadder is

begin
    out_sum <= in_a XOR in_b;
    o_carry <= in_a AND in_b;
end architecture beh;