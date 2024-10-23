library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;

entity tb_riscv_alu is
end entity tb_riscv_alu;

architecture beh of tb_riscv_alu is

  signal i_arith   : std_logic;
  signal i_sign    : std_logic;
  signal i_opcode  : std_logic_vector(ALUOP_WIDTH-1 downto 0);
  signal i_shamt   : std_logic_vector(SHAMT_WIDTH-1 downto 0);
  signal i_src1    : std_logic_vector(XLEN-1 downto 0);
  signal i_src2    : std_logic_vector(XLEN-1 downto 0);
  signal o_res     : std_logic_vector(XLEN-1 downto 0);


  signal clk       : std_logic := '0';
  signal rst       : std_logic := '0';

begin

  uut: entity work.riscv_alu
    port map(
      i_arith  => i_arith,
      i_sign   => i_sign,
      i_opcode => i_opcode,
      i_shamt  => i_shamt,
      i_src1   => i_src1,
      i_src2   => i_src2,
      o_res    => o_res
    );


  clk_process : process
  begin
    clk <= '0';
    wait for 10 ns;
    clk <= '1';
    wait for 10 ns;
  end process;


  stim_proc: process
  begin
     --Test 1:  addition
    i_arith  <= '0';
    i_sign   <= '0';
    i_opcode <= ALUOP_ADD;
    i_shamt  <= (others => '0');
    i_src1   <= std_logic_vector(to_unsigned(10, XLEN));
    i_src2   <= std_logic_vector(to_unsigned(5, XLEN));

    wait for 20 ns;
    assert (o_res = "00000000000000000000000000001111") report "Test Case 1 Failed!" severity error; 

    -- Test 2:  subtraction
    i_arith  <= '1'; -- Subtraction
    i_opcode <= ALUOP_ADD;
    i_src1   <= std_logic_vector(to_unsigned(15, XLEN));
    i_src2   <= std_logic_vector(to_unsigned(5, XLEN));

    wait for 20 ns;
    assert (o_res = "00000000000000000000000000001010") report "Test Case 2 Failed!" severity error; 

     --Test 3:  AND
    i_arith  <= '0';
    i_opcode <= ALUOP_AND;
    i_src1   <= std_logic_vector(to_unsigned(15, XLEN));
    i_src2   <= std_logic_vector(to_unsigned(5, XLEN));

    wait for 20 ns;
    assert (o_res = "00000000000000000000000000000101") report "Test Case 3 Failed!" severity error; 

    -- Test 4: Shift left
    i_arith  <= '0';
    i_opcode <= ALUOP_SL;
    i_shamt  <= std_logic_vector(to_unsigned(2, SHAMT_WIDTH));
    i_src1   <= std_logic_vector(to_unsigned(4, XLEN));
    
    wait for 20 ns;
    assert (o_res = "00000000000000000000000000010000") report "Test Case 4 Failed!" severity error; 
    -- End of test
    wait;
  end process;
end architecture beh;