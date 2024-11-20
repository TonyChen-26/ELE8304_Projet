
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_riscv_predecode is
end tb_riscv_predecode;

architecture behavior of tb_riscv_predecode is
    -- Component declaration for the tested module
    component riscv_predecode is
        port (
            i_instr      : in std_logic_vector(31 downto 0);
            o_rs1_addr   : out std_logic_vector(4 downto 0);
            o_rs2_addr   : out std_logic_vector(4 downto 0);
            o_opcode     : out std_logic_vector(6 downto 0);
            o_funct3     : out std_logic_vector(2 downto 0);
            o_funct7     : out std_logic_vector(6 downto 0)
           -- o_rd         : out std_logic_vector(4 downto 0)
        );
    end component riscv_predecode;

    -- Signals for the inputs and outputs of the tested module
    signal i_instr      : std_logic_vector(31 downto 0) := (others => '0');
    signal o_rs1_addr   : std_logic_vector(4 downto 0);
    signal o_rs2_addr   : std_logic_vector(4 downto 0);
    signal o_opcode     : std_logic_vector(6 downto 0);
    signal o_funct3     : std_logic_vector(2 downto 0);
    signal o_funct7     : std_logic_vector(6 downto 0);
    --signal o_rd         : std_logic_vector(4 downto 0);

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: riscv_predecode
        port map (
            i_instr      => i_instr,
            o_rs1_addr   => o_rs1_addr,
            o_rs2_addr   => o_rs2_addr,
            o_opcode     => o_opcode,
            o_funct3     => o_funct3,
            o_funct7     => o_funct7
           -- o_rd         => o_rd
        );

    -- Test process
    process
    begin
        -- Test case 1: R-Type instruction (ADD x5, x2, x3)
        i_instr <= "00000000110000100000000110110011"; -- opcode: 0110011 (R-Type)
        wait for 10 ns;
        assert o_opcode = "0110011" report "Test case 1 failed: opcode mismatch" severity error;
        assert o_rs1_addr = "00100" report "Test case 1 failed: rs1 mismatch" severity error;
        assert o_rs2_addr = "01100" report "Test case 1 failed: rs2 mismatch" severity error;
        --assert o_rd = "00011" report "Test case 1 failed: rd mismatch" severity error;
	assert o_funct3 = "000" report "Test case 1 failed: fonct3 mismatch" severity error;
	assert o_funct7 = "0000000" report "Test case 1 failed: fonct7 mismatch" severity error;

        -- Test case 2: I-Type instruction (ADDI x5, x2, 10)
        i_instr <= "00000000010100010000001010010011"; -- opcode: 0010011 (I-Type)
        wait for 10 ns;
        assert o_opcode = "0010011" report "Test case 2 failed: opcode mismatch" severity error;
	--assert o_rd = "00101" report "Test case 2 failed: rd mismatch" severity error;
	assert o_funct3 = "000" report "Test case 2 failed: fonct3 mismatch" severity error;
        assert o_rs1_addr = "00010" report "Test case 2 failed: rs1 mismatch" severity error;
	assert o_rs2_addr = "00000" report "Test case 2 failed: rs2 mismatch" severity error;
        assert o_funct7 = "0000000" report "Test case 2 failed: rd mismatch" severity error;

        -- Test case 3: S-Type instruction (SW x5, 10(x2))
        i_instr <= "00000000101000010010000100100011"; -- opcode: 0100011 (S-Type)
        wait for 10 ns;
        assert o_opcode = "0100011" report "Test case 3 failed: opcode mismatch" severity error;
	--assert o_rd = "00000" report "Test case 3 failed: rd mismatch" severity error;
	assert o_funct3 = "010" report "Test case 3 failed: fonct3 mismatch" severity error;
        assert o_rs1_addr = "00010" report "Test case 3 failed: rs1 mismatch" severity error;
        assert o_rs2_addr = "01010" report "Test case 3 failed: rs2 mismatch" severity error;
	assert o_funct7 = "0000000" report "Test case 3 failed: rd mismatch" severity error;


        -- Test case 4: J-Type instruction (JAL x5, offset)
        i_instr <= "00000000000100000000010111101111"; -- opcode: 1101111 (J-Type)
        wait for 10 ns;
        assert o_opcode = "1101111" report "Test case 4 failed: opcode mismatch" severity error;
	--assert o_rd = "01011" report "Test case 4 failed: rd mismatch" severity error;
	assert o_funct3 = "000" report "Test case 4 failed: fonct3 mismatch" severity error;
        assert o_rs1_addr = "00000" report "Test case 4 failed: rs1 mismatch" severity error;
        assert o_rs2_addr = "00000" report "Test case 4 failed: rs2 mismatch" severity error;
	assert o_funct7 = "0000000" report "Test case 4 failed: rd mismatch" severity error;

        -- Test case 5: Default (unknown instruction)
        i_instr <= (others => '0'); -- Undefined opcode
        wait for 10 ns;
        assert o_opcode = "0000000" report "Test case 5 failed: opcode mismatch" severity error;
       -- assert o_rd = "00000" report "Test case 5 failed: rd mismatch" severity error;
--
        -- End simulation
        wait;
    end process;

end behavior;
