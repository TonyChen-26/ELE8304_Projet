		
-------------------------------------------------------------------------------
-- Library Imports
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all;

-------------------------------------------------------------------------------
-- Entity Declaration
-------------------------------------------------------------------------------
entity memory_access is
  port (
    -- Clock and Reset
    i_clk         : in  std_logic;                          -- Clock signal
    i_rstn        : in  std_logic;                          -- Active-low reset

    -- Inputs
    i_store_data  : in  std_logic_vector(XLEN-1 downto 0);  -- Data to be stored in memory
    i_alu_result  : in  std_logic_vector(XLEN-1 downto 0);  -- ALU computation result
    i_rd_addr     : in  std_logic_vector(REG_WIDTH -1 downto 0);  -- Destination register address
    i_rw          : in  std_logic;                          -- Read/Write control signal
    i_wb          : in  std_logic;                          -- Write-back control signal
    i_we          : in  std_logic;                          -- Write enable signal

    -- Outputs
    o_store_data  : out std_logic_vector(XLEN-1 downto 0);  -- Data to be written to memory
    o_alu_result  : out std_logic_vector(XLEN-1 downto 0);  -- ALU result passed to the next stage
    o_wb          : out std_logic;                          -- Write-back control signal passed on
    o_we          : out std_logic;                          -- Write enable signal passed on
    o_rw          : out std_logic;                          -- Read/Write control signal passed on
    o_rd_addr     : out std_logic_vector(REG_WIDTH-1 downto 0)  -- Destination register address
  );
end entity memory_access;

-------------------------------------------------------------------------------
-- Architecture Implementation
-------------------------------------------------------------------------------
architecture beh of memory_access is
begin

  -- Process for synchronous reset and sequential logic
  process(i_clk, i_rstn)
  begin
    -- Reset condition: Active-low reset (i_rstn = '0')
    if falling_edge(i_rstn) then
      o_store_data  <= (others => '0');     -- Clear store data
      o_we          <= '0';                -- Disable write enable
      o_rw          <= '0';                -- Clear read/write signal
      o_alu_result  <= (others => '0');    -- Clear ALU result
      o_wb          <= '0';                -- Disable write-back
      o_rd_addr     <= (others => '0');    -- Clear register address

    -- Clock rising edge: Update outputs with inputs
    elsif rising_edge(i_clk) then
      o_store_data  <= i_store_data;       -- Pass input store data to output
      o_we          <= i_we;               -- Pass input write enable signal
      o_rw          <= i_rw;               -- Pass input read/write control
      o_alu_result  <= i_alu_result;       -- Pass ALU result to output
      o_wb          <= i_wb;               -- Pass write-back control signal
      o_rd_addr     <= i_rd_addr;          -- Pass destination register address
    end if;
  end process;

end architecture beh;



