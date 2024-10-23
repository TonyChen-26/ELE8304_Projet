library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.riscv_pkg.all;

entity tb_riscv_pc is
end tb_riscv_pc;

architecture beh of tb_riscv_pc is

 
  signal tb_clk       : std_logic := '0';
  signal tb_rstn      : std_logic := '1';
  signal tb_stall     : std_logic := '0';
  signal tb_transfert : std_logic := '0';
  signal tb_target    : std_logic_vector(XLEN-1 downto 0) := (others => '0');
  signal tb_pc        : std_logic_vector(XLEN-1 downto 0);

 
  constant clk_period : time := 10 ns;

begin


  uut: entity work.riscv_pc
    generic map (RESET_VECTOR => 16#00000000#)
    port map (
      i_clk       => tb_clk,
      i_rstn      => tb_rstn,
      i_stall     => tb_stall,
      i_transfert => tb_transfert,
      i_target    => tb_target,
      o_pc        => tb_pc
    );


  process
  begin
    tb_clk <= '0';
    wait for clk_period / 2;
    tb_clk <= '1';
    wait for clk_period / 2;
  end process;


  process
  begin
    -- Test case 1: Reset counter
    tb_rstn <= '0';  -- Assert reset
    wait for clk_period;


    -- Check if the PC = RESET_VECTOR 
    assert tb_pc = std_logic_vector(to_unsigned(16#00000000#, XLEN))
    report "PC reset failed" severity error;
    tb_rstn <= '1';  -- Deassert reset
    wait for clk_period;
    -- Test case 2: Normal operation - PC increments by ADDR_INCR

    assert tb_pc = std_logic_vector(to_unsigned(ADDR_INCR, XLEN))
      report "PC increment failed" severity error;

    -- Test case 3: Stall the program counter
    tb_stall <= '1';  -- Enable stall
    wait for clk_period;
    assert tb_pc = std_logic_vector(to_unsigned(ADDR_INCR, XLEN))
      report "PC stall failed" severity error;  -- PC should not increment

    -- Test case 4: Remove stall and check increment
    tb_stall <= '0';  -- Disable stall
    wait for clk_period;
    assert tb_pc = std_logic_vector(to_unsigned(ADDR_INCR * 2, XLEN))
    report "PC increment after stall failed" severity error;

    -- Test case 5: Transfer to a new target
    tb_transfert <= '1';  -- Enable transfer
    tb_target <= std_logic_vector(to_unsigned(16#12345678#, XLEN));  -- Target address
    wait for clk_period;

    -- Check if the PC jumped to the target address
    assert tb_pc = std_logic_vector(to_unsigned(16#12345678#, XLEN))
      report "PC transfer failed" severity error;

    -- End simulation
    wait;
  end process;

end architecture beh;
