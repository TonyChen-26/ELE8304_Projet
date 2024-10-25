
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DECODE is
    Port ( -- taille des vector no bueno
        i_clk         : in  STD_LOGIC;
        i_flush       : in  STD_LOGIC;
        i_instruction : in  STD_LOGIC_VECTOR(31 downto 0);
        i_wb          : in  STD_LOGIC;
        i_rd_addr     : in STD_LOGIC_VECTOR(4 downto 0);  
        i_rd_data     : in STD_LOGIC_VECTOR(4 downto 0);  
        o_rs1_data    : out STD_LOGIC_VECTOR(31 downto 0); 
        o_rs2_data    : out STD_LOGIC_VECTOR(31 downto 0); 
        o_imm         : out STD_LOGIC_VECTOR(31 downto 0); 
        o_src_imm     : out STD_LOGIC_VECTOR(31 downto 0); 
        o_branch      : out STD_LOGIC;
        o_jump        : out STD_LOGIC;
        o_wb          : out STD_LOGIC
        o_arith       : out STD_LOGIC;
        o_sign        : out STD_LOGIC;
        o_wb          : out STD_LOGIC;
    );
end DECODE;