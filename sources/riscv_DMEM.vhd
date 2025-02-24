library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity d_mem is
    port (
        i_clk        : in  std_logic;                      -- Clock signal
        i_store_data : in  std_logic_vector(31 downto 0);  -- Data to be stored
        i_rw         : in  std_logic;                      -- Read/Write control (0: Read, 1: Write)
        i_we         : in  std_logic;                      -- Write Enable
        i_alu_result : in  std_logic_vector(31 downto 0);  -- Address for memory access
        o_load_data  : out std_logic_vector(31 downto 0)   -- Data loaded from memory
    );
end entity d_mem;

architecture beh of d_mem is

    -- Memory array (simple simulation of a data memory, 256 32-bit locations)
    type mem_array is array (0 to 255) of std_logic_vector(31 downto 0);
    signal mem : mem_array := (others => (others => '0'));

    -- Buffered output signal
    signal load_data_buf : std_logic_vector(31 downto 0) := (others => '0');

    -- Address index signal (used instead of a function for conversion)
    signal addr_index : integer range 0 to 255 := 0;

begin
addr_index <= to_integer(unsigned(i_alu_result(7 downto 0)));
    -- Memory Access Process
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            -- Convert i_alu_result(7 downto 0) to an integer for indexing
            

            if i_we = '1' and i_rw = '1' then
                -- Write operation: store data at the address specified by i_alu_result
                mem(addr_index) <= i_store_data;
		--load_data_buf <= (others => '0'); 

            end if;

            if i_rw = '0' then
                -- Read operation: load data from the address specified by i_alu_result
                load_data_buf <= mem(addr_index);
            end if;
        end if;
    end process;

    -- Output Buffering
    o_load_data <= load_data_buf;

end architecture beh;

