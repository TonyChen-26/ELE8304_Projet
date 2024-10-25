library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FETCH_TB is
end FETCH_TB;

architecture Behavioral of FETCH_TB is
    -- Testbench signals
    signal clk          : std_logic := '0';
    signal i_flush      : std_logic := '0';
    signal i_mem        : std_logic_vector(31 downto 0) := (others => '0');
    signal i_stall      : std_logic := '0';
    signal i_transfert  : std_logic := '0';
    signal i_target     : std_logic_vector(31 downto 0) := (others => '0');
    signal o_pc         : std_logic_vector(31 downto 0);
    signal o_instruction: std_logic_vector(31 downto 0);

    -- Instantiation of the FETCH component
    component FETCH
        Port (
            clk            : in  std_logic;
            i_flush        : in  std_logic;
            i_mem          : in  std_logic_vector(31 downto 0);
            i_stall        : in  std_logic;
            i_transfert    : in  std_logic;
            i_target       : in  std_logic_vector(31 downto 0);
            o_pc           : out std_logic_vector(31 downto 0);
            o_instruction  : out std_logic_vector(31 downto 0)
        );
    end component;

begin
    -- Instance of the FETCH module
    UUT: FETCH
        port map (
            clk           => clk,
            i_flush       => i_flush,
            i_mem         => i_mem,
            i_stall       => i_stall,
            i_transfert   => i_transfert,
            i_target      => i_target,
            o_pc          => o_pc,
            o_instruction => o_instruction
        );

    -- Clock process generation
    clk_process: process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize and wait for reset
        wait for 20 ns;

        -- Test case 1: Normal fetch
        i_mem <= x"AAAAAAAA";        -- Instruction to be fetched
        i_stall <= '0';
        i_transfert <= '1';          -- Transfer enabled to fetch new instruction
        wait for 20 ns;
        assert o_instruction = x"AAAAAAAA" report "Error: Normal fetch failed" severity error;

        -- Test case 2: Stall active (i_stall = '1')
        i_mem <= x"BBBBBBBB";        -- New instruction should not be fetched
        i_stall <= '1';              -- Stall is active
        wait for 20 ns;
        assert o_instruction = x"AAAAAAAA" report "Error: Stall handling failed" severity error;

        -- Test case 3: Fetch with i_flush (reset PC to zero)
        i_flush <= '1';              -- Activate flush (simulate branch/jump)
        wait for 20 ns;
        i_flush <= '0';              -- Deactivate flush
       -- assert o_pc = (others => '0') report "Error: Flush handling failed, PC not reset" severity error;

        -- Test case 4: Fetch with i_target (branch/jump to target)
        i_mem <= x"CCCCCCCC";
        i_stall <= '0';              -- No stall
        i_target <= x"00000010";     -- Set branch target
        i_flush <= '1';              -- Trigger flush to jump to target
        wait for 20 ns;
        i_flush <= '0';              -- Deactivate flush
        wait for 20 ns;
        assert o_instruction = x"CCCCCCCC" report "Error: Fetch after branch/jump failed" severity error;

        -- Finish simulation
        wait;
    end process;

end Behavioral;
