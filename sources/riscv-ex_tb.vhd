library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


library work;
use work.riscv_pkg.all;


entity tb_execute is
-- Testbench doesn't have any ports
end tb_execute;

architecture Behavioral of tb_execute is

    -- Component Declaration
    component execute is
        Port (
		i_clk : in std_logic;
            -- Inputs
            i_alu_op      : in  STD_LOGIC_VECTOR(2 downto 0);
            i_rs1_data    : in  STD_LOGIC_VECTOR(31 downto 0);
            i_rs2_data    : in  STD_LOGIC_VECTOR(31 downto 0);
            i_imm         : in  STD_LOGIC_VECTOR(31 downto 0);
            i_pc          : in  STD_LOGIC_VECTOR(31 downto 0);
            i_src_imm     : in  STD_LOGIC;
            i_branch      : in  STD_LOGIC;
            i_jump        : in  STD_LOGIC;
    	    i_arith       : in std_logic;	
	    i_sign        : in std_logic;



            -- Outputs
            o_pc_transfer : out STD_LOGIC_VECTOR(31 downto 0);
            o_alu_result  : out STD_LOGIC_VECTOR(31 downto 0);
            o_store_data  : out STD_LOGIC_VECTOR(31 downto 0);
            o_pc_target   : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    -- Testbench Signals
    signal tb_alu_op      : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal tb_rs1_data    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal tb_rs2_data    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal tb_imm         : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal tb_pc          : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal tb_src_imm     : STD_LOGIC := '0';
    signal tb_branch      : STD_LOGIC := '0';
    signal tb_jump        : STD_LOGIC := '0';
    signal tb_arith        : STD_LOGIC := '0';
    signal tb_sign         : STD_LOGIC := '0';

    signal tb_pc_transfer : STD_LOGIC_VECTOR(31 downto 0);
    signal tb_alu_result  : STD_LOGIC_VECTOR(31 downto 0);
    signal tb_store_data  : STD_LOGIC_VECTOR(31 downto 0);
    signal tb_pc_target   : STD_LOGIC_VECTOR(31 downto 0);
    signal i_clk       : std_logic := '0';
   constant clk_period : time := 10 ns;
begin
    -- Instantiate the `execute` Module
    DUT : execute
        port map (
		i_clk => i_clk,
            i_alu_op      => tb_alu_op,
            i_rs1_data    => tb_rs1_data,
            i_rs2_data    => tb_rs2_data,
            i_imm         => tb_imm,
            i_pc          => tb_pc,
            i_src_imm     => tb_src_imm,
            i_branch      => tb_branch,
            i_jump        => tb_jump,
	    i_arith       => tb_arith,
            i_sign        => tb_sign,


            o_pc_transfer => tb_pc_transfer,
            o_alu_result  => tb_alu_result,
            o_store_data  => tb_store_data,
            o_pc_target   => tb_pc_target
        );

    -- Test Process

    clk_process : process
    begin
        while true loop
            i_clk <= '0';
            wait for clk_period / 2;
            i_clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;


    process
    begin
        -- Test Case 1: Simple Addition (ALU)
        tb_alu_op <= ALUOP_ADD; -- ALU Add Operation
        tb_rs1_data <= "00000000000000000000000000001100"; -- rs1 = 3
        tb_rs2_data <= "00000000000000000000000000000010"; -- rs2 = 2
        tb_imm <= X"00000001"; -- Immediate = 8
        tb_src_imm <= '0'; -- Use rs2_data
	tb_pc <= X"00000004";
        tb_branch <= '0';
        tb_jump <= '0';
        wait for 20 ns;

        assert tb_alu_result = "00000000000000000000000000001110" -- rs1 + rs2 = 16 + 4 = 20
        report "Test Case 1 failed: Incorrect ALU addition result" severity error;

        assert tb_pc_transfer =X"00000008"  -- No branch/jump, so pc_transfer = alu_result
        report "Test Case 1 failed: Incorrect PC transfer" severity error;

        -- Test Case 2: Use Immediate as Operand
        tb_src_imm <= '1'; -- Use immediate instead of rs2_data
        wait for 20 ns;

        assert tb_alu_result = X"000000D" -- rs1 + imm = 16 + 8 = 24
        report "Test Case 2 failed: Incorrect ALU result with immediate" severity error;

        -- Test Case 3: Branch with PC Target
	tb_pc <= X"00000007";
        tb_imm <= X"00000005"; -- Immediate = 5
        tb_branch <= '1'; -- Branch condition
        tb_jump <= '0';
        tb_rs1_data <= X"00000010"; -- rs1 = 16
       
        wait for clk_period;

        assert tb_pc_transfer = X"0000000B" -- rs1 + imm 
        report "Test Case 3 failed: Incorrect PC transfer for branch" severity error;

        assert tb_pc_target = X"0000000C" -- i_pc + i_mm
        report "Test Case 3 failed: Incorrect PC target for branch" severity error;

        -- Test Case 4: Jump Operation
        tb_branch <= '0';
        tb_jump <= '1'; -- Jump condition
        tb_rs1_data <= X"00000020"; -- rs1 = 32
        tb_imm <= X"00000010"; -- Offset = 16
        wait for 20 ns;

        assert tb_pc_transfer = X"00000030" -- rs1 + imm = 32 + 16 = 48
        report "Test Case 4 failed: Incorrect PC transfer for jump" severity error;

        -- Test Case 5: ALU Subtraction	
	tb_arith <= '1';
        tb_src_imm <= '1'; -- Use imm
   	tb_jump	 <= '0'; -- Jump condition
	tb_imm <= X"00000003";
        tb_alu_op <= "000"; -- ALU Subtraction
	tb_rs1_data <= X"00000005"; -- rs2 = 3
        tb_rs2_data <= X"00000000"; -- rs2 = 3

        wait for 20 ns;

        assert tb_alu_result = X"00000002" -- rs1 - rs2 = 16 - 3 = 13
        report "Test Case 5 failed: Incorrect ALU subtraction result" severity error;



        -- Test Case 3: Logical AND
        tb_src_imm <= '0';
        tb_alu_op <= ALUOP_AND; -- AND operation
        tb_rs1_data <= X"FFFFFFFF";
        tb_rs2_data <= X"0F0F0F0F";
        tb_arith <= '0';
        wait for clk_period;

        assert tb_alu_result = "1111000011110000111100001111" report "Test Case 3 Failed: Incorrect AND result" severity error;

        -- Test Case 4: Logical OR
        tb_alu_op <= ALUOP_OR; -- OR operation
        tb_rs1_data <= X"000000F0";
        tb_rs2_data <= X"0000000F";
        wait for clk_period;

        assert tb_alu_result = X"000000FF" report "Test Case 4 Failed: Incorrect OR result" severity error;




        -- Finish Simulation
        report "All tests passed successfully!" severity note;
        wait;
    end process;

end Behavioral;

