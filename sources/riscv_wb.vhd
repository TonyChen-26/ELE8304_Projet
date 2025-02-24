library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.riscv_pkg.all;

entity write_back is
  port (
    -- Clock and Reset
    i_rstn       : in  std_logic;                           -- Active-low reset
    i_clk        : in  std_logic;                           -- Clock signal

    -- Inputs
    i_load_data  : in  std_logic_vector(XLEN-1 downto 0);   -- Data loaded from memory
    i_alu_result : in  std_logic_vector(XLEN-1 downto 0);   -- Result from ALU
    i_rd_addr    : in  std_logic_vector(REG_WIDTH-1 downto 0); -- Destination register address
    i_rw         : in  std_logic;                           -- Read/Write control signal
    i_wb         : in  std_logic;                           -- Write-back enable signal

    -- Outputs
    o_wb         : out std_logic;                           -- Write-back control signal
    o_rd_addr    : out std_logic_vector(REG_WIDTH-1 downto 0); -- Destination register address
    o_rd_data    : out std_logic_vector(XLEN-1 downto 0)    -- Data to write back to register
  );
end entity write_back;

architecture beh of write_back is
begin
  -- Pass through signals
  o_rd_addr <= i_rd_addr;  -- Propagate register address to output
  o_wb <= i_wb;            -- Propagate write-back signal to output

  -- Select data for write-back based on Read/Write control signal
  with i_rw select 
    o_rd_data <= 
      i_load_data  when '1',   -- Load data if i_rw is '1'
      i_alu_result when others; -- Otherwise, use ALU result
end architecture beh;


