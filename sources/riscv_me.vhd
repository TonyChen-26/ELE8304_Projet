library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
  Port (
    i_store_data  	: in std_logic_vector(6 downto 0);
    i_rw  		: in std_logic_vector(2 downto 0);
    i_we  		: in std_logic_vector(6 downto 0);
    i_alu_result   	: in std_logic_vector(31 downto 0);
    i_wb		: in std_logic_vector();
    i_rd_addr		: in std_logic_vector();

    o_load_data  	: out std_logic_vector();
    o_alu_result  	: out std_logic_vector();
    o_wb	  	: out std_logic_vector();
    o_rd_addr	  	: out std_logic_vector();
  );
end entity memory;
