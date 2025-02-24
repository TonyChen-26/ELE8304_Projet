library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_write_back is
end tb_write_back;

architecture behavioral of tb_write_back is


  -- Signals
  signal i_rw         : std_logic;
  signal i_wb         : std_logic;
  signal i_load_data  : std_logic_vector(31 downto 0);
  signal i_alu_result : std_logic_vector(31 downto 0);
  signal i_rd_addr    : std_logic_vector(4 downto 0);

  signal o_rd_data    : std_logic_vector(31 downto 0);
  signal o_rw         : std_logic;
  signal o_wb         : std_logic;
  signal o_rd_addr    : std_logic_vector(4 downto 0);


  -- Component Declaration for the Unit Under Test (UUT)
  component write_back is
    port (
      i_rw         : in  std_logic;
      i_wb         : in  std_logic;
      i_load_data  : in  std_logic_vector(31 downto 0);
      i_alu_result : in  std_logic_vector(31 downto 0);
      i_rd_addr    : in  std_logic_vector(4 downto 0);

      o_rd_data    : out std_logic_vector(31 downto 0);
      o_rw         : out std_logic;
      o_wb         : out std_logic;
      o_rd_addr    : out std_logic_vector(4 downto 0)
    );
  end component;

begin
  -- Instantiate the Unit Under Test (UUT)
  uut: write_back
    port map (
      i_rw         => i_rw,
      i_wb         => i_wb,
      i_load_data  => i_load_data,
      i_alu_result => i_alu_result,
      i_rd_addr    => i_rd_addr,
      o_rd_data    => o_rd_data,
      o_rw         => o_rw,
      o_wb         => o_wb,
      o_rd_addr    => o_rd_addr
    );

  -- Stimulus Process
  process
  begin
    i_rw <= '0';
    i_wb <= '0';
    i_load_data <= (others => '0');
    i_alu_result <= (others => '0');
    i_rd_addr <= (others => '0');
    wait for 10 ns;

    -- Test 1: Write-Back disabled
    i_wb <= '0';
    i_rw <= '0';
    i_load_data <= x"00000001";
    i_alu_result <= x"00000002";
    i_rd_addr <= "00001";
    wait for 10 ns;

    -- Test 2: Write-Back enabled, ALU result selected
    i_wb <= '1';
    i_rw <= '0';
    wait for 10 ns;

    -- Test 3: Write-Back enabled, Memory data selected
    i_rw <= '1';
    wait for 10 ns;

    -- Test 4: Change register address
    i_rd_addr <= "00010";
    wait for 10 ns;

    -- Stop simulation
    wait;
  end process;
end behavioral;
