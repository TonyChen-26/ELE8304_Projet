library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Import the RISC-V package
library work;
use work.riscv_pkg.all;

entity tb_riscv_rf is
end tb_riscv_rf;

architecture beh of tb_riscv_rf is

  -- Signals for connecting to the register file
  signal tb_clk     : std_logic := '0';
  signal tb_rstn    : std_logic := '1';
  signal tb_we      : std_logic := '0';
  signal tb_addr_ra : std_logic_vector(REG_WIDTH-1 downto 0) := (others => '0');
  signal tb_addr_rb : std_logic_vector(REG_WIDTH-1 downto 0) := (others => '0');
  signal tb_addr_w  : std_logic_vector(REG_WIDTH-1 downto 0) := (others => '0');
  signal tb_data_w  : std_logic_vector(XLEN-1 downto 0) := (others => '0');
  signal tb_data_ra : std_logic_vector(XLEN-1 downto 0);
  signal tb_data_rb : std_logic_vector(XLEN-1 downto 0);

  -- Clock period definition
  constant clk_period : time := 10 ns;

begin

  -- Instantiate the register file (RF) module
  uut: entity work.riscv_rf
    port map (
      i_clk     => tb_clk,
      i_rstn    => tb_rstn,
      i_we      => tb_we,
      i_addr_ra => tb_addr_ra,
      o_data_ra => tb_data_ra,
      i_addr_rb => tb_addr_rb,
      o_data_rb => tb_data_rb,
      i_addr_w  => tb_addr_w,
      i_data_w  => tb_data_w
    );

  -- Clock generation process
  process
  begin
    tb_clk <= '0';
    wait for clk_period / 2;
    tb_clk <= '1';
    wait for clk_period / 2;
  end process;

  -- Test process to verify functionality
  process
  begin
     --Test case 1: Reset the register file
    tb_rstn <= '0';  -- Assert reset
    wait for clk_period;
    tb_rstn <= '1';  -- Deassert reset
    wait for clk_period;
   
    assert tb_data_ra = std_logic_vector(to_unsigned(0,XLEN))  report "Reset failed" severity error;
    assert tb_data_rb = std_logic_vector(to_unsigned(0,XLEN))  report "Reset failed" severity error;

    -- Test case 2: Write data to register 1 and verify
    tb_we <= '1';  -- Enable write
    tb_addr_w <= "00001";  -- Write to register 1
    tb_data_w <= x"12345678";  -- Data to write
    wait for clk_period;

    tb_we <= '0';  -- Disable write
    tb_addr_ra <= "00001";  -- Read from register 1
    wait for clk_period;

    assert tb_data_ra = x"12345678" report "Write to register 1 failed" severity error;
    -- Test case 3: Write to another register and verify
    tb_we <= '1';  -- Enable write
    tb_addr_w <= "00010";  -- Write to register 2
    tb_data_w <= x"ABCDEF12";  -- Data to write
    wait for clk_period;

    tb_we <= '0';  -- Disable write
    tb_addr_ra <= "00001";  -- Read from register 1
    tb_addr_rb <= "00010";  -- Read from register 2
    wait for clk_period;

    assert tb_data_ra = x"12345678" report "Read from register 1 failed" severity error;
    assert tb_data_rb = x"ABCDEF12" report "Read from register 2 failed" severity error;

    -- Test case 4: Forwarding test
    tb_we <= '1';  -- Enable write
    tb_addr_w <= "00001";  -- Write to register 1 again
    tb_data_w <= x"87654321";  -- New data to write
    tb_addr_ra <= "00001";  -- Read from register 1 (should forward new value)
    wait for clk_period;

    assert tb_data_ra = x"87654321" report "Forwarding failed" severity error;

    -- End simulation
    wait;
  end process;

end architecture beh;