
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.riscv_pkg.all;

entity FETCH is
    Port (
        clk     : in  STD_LOGIC;
	i_flush : in  std_logic;
        i_mem   : in  STD_LOGIC_VECTOR(31 downto 0); 
	i_stall     : in  std_logic;
	i_transfert : in  std_logic;
    	i_target    : in  std_logic_vector(XLEN-1 downto 0);
        o_pc  : out  STD_LOGIC_VECTOR(XLEN-1 downto 0); 
        o_instruction : out  STD_LOGIC_VECTOR(31 downto 0)  := (others=> '0')
	
    );
end FETCH;

architecture Behavioral of FETCH is


component riscv_pc is
  generic (RESET_VECTOR : natural := 16#00000000#);
  port (
    i_clk       : in  std_logic;
    i_rstn      : in  std_logic;
    i_stall     : in  std_logic;
    i_transfert : in  std_logic;
    i_target    : in  std_logic_vector(XLEN-1 downto 0);
    o_pc        : out std_logic_vector(XLEN-1 downto 0));
end component riscv_pc;



signal InstructionBuffer : std_logic_vector(XLEN-1 downto 0):= (others=> '0'); 


begin

o_instruction <= InstructionBuffer;

    u_add:riscv_pc port map (clk, i_flush,i_stall,i_transfert,i_target, o_pc);

    process(clk, i_flush)
    begin
        if i_flush = '1' then
        	 InstructionBuffer <=(others => '0');

        elsif rising_edge(clk) then
		if i_stall = '0' then
			InstructionBuffer<= i_mem;  	
		else 
			InstructionBuffer <= InstructionBuffer;
 		end if;
        end if;
    end process;
	
end Behavioral;
