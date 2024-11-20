
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Testbench entity
entity riscv_id_tb is
end entity riscv_id_tb;

architecture beh of riscv_id_tb is
  -- Clock and Reset Signals
  signal i_clk    : std_logic := '0';	
  signal tb_rstn   : std_logic := '0';
  constant PERIOD : time := 20 ns;

  -- Testbench input signals
  signal tb_i_instr    : std_logic_vector(31 downto 0) := (others => '0');
  signal tb_i_wb       : std_logic := '0';
  signal tb_i_rd_addr  : std_logic_vector(4 downto 0) := (others => '0');
  signal tb_i_rd_data  : std_logic_vector(31 downto 0) := (others => '0');
  signal tb_i_flush    : std_logic := '0';
  
  -- Testbench output signals
  signal tb_o_rs1_data : std_logic_vector(31 downto 0);
  signal tb_o_rs2_data : std_logic_vector(31 downto 0);
  signal tb_o_branch   : std_logic;
  signal tb_o_jump     : std_logic;
  signal tb_o_rw       : std_logic;
  signal tb_o_wb_out   : std_logic;
  signal tb_o_arith    : std_logic;
  signal tb_o_sign     : std_logic;
  signal tb_o_src_imm  : std_logic;
  signal tb_o_alu_op   : std_logic_vector(3 downto 0);
  signal tb_o_imm      : std_logic_vector(31 downto 0);

  component riscv_id is
    port (
      i_clk       : in  std_logic;
      i_rstn      : in  std_logic;
      i_instr     : in  std_logic_vector(31 downto 0);
      i_wb        : in  std_logic;
      i_rd_addr   : in  std_logic_vector(4 downto 0);
      i_rd_data   : in  std_logic_vector(31 downto 0);
      i_flush     : in  std_logic;

      o_rs1_data  : out std_logic_vector(31 downto 0);
      o_rs2_data  : out std_logic_vector(31 downto 0);
      o_branch    : out std_logic;
      o_jump      : out std_logic;
      o_rw        : out std_logic;
      o_wb_out    : out std_logic;
      o_arith     : out std_logic;
      o_sign      : out std_logic;
      o_src_imm   : out std_logic;
      o_alu_op    : out std_logic_vector(3 downto 0);
      o_imm       : out std_logic_vector(31 downto 0)
    );
  end component;

begin
	
  -- Connect UUT
  dut: entity work.riscv_id
    port map (
      i_clk       => i_clk,
      i_rstn      => tb_rstn,
      i_instr     => tb_i_instr,
      i_wb        => tb_i_wb,
      i_rd_addr   => tb_i_rd_addr,
      i_rd_data   => tb_i_rd_data,
      i_flush     => tb_i_flush,

      o_rs1_data  => tb_o_rs1_data,
      o_rs2_data  => tb_o_rs2_data,
      o_branch    => tb_o_branch,
      o_jump      => tb_o_jump,
      o_rw        => tb_o_rw,
      o_wb_out    => tb_o_wb_out,
      o_arith     => tb_o_arith,
      o_sign      => tb_o_sign,
      o_src_imm   => tb_o_src_imm,
      o_alu_op    => tb_o_alu_op,
      o_imm       => tb_o_imm
    );

  -- Clock Generation
  i_clk <= not i_clk after PERIOD / 2;

  -- Stimulus Process with Assertions
  process
  begin
    -- Reset the system
    --tb_rstn <= '1';
    --wait for 20 ns;
    --tb_rstn <= '0';

--    -- Test Case 1: No operation (NOP)
--    tb_i_instr <= x"00000000";  -- Example NOP instruction
--    wait for PERIOD;
--
--    assert tb_o_branch = '0' report "Branch flag incorrect for NOP" severity error;
--    assert tb_o_jump = '0' report "Jump flag incorrect for NOP" severity error;
--    assert tb_o_rw = '0' report "RW signal incorrect for NOP" severity error;
--    assert tb_o_wb_out = '0' report "WB out signal incorrect for NOP" severity error;

    -- Test Case 2: Example Branch Instruction
    tb_i_instr <= "00000000000000000000000001100011";  -- Example BEQ instruction (adjust based on your ISA)
    wait for PERIOD;

    assert tb_o_branch = '1' report "Branch flag incorrect for BEQ" severity error;
    assert tb_o_rw = '0' report "RW signal incorrect for BEQ" severity error;

    -- Test Case 3: Example Arithmetic Instruction
    tb_i_instr <= x"00000033";  -- Example ADD instruction
    wait for PERIOD;

    assert tb_o_arith = '1' report "Arithmetic flag incorrect for ADD" severity error;
    assert tb_o_src_imm = '0' report "Src Imm flag incorrect for ADD" severity error;

    -- Test Case 4: Example Load Instruction
    tb_i_instr <= x"00002003";  -- Example LW instruction
    wait for PERIOD;

    assert tb_o_src_imm = '1' report "Src Imm flag incorrect for LW" severity error;
    assert tb_o_rw = '1' report "RW signal incorrect for LW" severity error;

    -- Add more test cases as needed...

    -- Stop simulation
    wait;
  end process;

end architecture beh;
