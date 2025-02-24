
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;	   
use work.riscv_pkg.all;

entity execute is
  port ( 	
  i_rstn			: in  std_logic;
  i_clk 			: in  std_logic;					
  i_jump 			: in  std_logic;
  i_branch 			: in  std_logic; 
  i_src_imm			: in  std_logic;
  i_rw 				: in  std_logic; -- read word from d-mem
  i_we				: in  std_logic; -- write enable in d-mem	
  i_wb 				: in  std_logic; -- write back in rf
  i_rs1_data 		: in  std_logic_vector(XLEN-1 downto 0);
  i_rs2_data 		: in  std_logic_vector(XLEN-1 downto 0);
  i_imm				: in  std_logic_vector(XLEN-1 downto 0);
  i_pc				: in  std_logic_vector(XLEN-1  downto 0);
  i_rd_addr 		: in  std_logic_vector(REG_WIDTH-1 downto 0);
  i_stall			: in  std_logic;

  -- ALU inputs	from ID
  i_shamt			: in  std_logic_vector(SHAMT_WIDTH-1 downto 0);
  i_alu_op			: in  std_logic_vector(ALUOP_WIDTH-1 downto 0);
  i_arith			: in  std_logic;
  i_sign			: in  std_logic;
	
  o_pc_transfert	: out std_logic;
  o_alu_result 		: out std_logic_vector(XLEN-1 downto 0);
  o_store_data 		: out std_logic_vector(XLEN-1 downto 0); 
  o_pc_target 		: out std_logic_vector(XLEN-1 downto 0);
  o_rw 				: out std_logic;  -- read word from d-mem
  o_we				: out std_logic;	-- write enable in d-mem
  o_wb				: out std_logic;  -- write back in rf
  o_rd_addr 		: out std_logic_vector(REG_WIDTH-1 downto 0);
  tb_execute_alu_result: out std_logic_vector(XLEN-1 downto 0);
  tb_pc_transfert 	: out std_logic;
  tb_pc_target 		: out std_logic_vector(XLEN-1 downto 0);
  tb_imm			: out std_logic_vector(XLEN-1 downto 0) 
  ); 
  
end entity execute;

architecture beh of execute is 	

component riscv_alu is
	port (
	    i_arith  : in  std_logic;                                -- Arith/Logic
	    i_sign   : in  std_logic;                                -- Signed/Unsigned
	    i_opcode : in  std_logic_vector(ALUOP_WIDTH-1 downto 0); -- ALU opcodes
	    i_shamt  : in  std_logic_vector(SHAMT_WIDTH-1 downto 0); -- Shift Amount
	    i_src1   : in  std_logic_vector(XLEN-1 downto 0);        -- Operand A
	    i_src2   : in  std_logic_vector(XLEN-1 downto 0);        -- Operand B
	    o_res    : out std_logic_vector(XLEN-1 downto 0));       -- Result	   
  end component riscv_alu ;
  
  component riscv_adder is 
	generic (N : positive := 32);
	port (
		i_a    : in  std_logic_vector(XLEN-1 downto 0);
  		i_b    : in  std_logic_vector(XLEN-1 downto 0);   
	    i_sign : in  std_logic;
	    i_sub  : in  std_logic;
	    o_sum  : out std_logic_vector(XLEN downto 0));
  end component riscv_adder;
  
signal alu_result		: std_logic_vector(XLEN-1 downto 0);
signal src2_alu			: std_logic_vector(XLEN-1 downto 0);
signal pc_target		: std_logic_vector(XLEN downto 0);
signal beq				: std_logic;
signal pc_transfert		: std_logic;
signal branch_and_alu   : std_logic_vector(XLEN downto 0);

begin 
  tb_pc_target <= pc_target(XLEN-1 downto 0);
  tb_pc_transfert <= pc_transfert;
  tb_execute_alu_result <= alu_result;
  tb_imm <= i_imm;
  branch_and_alu <=  i_branch&alu_result;
  
	pc_adder: component riscv_adder
    port map(
	i_a => i_imm,
    i_b => i_pc,
    i_sign => '0',
    i_sub => '0',
	o_sum => pc_target	 
	);	
	-- MUX to select src2_alu
  with i_src_imm select  src2_alu <=
  i_imm		 when '1',  
  i_rs2_data when others;
  
  	-- PC transfert
  with branch_and_alu select beq <= 
  '1'	when "100000000000000000000000000000000",	-- if (alu_result == 0 and i_branch==1) ==> BEQ
  '0'	when others;
  pc_transfert <= beq or i_jump;		 -- pc_transfert == flush
  
  -- ALU 
  alu: component riscv_alu
	  port map(
	  i_arith => i_arith,
	  i_sign => i_sign,
	  i_opcode => i_alu_op,
	  i_shamt => i_shamt,
	  i_src1 => i_rs1_data,
	  i_src2 => src2_alu,
	  o_res => alu_result
	  );
  
  process(i_clk, i_rstn)
	begin
	  if i_rstn = '0' then
		o_pc_transfert <= '0';
		o_alu_result   <= alu_result;  -- reset by decode 
		o_store_data   <= i_rs2_data;  -- won't be stored because we = 0
		o_pc_target    <= pc_target(XLEN-1 downto 0);   -- handled by pc
		o_rw 		   <= '0';
		o_we		   <= '0';
		o_wb		   <= '0';
		o_rd_addr	   <= i_rd_addr;   -- handeled by rf
	  elsif rising_edge(i_clk) then	
		o_pc_transfert <= pc_transfert;	-- pc_transfert == flush
		o_alu_result   <= alu_result;
		o_store_data   <= i_rs2_data;
		o_pc_target    <= pc_target(XLEN-1 downto 0);  -- we don't need the last bit of o_sum
		o_rw 		   <= i_rw;
		o_we		   <= i_we;
		o_wb		   <= i_wb;
		o_rd_addr	   <= i_rd_addr;
	  end if;
	end process;	
  
end architecture beh;


