
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
    signal o_sum  : std_logic_vector(N downto 0);  -- 32-bit sum + carry bit

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

    -- Instantiate the DUT
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
--        -- Test Case 1: 3 + 2 (unsigned addition)
--        i_sign <= '0';  -- Unsigned
--        i_sub <= '0';
--        i_a <= "00000000000000000000000000000011";  -- 3 in binary
--        i_b <= "00000000000000000000000000000010";  -- 2 in binary
--        wait for 10 ns;
--        assert (o_sum = "000000000000000000000000000000101") report "Test Case 1 Failed!" severity error;  -- Expected output: 5
--
        -- Test Case 2: -3 + 2 (signed addition)
        i_sign <= '1';  -- Signed
        i_sub <= '0';
        i_a <= "10000000000000000000000000000011";  -- -3 in binary
        i_b <= "00010000000000000000000000000010";  -- 2 in binary
        wait for 10 ns;
        assert (o_sum = "111111111111111111111111111111111") report "Test Case 2 Failed!" severity error;  -- Expected output: -1

----        -- Test Case 3: 3 - 2 (unsigned subtraction)
--        i_sign <= '0';  -- Unsigned
--        i_sub <= '1';
--        i_a <= "00000000000000000000000000000011";  -- 3 in binary
--        i_b <= "00000000000000000000000000000010";  -- 2 in binary
--        wait for 10 ns;
--        assert (o_sum = "000000000000000000000000000000001") report "Test Case 3 Failed!" severity error;  -- Expected output: 1
----
--        -- Test Case 4: -3 - 2 (signed subtraction)
--        i_sign <= '1';  -- Signed
--        i_sub <= '1';
--        i_a <= "11111111111111111111111111111101";  -- -3 in binary
--        i_b <= "00000000000000000000000000000010";  -- 2 in binary
--        wait for 10 ns;
--        assert (o_sum = "111111111111111111111111111111011") report "Test Case 4 Failed!" severity error;  -- Expected output: -5
--
--        -- Test Case 5: 2 + 2 (unsigned addition)
--        i_sign <= '0';  -- Unsigned
--        i_sub <= '0';
--        i_a <= "00000000000000000000000000000010";  -- 2 in binary
--        i_b <= "00000000000000000000000000000010";  -- 2 in binary
--        wait for 10 ns;
--        assert (o_sum = "000000000000000000000000000000100") report "Test Case 5 Failed!" severity error;  -- Expected output: 4
--
--        -- Test Case 6: -2 + -2 (signed addition)
--        i_sign <= '1';  -- Signed
--        i_sub <= '0';
--        i_a <= "11111111111111111111111111111110";  -- -2 in binary
--        i_b <= "11111111111111111111111111111110";  -- -2 in binary
--        wait for 10 ns;
--        assert (o_sum = "111111111111111111111111111111100") report "Test Case 6 Failed!" severity error;  -- Expected output: -4
--
        -- End simulation
        wait;
    end process;

end architecture test;
