library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity riscv_predecode is
	Port (
		i_instr	   : 	in std_logic_vector ( 31 downto 0);
		o_rs1_addr :	out std_logic_vector( 4 downto 0 );
		o_rs2_addr :	out std_logic_vector( 4 downto 0 );
		o_opcode   :    out std_logic_vector(6 downto 0);
		o_funct3   : 	out std_logic_vector(2 downto 0);
        	o_funct7   : 	out std_logic_vector(6 downto 0)
       		--o_rd 	   : 	out std_logic_vector(4 downto 0)
--        	o_imm 	   : 	out std_logic_vector(31 downto 0)
	);
end entity riscv_predecode;


  
architecture beh of riscv_predecode is 

	signal rs1_addr_buffer :  std_logic_vector( 4 downto 0 ):=(others=> '0'); 
	signal rs2_addr_buffer :  std_logic_vector( 4 downto 0 ):=(others=> '0'); 
	signal opcode_buffer   :  std_logic_vector( 6 downto 0 ):=(others=> '0'); 
	signal funct3_buffer   :  std_logic_vector( 2 downto 0 ):=(others=> '0'); 
	signal o_funct7_buffer :  std_logic_vector( 6 downto 0 ):=(others=> '0'); 
	--signal o_rd_buffer     :  std_logic_vector( 4 downto 0 ):=(others=> '0'); 


begin
    opcode_buffer <= i_instr(6 downto 0);
    o_opcode <= opcode_buffer;
    o_funct3 <= funct3_buffer; 
    o_funct7 <= o_funct7_buffer; 
    o_rs1_addr <= rs1_addr_buffer;
    o_rs2_addr<= rs2_addr_buffer;
    --o_rd <= o_rd_buffer;
    
	process(i_instr, opcode_buffer)
	begin
        case opcode_buffer is
            -- Format I-IMM
            when "0010011" | "0000011" | "1100111" =>
		rs1_addr_buffer <= i_instr(19 downto 15);
		funct3_buffer <= i_instr(14 downto 12);
		--o_rd_buffer <= i_instr(11 downto 7);
		rs2_addr_buffer <= (others => '0');	
		o_funct7_buffer <= (others => '0');
               --imm <= (others => instr(31)) & instr(30 downto 20); -- Sign-extension

            -- Format S-IMM
            when "0100011" =>		
		funct3_buffer <= i_instr(14 downto 12);
   		rs1_addr_buffer <= i_instr(19 downto 15);
    		rs2_addr_buffer <= i_instr(24 downto 20);
		--o_rd_buffer <= (others => '0');
		o_funct7_buffer <= (others => '0');
		
               -- imm <= (others => instr(31)) & instr(30 downto 25) & instr(11 downto 7);
            -- Format B-IMM
            when "1100011" =>
		funct3_buffer <= i_instr(14 downto 12);
    		rs1_addr_buffer <= i_instr(19 downto 15);
    		rs2_addr_buffer <= i_instr(24 downto 20);
		--o_rd_buffer <= (others => '0');
		o_funct7_buffer <= (others => '0');
                --imm <= (others => instr(31)) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0';
            -- Format U-IMM
            when "0110111" | "0010111" =>	
		--o_rd_buffer <= i_instr(11 downto 7);
		rs1_addr_buffer <= (others => '0');	
		funct3_buffer <= (others => '0');
		o_funct7_buffer <= (others => '0');
		rs2_addr_buffer <= (others => '0');
               -- imm <= instr(31 downto 12) & (others => '0');
            -- Format J-IMM
            when "1101111" =>
		rs1_addr_buffer <= (others => '0');	
		funct3_buffer <= (others => '0');
		o_funct7_buffer <= (others => '0');
		rs2_addr_buffer <= (others => '0');
		--o_rd_buffer <= i_instr(11 downto 7);
              --  imm <= (others => instr(31)) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0';
	    when "0110011" =>
		  -- Format R-Type
    		funct3_buffer <= i_instr(14 downto 12);
   		o_funct7_buffer <= i_instr(31 downto 25);
    		rs1_addr_buffer <= i_instr(19 downto 15);
    		rs2_addr_buffer <= i_instr(24 downto 20);
    		--o_rd_buffer <= i_instr(11 downto 7);

            when others =>
		rs1_addr_buffer <= (others => '0');	
		funct3_buffer <= (others => '0');
		o_funct7_buffer <= (others => '0');
		rs2_addr_buffer <= (others => '0');
		--o_rd_buffer <= (others => '0');
               -- imm <= (others => '0');
        end case;

    end process;



end architecture beh;