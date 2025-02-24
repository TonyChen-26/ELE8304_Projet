library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;

entity tb_riscv_pc is

end entity tb_riscv_pc;

architecture beh of tb_riscv_pc is

  -- Constantes
  constant CLK_PERIOD      : time := 10 ns;
  constant XLEN            : integer := 32;
  constant RESET_VECTOR    : unsigned(XLEN-1 downto 0) := x"00000000";
  constant ADDR_INCR       : unsigned(XLEN-1 downto 0) := to_unsigned(4, XLEN);

  -- Signaux
  signal i_clk       : std_logic := '0';
  signal i_rstn      : std_logic := '1';
  signal i_stall     : std_logic := '0';
  signal i_transfert : std_logic := '0';
  signal i_target    : std_logic_vector(XLEN-1 downto 0) := (others => '0');
  signal o_pc        : std_logic_vector(XLEN-1 downto 0);

  -- Pour les vérifications
  signal pc_expected : unsigned(XLEN-1 downto 0) := RESET_VECTOR;

begin

  -- Instanciation du module riscv_pc
  uut: entity work.riscv_pc
    generic map (
      RESET_VECTOR => to_integer(RESET_VECTOR)
    )
    port map (
      i_clk       => i_clk,
      i_rstn      => i_rstn,
      i_stall     => i_stall,
      i_transfert => i_transfert,
      i_target    => i_target,
      o_pc        => o_pc
    );

  -- Génération de l'horloge
  clk_gen: process
  begin
    while true loop
      i_clk <= '0';
      wait for CLK_PERIOD / 2;
      i_clk <= '1';
      wait for CLK_PERIOD / 2;
    end loop;
  end process;

  -- Processus de test
  stim_proc: process
  begin
    -- Reset
    i_rstn <= '0';
    wait for CLK_PERIOD;
    assert std_logic_vector(pc_expected) = o_pc report "RESET failed!" severity error;
    
    i_rstn <= '1';

    wait for CLK_PERIOD;
	
    pc_expected <= pc_expected + ADDR_INCR;
    wait for 5 ns;
    -- Vérification de l'incrémentation normale
 
    assert std_logic_vector(pc_expected)  = o_pc report "Increment failed!" severity error;

    -- Vérification du stall
    i_stall <= '1';
    wait for CLK_PERIOD;
    assert std_logic_vector(pc_expected) = o_pc report "Stall failed!" severity error;

    -- Vérification du transfert
    i_stall <= '0';
    i_transfert <= '1';
    i_target <= x"00001000";
    wait for CLK_PERIOD;
    pc_expected <= unsigned(i_target);
    wait for CLK_PERIOD;
    assert std_logic_vector(pc_expected) = o_pc report "Transfer failed!" severity error;

    -- Retour à l'incrémentation
    i_transfert <= '0';
    pc_expected <= pc_expected + ADDR_INCR;
    wait for CLK_PERIOD;
    assert std_logic_vector(pc_expected) = o_pc report "Post-transfer increment failed!" severity error;

    -- Fin du test
    wait;
  end process;

end architecture beh;

