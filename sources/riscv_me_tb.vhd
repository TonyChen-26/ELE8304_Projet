
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_memory is
end entity;

architecture Behavioral of tb_memory is

  -- Component Declaration
  component memory
    port (
        i_clk           : in std_logic;
        i_rstn          : in std_logic;  -- Added reset signal
        i_store_data    : in std_logic_vector(31 downto 0);
        i_rw            : in std_logic;
        i_we            : in std_logic;
        i_alu_result    : in std_logic_vector(31 downto 0);
        i_wb            : in std_logic;
        i_rd_addr       : in std_logic_vector(4 downto 0);
        i_dmem_read     : in std_logic_vector(31 downto 0);  -- New input for data read from memory
        
        -- Outputs
        o_rw            : out std_logic;
        o_dmem_en       : out std_logic;
        o_dmem_we       : out std_logic;
        o_dmem_addr     : out std_logic_vector(8 downto 0);
        o_dmem_write    : out std_logic_vector(31 downto 0);
        o_load_data     : out std_logic_vector(31 downto 0);
        o_alu_result    : out std_logic_vector(31 downto 0);
        o_wb            : out std_logic;
        o_rd_addr       : out std_logic_vector(4 downto 0)
    );
  end component;

  -- Clock signal
  signal clk           : std_logic := '0';
  signal rst           : std_logic := '0';

  -- Input signals
  signal store_data    : std_logic_vector(31 downto 0) := (others => '0');
  signal rw            : std_logic := '0';
  signal we            : std_logic := '0';
  signal alu_result    : std_logic_vector(31 downto 0) := (others => '0');
  signal wb            : std_logic := '0';
  signal rd_addr       : std_logic_vector(4 downto 0) := (others => '0');
  signal dmem_read     : std_logic_vector(31 downto 0);

  -- Output signals
  signal tb_o_rw       : std_logic; 
  signal tb_o_dmem_en  : std_logic;
  signal tb_o_dmem_we  : std_logic;
  signal tb_o_dmem_addr : std_logic_vector(8 downto 0);
  signal tb_o_dmem_write : std_logic_vector(31 downto 0);
  signal load_data     : std_logic_vector(31 downto 0);
  signal alu_result_out : std_logic_vector(31 downto 0);
  signal wb_out        : std_logic;
  signal rd_addr_out   : std_logic_vector(4 downto 0);

  constant CLK_PERIOD  : time := 10 ns;

begin

  -- Instantiate the DUT (Device Under Test)
  uut: memory
    port map (
      i_clk        => clk,
      i_rstn       => rst,
      i_store_data => store_data,
      i_rw         => rw,
      i_we         => we,
      i_alu_result => alu_result,
      i_wb         => wb,
      i_rd_addr    => rd_addr,
      i_dmem_read => dmem_read,

      o_rw      =>    tb_o_rw,  
      o_dmem_en   => tb_o_dmem_en,   
      o_dmem_we  => tb_o_dmem_we,      
      o_dmem_addr => tb_o_dmem_addr,    
      o_dmem_write => tb_o_dmem_write,    
      o_load_data  => load_data,
      o_alu_result => alu_result_out,
      o_wb         => wb_out,
      o_rd_addr    => rd_addr_out
    );

  -- Clock generation process
  clk_process : process
  begin
    clk <= '0';
    wait for CLK_PERIOD / 2;
    clk <= '1';
    wait for CLK_PERIOD / 2;
  end process;

  -- Stimulus process
  stimulus : process
  begin
    -- Test Case 1: Write to Memory
    rw <= '1';  -- Write mode
    we <= '1';  -- Enable write
    wb <= '1';  
    alu_result <= x"00000004";  -- Address in memory
    store_data <= "10101010101010101010101010101010";  -- Data to store
    rd_addr <= "00010";  -- Register address
    wait for CLK_PERIOD;

    -- Check results after write
    assert alu_result_out = alu_result report "ALU Result Mismatch on Write" severity error;
    assert wb_out = wb report "Write-Back Signal Mismatch on Write" severity error;
    assert rd_addr_out = rd_addr report "Register Address Mismatch on Write" severity error;

    -- Test Case 2: Read from Memory
    rw <= '0';  -- Read mode
    we <= '0';  -- Disable write
    alu_result <= x"00000004";  -- Same address
    wait for CLK_PERIOD;

    -- Check results after read
    assert load_data(31 downto 0) = store_data report "Memory Read Data Mismatch" severity error;
    assert alu_result_out = alu_result report "ALU Result Mismatch on Read" severity error;
    assert wb_out = wb report "Write-Back Signal Mismatch on Read" severity error;
    assert rd_addr_out = rd_addr report "Register Address Mismatch on Read" severity error;

    -- Test Case 3: Idle State (No Operation)
    rw <= '0';  -- No read/write
    we <= '0';
    alu_result <= x"00000008";  -- Unused address
    wait for CLK_PERIOD;

    -- Check results after idle
    assert load_data = "00000000000000000000000000000000" report "Unexpected Memory Operation in Idle" severity error;

    -- Test Case 4: Write to Boundary Address
    rw <= '1';  -- Write mode
    we <= '1';  -- Enable write
    alu_result <= x"00000000";  -- Boundary address (lowest address)
    store_data <= "11110000111100001111000011110000";  -- Data to store
    wait for CLK_PERIOD;

    alu_result <= x"FFFFFFFF";  -- Boundary address (highest address)
    store_data <= "00001111000011110000111100001111";  -- Another data value
    wait for CLK_PERIOD;

    -- Test Case 5: Write and Read from Different Addresses
    rw <= '1';  -- Write mode
    alu_result <= x"00000010";  -- Address 1
    store_data <= "01010101010101010101010101010101";
    wait for CLK_PERIOD;

    rw <= '0';  -- Read mode
    alu_result <= x"00000014";  -- Address 2 (different)
    wait for CLK_PERIOD;

    -- Test Case 6: Reset Test
    rst <= '1';  -- Assert reset
    wait for CLK_PERIOD;
    rst <= '0';  -- Deassert reset
    wait for CLK_PERIOD;

    -- Test Case 7: Multiple Writes to Same Address
    rw <= '1';  -- Write mode
    alu_result <= x"00000010";  -- Same address
    store_data <= "11111111000000001111000011110000";  -- First data value
    wait for CLK_PERIOD;

    store_data <= "00001111000011110000111100001111";  -- Second data value
    wait for CLK_PERIOD;

    -- Test Case 8: Invalid Read with No Write Operation
    rw <= '0';  -- Read mode
    alu_result <= x"00000010";  -- Address without write
    wait for CLK_PERIOD;

    -- Test Case 9: Write with No Enable
    rw <= '1';  -- Write mode
    we <= '0';  -- Disable write
    alu_result <= x"00000020";  -- Address
    store_data <= "00110011001100110011001100110011";  -- Data to write
    wait for CLK_PERIOD;

    -- Test Case 10: Simultaneous Read and Write
    rw <= '1';  -- Write mode
    we <= '1';  -- Enable write
    alu_result <= x"00000030";  -- Address
    store_data <= "01010101010101010101010101010101";  -- Data
    rw <= '0';  -- Read mode
    wait for CLK_PERIOD;

    -- Test completed
    report "All test cases passed!" severity note;
    wait;
  end process;

end Behavioral;
