library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_riscv_adder is
  generic (
    N : positive := 32
  );
end entity tb_riscv_adder;


architecture test of tb_riscv_adder is

    -- Declare signals to connect to the DUT (Device Under Test)
    signal i_a    : std_logic_vector(N-1 downto 0);
    signal i_b    : std_logic_vector(N-1 downto 0) := (others => '0');
    signal i_sign : std_logic;
    signal i_sub  : std_logic;
    signal o_sum  : std_logic_vector(N downto 0);  -- 4-bit sum + carry bit

    -- Instantiate the DUT
    component riscv_adder is
        port (
            i_a    : in  std_logic_vector(N-1 downto 0);
            i_b    : in  std_logic_vector(N-1 downto 0);
            i_sign : in  std_logic;
            i_sub  : in  std_logic;
            o_sum  : out std_logic_vector(N downto 0)
        );
    end component riscv_adder;


begin

    -- Instantiate the 4-bit adder
    dut: riscv_adder
        port map (
            i_a    => i_a,
            i_b    => i_b,
            i_sign => i_sign,
            i_sub  => i_sub,
            o_sum  => o_sum
        );

    -- Test procedure
    process
    begin
        -- Test Case 1: 3 + 2
        i_a <= "00000000000000000000000001010101";  -- 3 in binary
        i_b <= "00000000000000000000000001101010";  -- 2 in binary
        i_sign <= '0';  -- Addition
        i_sub <= '0';   -- Not used in this case
        wait for 10 ns;
        --assert (o_sum = "00001") report "Test Case 1 Failed!" severity error;  -- Expected output: 5

        -- End simulation
        wait;
    end process;

end architecture test;
