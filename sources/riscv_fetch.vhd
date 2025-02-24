--
--- File     riscv_fetch.vhd
---- Author   Tony Chen
---- Lab      GRM - Polytechnique Montreal
---- Date     2024-12-01
---------------------------------------------------------------------------------
---- Brief    Fetch layer in pipeline
---------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	   
use work.riscv_pkg.all;

entity fetch is
  port (
  i_target	     : in  std_logic_vector(XLEN-1 downto 0);
  i_imem_read    : in  std_logic_vector(XLEN-1 downto 0);
  i_transfert    : in  std_logic;
  i_stall		 : in  std_logic;
  i_flush		 : in  std_logic;
  i_rstn		 : in  std_logic;
  i_clk    	     : in  std_logic;  
  
  o_imem_en 	 : out std_logic;
  o_imem_addr    : out std_logic_vector(XLEN-1 downto 0);	
  o_instruction  : out std_logic_vector(XLEN-1 downto 0);
  o_pc			 : out std_logic_vector(XLEN-1 downto 0)
  );
end entity fetch;

architecture beh of fetch is 

	component riscv_pc is
		port (
		i_clk		 : in  std_logic;
		i_rstn		 : in  std_logic;
		i_stall		 : in  std_logic;
		i_transfert  : in  std_logic;
		i_target 	 : in std_logic_vector(XLEN-1 downto 0); 
		o_pc 		 : out  std_logic_vector(XLEN-1 downto 0));	   
	end component riscv_pc ;
	
	
	
	begin
	o_imem_en <= '1';		
	pc: component riscv_pc
		port map(
			i_clk =>  i_clk,
			i_rstn => i_rstn, 
			i_stall => i_stall,
			i_transfert => i_transfert,
			i_target => i_target,
			o_pc => o_imem_addr
			);
	process(i_clk, i_rstn,i_flush)
	begin
	  if i_rstn='0' then
	      o_instruction <= i_imem_read;  --reset to first instruction in i_mem (done by the reset of dpm)
	  elsif rising_edge(i_clk) then
	    if i_flush = '0' then	   
			--o_pc(MEM_ADDR_WIDTH-1 downto 0) => o_imem_addr(MEM_ADDR_WIDTH-1 downto 0)
			o_pc <= o_imem_addr;
			o_instruction <= i_imem_read;
		else
			o_instruction <= x"00000013";
	    end if;		
	  end if;
	end process;	
	
end architecture beh;


