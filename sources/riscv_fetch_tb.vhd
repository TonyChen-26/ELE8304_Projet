library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.riscv_pkg.all;

entity FETCH_TB is
end FETCH_TB;

architecture Behavioral of FETCH_TB is
    -- Testbench signals
    signal i_clk        : std_logic := '0';
    signal i_flush      : std_logic := '0';
    signal i_rst	: std_logic := '1';
    signal i_stall      : std_logic := '0';
    signal i_transfert  : std_logic := '0';
    signal i_target     : std_logic_vector(31 downto 0) := (others => '0');
    signal i_mem        : std_logic_vector(31 downto 0) := (others => '0');

    signal o_instruction: std_logic_vector(31 downto 0);
    signal o_pc         : std_logic_vector(31 downto 0);
    signal o_imem_addr : std_logic_vector(8 downto 0);  -- Address to memory (9-bit address)
    signal o_imem_en   : std_logic;                     -- Memory enable signal

constant PERIOD   : time := 20 ns;
    -- Instantiation of the FETCH component
    component FETCH
        Port (       
	i_clk       : in  std_logic;
	i_rst 	    : in  std_logic;
        i_flush     : in  std_logic;
        i_stall     : in  std_logic;
        i_transfert : in  std_logic;
        i_target    : in  std_logic_vector(31 downto 0);
        i_mem : in  std_logic_vector(31 downto 0);  -- Instruction from memory

        -- Outputs
        o_instruction     : out std_logic_vector(31 downto 0);
        o_pc        : out std_logic_vector(31 downto 0);
        o_imem_addr : out std_logic_vector(8 downto 0);  -- Address to memory (9-bit address)
        o_imem_en   : out std_logic                     -- Memory enable signal
        );
    end component;
	

	 type memory_type is array (0 to 1023) of std_logic_vector(31 downto 0);
    signal test : memory_type := (
        0 => X"000074B3", 1 => X"FFFFF2B7", 2 => X"7FF06313", 3 => X"FFF00393", 4 => X"00204E13", -- Add more here
        others => (others => '0') -- Initialize rest of memory to zero (if needed)
    );

begin
    -- Instance of the FETCH module
    DUT: FETCH
        port map (
            i_clk         => i_clk,
	    i_rst	  => i_rst,
            i_flush       => i_flush,
            i_mem         => i_mem,
            i_stall       => i_stall,
            i_transfert   => i_transfert,
            i_target      => i_target,
            o_pc          => o_pc,
            o_instruction => o_instruction,
	    o_imem_en => o_imem_en,
	    o_imem_addr => o_imem_addr
        );

    -- Clock process generation

     i_clk <= not i_clk after PERIOD/2 ;


    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize and wait for reset
  

         --Test case 1: Normal fetch
	i_transfert <= '1';
	i_target <= x"00000000";
	wait for 20 ns;
        i_mem <= test(1);--x"AAAAAAAA";        -- Instruction to be fetched
        i_stall <= '0';
        i_transfert <= '0';          -- Transfer enabled to fetch new instruction
        wait for 20 ns;
        assert i_transfert = '1' report "Error: i_transfert should be '1'" severity error;
        assert i_stall = '0' report "Error: i_stall should be '0'" severity error;
        assert o_instruction = x"AAAAAAAA" report "Error: Normal fetch failed" severity error;

        -- Test case 2: Stall active (i_stall = '1')
        i_mem <= x"BBBBBBBB";        -- New instruction should not be fetched
        --i_stall <= '0';              -- Stall is active
        wait for 20 ns;
        assert o_instruction = x"AAAAAAAA" report "Error: Stall handling failed" severity error;

        -- Test case 3: Fetch with i_flush (reset PC to zero)
        i_flush <= '0';              -- Activate flush (simulate branch/jump)
        wait for 20 ns;
        assert o_pc = "00000000000000000000000000000000" report "Error: Flush handling failed, PC not reset" severity error;
        i_flush <= '0';              -- Deactivate flush
	i_stall <= '0';
        wait for 20 ns;

        -- Test case 4: Fetch with i_target (branch/jump to target)
        i_mem <= x"CCCCCCCC";
        i_stall <= '0';              -- No stall
        i_target <= x"00000010";     -- Set branch target
        i_flush <= '0';              -- Trigger flush to jump to target
        wait for 20 ns;
        assert o_instruction = x"00000000" report "Error: PC not updated to target address" severity error;
        i_flush <= '0';              -- Deactivate flush
        wait for 20 ns;
        assert o_instruction = x"CCCCCCCC" report "Error: Fetch after branch/jump failed" severity error;

        -- Test case 5: Multiple instructions in sequence
        -- Fetch instruction 1
        i_mem <= x"11111111";        -- Instruction 1 to be fetched
        i_transfert <= '0';          -- Transfer enabled
        wait for 20 ns;
        assert o_instruction = x"11111111" report "Error: First instruction fetch failed" severity error;

        -- Fetch instruction 2 (next instruction)
        i_mem <= x"22222222";        -- Instruction 2 to be fetched
        wait for 20 ns;
        assert o_instruction = x"22222222" report "Error: Second instruction fetch failed" severity error;

        -- Test case 6: Instruction Fetch after stall
        i_stall <= '0';              -- Set stall
        i_mem <= x"33333333";        -- Instruction to be fetched
        wait for 20 ns;
        assert o_instruction = x"22222222" report "Error: Instruction fetch not stalled" severity error;
	assert i_clk = '1' report "test" severity error;
        -- Test case 7: Reset PC after flush
        i_mem <= x"44444444";        -- Instruction to be fetched
        i_flush <= '1';              -- Flush signal, reset PC
        wait for 20 ns;
        assert o_instruction = "00000000000000000000000000000000" report "Test 7 Error: PC was not reset after flush" severity error;
        i_flush <= '0';              -- Deactivate flush
        wait for 20 ns;

        -- Test case 8: PC rollover condition
        i_mem <= x"55555555";        -- Instruction to be fetched
	i_stall <= '0';
        i_target <= x"FFFFFFFF";     -- Target to simulate a potential PC rollover
        i_flush <= '0';              -- Trigger flush
        wait for 20 ns;
        assert o_pc = x"FFFFFFFF" report "Error: Test 8 PC rollover not handled correctly" severity error;

        -- Test case 9: Fetch with invalid instruction
        i_mem <= x"DEADBEEF";        -- Invalid instruction pattern for testing
        i_transfert <= '1';          -- Transfer enabled
        wait for 20 ns;
        assert o_instruction = x"DEADBEEF" report "Error: Test 9 Invalid instruction fetch failed" severity error;

        -- Finish simulation
--Yuba la legende, Amar la legende était ici tabarnak
        wait;
    end process;

end Behavioral;
