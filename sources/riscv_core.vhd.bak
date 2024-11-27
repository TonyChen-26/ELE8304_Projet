library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.riscv_pkg.all;

entity riscv_core is
    port (
    i_rstn : in std_logic;
    i_clk : in std_logic;
    o_imem_en : out std_logic;
    o_imem_addr : out std_logic_vector(8 downto 0);
    i_imem_read : in std_logic_vector(31 downto 0);
    o_dmem_en : out std_logic;
    o_dmem_we : out std_logic;
    o_dmem_addr : out std_logic_vector(8 downto 0);
    i_dmem_read : in std_logic_vector(31 downto 0);
    o_dmem_write : out std_logic_vector(31 downto 0);
    -- DFT
    i_scan_en : in std_logic;
    i_test_mode : in std_logic;
    i_tdi : in std_logic;
    o_tdo : out std_logic
);
end entity riscv_core;

architecture beh of riscv_core is

  -- Signals for inter-stage connections
    signal pc, next_pc            : std_logic_vector(XLEN-1 downto 0);
    signal instruction            : std_logic_vector(31 downto 0);
    signal rs1_data, rs2_data     : std_logic_vector(31 downto 0);
    signal alu_result             : std_logic_vector(31 downto 0);
    signal branch, jump           : std_logic;
    signal imm                    : std_logic_vector(31 downto 0);
    signal alu_op                 : std_logic_vector(2 downto 0);
    signal store_data, load_data  : std_logic_vector(31 downto 0);
    signal wb_data                : std_logic_vector(31 downto 0);
    signal wb_addr                : std_logic_vector(4 downto 0);
    signal wb_enable              : std_logic;
    signal rw, src_imm, sign, arith : std_logic;
    signal pc_target, pc_transfer : std_logic_vector(XLEN-1 downto 0);
    signal flush                  : std_logic;



    component FETCH is
    Port (
        clk       : in  std_logic;
        i_flush      : in  std_logic;
        i_stall     : in  std_logic;
        i_transfert : in  std_logic;
        i_target    : in  std_logic_vector(XLEN-1 downto 0);
        i_mem : in  std_logic_vector(XLEN-1 downto 0);  -- Instruction from memory

        -- Outputs
        o_instruction     : out std_logic_vector(XLEN-1 downto 0);
        o_pc        : out std_logic_vector(XLEN-1 downto 0);
        o_imem_addr : out std_logic_vector(8 downto 0);  -- Address to memory (9-bit address)
        o_imem_en   : out std_logic                     -- Memory enable signal
    );
	end component FETCH;

component riscv_id is
    Port (
        i_clk       : in std_logic;
        i_rstn      : in std_logic;
	

        i_pc        : in std_logic_vector(XLEN-1 downto 0);
        i_instr     : in std_logic_vector(31 downto 0);
        i_wb        : in std_logic;
        i_rd_addr   : in std_logic_vector(4 downto 0);
        i_rd_data   : in std_logic_vector(31 downto 0);
        i_flush     : in std_logic;
        
        o_rs1_data  : out std_logic_vector(31 downto 0);
        o_rs2_data  : out std_logic_vector(31 downto 0);
	
	o_rd_addr   : out std_logic_vector(REG_WIDTH-1 downto 0);

        o_branch    : out std_logic;
        o_jump      : out std_logic;
        o_rw        : out std_logic;
        o_wb_out    : out std_logic;
        o_arith     : out std_logic;
        o_sign      : out std_logic;
        o_src_imm   : out std_logic;
        o_alu_op    : out std_logic_vector(2 downto 0);
        o_pc        : out std_logic_vector(XLEN-1 downto 0);
        o_imm       : out std_logic_vector(31 downto 0)
    );
end component riscv_id;


component execute is
    Port (
       	i_clk 	      : in std_logic;
	i_rstn	      : in std_logic;
	i_alu_op      : in  std_logic_vector(2 downto 0); 
        i_rs1_data    : in  STD_LOGIC_VECTOR(31 downto 0);
        i_rs2_data    : in  STD_LOGIC_VECTOR(31 downto 0);
        i_imm         : in  STD_LOGIC_VECTOR(31 downto 0);
        i_pc          : in  STD_LOGIC_VECTOR(XLEN-1 downto 0);
        i_src_imm     : in  STD_LOGIC;
        i_branch      : in  STD_LOGIC;
        i_jump        : in  STD_LOGIC;
	i_arith       : in std_logic;	
	i_sign        : in std_logic;

        i_rd_addr    : in std_logic_vector(REG_WIDTH-1 downto 0);
        i_rw         : in std_logic;
        i_wb         : in std_logic;


        -- Outputs
        o_pc_transfer : out STD_LOGIC;
        o_alu_result  : out STD_LOGIC_VECTOR(31 downto 0);
        o_store_data  : out STD_LOGIC_VECTOR(31 downto 0);
        o_pc_target   : out STD_LOGIC_VECTOR(XLEN-1 downto 0);

	o_we          : out std_logic;
        o_rd_addr     : out std_logic_vector(REG_WIDTH-1 downto 0);
        o_rw          : out std_logic;
        o_wb          : out std_logic
    );
end component execute;

component memory is
    Port (
        i_clk        : in std_logic;
	i_rstn	     : in std_logic;
        i_store_data : in std_logic_vector(31 downto 0);
        i_rw         : in std_logic;
        i_we         : in std_logic;
        i_alu_result : in std_logic_vector(31 downto 0);
        i_wb         : in std_logic;
        i_rd_addr    : in std_logic_vector(4 downto 0);
        
	
        o_rw            : out std_logic;
        i_dmem_read     : in std_logic_vector(XLEN-1 downto 0);
        o_dmem_en       : out std_logic;
        o_dmem_we       : out std_logic;
        o_dmem_addr     : out std_logic_vector(8 downto 0);
        o_dmem_write    : out std_logic_vector(XLEN-1 downto 0);

	o_load_data  : out std_logic_vector(31 downto 0);
        o_alu_result : out std_logic_vector(31 downto 0);
        o_wb         : out std_logic;
        o_rd_addr    : out std_logic_vector(4 downto 0)
    );
end component memory;

component write_back is
    Port (
        i_rw         : in std_logic;
        i_wb         : in std_logic;
        i_load_data  : in std_logic_vector(31 downto 0);
        i_alu_result : in std_logic_vector(31 downto 0);
        i_rd_addr    : in std_logic_vector(4 downto 0);

        o_rd_data    : out std_logic_vector(31 downto 0);
        o_wb         : out std_logic;
        o_rd_addr    : out std_logic_vector(4 downto 0)
    );
end component write_back;


    -- Signals for inter-stage connections
    signal if_to_id_instr       : std_logic_vector(31 downto 0);  -- Instruction IF to ID
    signal if_to_id_pc          : std_logic_vector(31 downto 0);  -- PC IF to ID

    signal id_to_ex_rs1_data    : std_logic_vector(31 downto 0);  -- rs1 data ID to EX
    signal id_to_ex_rs2_data    : std_logic_vector(31 downto 0);  -- rs2 data ID to EX
    signal id_to_ex_imm         : std_logic_vector(31 downto 0);  -- Immediate value ID to EX
    signal id_to_ex_branch      : std_logic;                      -- Branch signal ID to EX
    signal id_to_ex_jump        : std_logic;                      -- Jump signal ID to EX
    signal id_to_ex_rw          : std_logic;                      -- Read/Write signal ID to EX
    signal id_to_ex_wb          : std_logic;                      -- Write-back enable ID to EX
    signal id_to_ex_arith       : std_logic;                      -- Arithmetic operation flag
    signal id_to_ex_sign        : std_logic;                      -- Signed/Unsigned control
    signal id_to_ex_src_imm     : std_logic;                      -- Source immediate flag
    signal id_to_ex_alu_op      : std_logic_vector(2 downto 0);   -- ALU operation
    signal id_to_ex_rd_addr     : std_logic_vector(4 downto 0);   -- Destination register address
    signal id_to_ex_pc          : std_logic_vector(31 downto 0);  -- PC from ID to EX

    signal ex_to_me_result      : std_logic_vector(31 downto 0);  -- ALU result EX to MEM
    signal ex_to_me_store_data  : std_logic_vector(31 downto 0);  -- Data to store EX to MEM
    signal ex_to_me_rw          : std_logic;                      -- Read/Write control EX to MEM
    signal ex_to_me_we          : std_logic;                      -- Write enable EX to MEM
    signal ex_to_me_wb          : std_logic;                      -- Write-back enable EX to MEM
    signal ex_to_me_rd_addr     : std_logic_vector(4 downto 0);   -- RD address EX to MEM
    signal ex_to_if_pc_transfer : std_logic;                      -- PC transfer control EX to IF
    signal ex_to_if_pc_target   : std_logic_vector(31 downto 0);  -- Target PC EX to IF

    signal me_to_wb_rd_addr     : std_logic_vector(4 downto 0);   -- Destination register address MEM to WB
    signal me_to_wb_rw          : std_logic;                      -- Read/Write control MEM to WB
    signal me_to_wb_load_data   : std_logic_vector(31 downto 0);  -- Data loaded from memory MEM to WB
    signal me_to_wb_alu_result  : std_logic_vector(31 downto 0);  -- ALU result MEM to WB
    signal me_to_wb_wb          : std_logic;                      -- Write-back enable MEM to WB

    signal wb_to_id_addr        : std_logic_vector(4 downto 0);   -- Register address WB to ID
    signal wb_to_id_data        : std_logic_vector(31 downto 0);  -- Register data WB to ID
    signal wb_to_id_wb          : std_logic;                      -- Write-back enable WB to ID

begin 

    -- Instruction Fetch (IF) Stage
    u_fetch : FETCH
        port map (
            clk         => i_clk,
            i_flush     => i_rstn,     -- Control signal for flushing the pipeline
            i_stall     => '0',                      -- Stall logic (optional, defaulted to 0)
            i_transfert => ex_to_if_pc_transfer,     -- Control signal to transfer PC
            i_target    => ex_to_if_pc_target,       -- Target PC for branch/jump
            i_mem       => i_imem_read,              -- Instruction memory data input

            o_instruction => if_to_id_instr,         -- Instruction to ID stage
            o_pc          => if_to_id_pc,            -- Program Counter to ID stage
            o_imem_addr   => o_imem_addr,            -- Instruction memory address
            o_imem_en     => o_imem_en               -- Instruction memory enable
        );

    -- Instruction Decode (ID) Stage
    u_decode : riscv_id
        port map (
            i_clk       => i_clk,
            i_rstn      => i_rstn,
	    i_flush     => i_rstn,
            i_wb        => wb_to_id_wb,              -- Write-back control signal from WB stage
            i_rd_addr   => wb_to_id_addr,            -- Register address from WB
            i_rd_data   => wb_to_id_data,            -- Register data from WB
            i_instr     => if_to_id_instr,           -- Instruction from IF
            i_pc        => if_to_id_pc,              -- PC from IF

            o_rs1_data  => id_to_ex_rs1_data,        -- RS1 data to EX
            o_rs2_data  => id_to_ex_rs2_data,        -- RS2 data to EX
            o_branch    => id_to_ex_branch,          -- Branch signal
            o_jump      => id_to_ex_jump,            -- Jump signal
            o_rw        => id_to_ex_rw,              -- Read/Write control
            o_wb_out    => id_to_ex_wb,              -- Write-back control
            o_arith     => id_to_ex_arith,           -- Arithmetic control
            o_sign      => id_to_ex_sign,            -- Sign control
            o_src_imm   => id_to_ex_src_imm,         -- Immediate source flag
            o_alu_op    => id_to_ex_alu_op,          -- ALU operation code
            o_rd_addr   => id_to_ex_rd_addr,         -- RD address to EX
            o_imm       => id_to_ex_imm              -- Immediate value to EX
        );

    -- Execute (EX) Stage
    u_execute : execute
        port map (
            i_clk        => i_clk,
            i_rstn       => i_rstn,
            i_rs1_data   => id_to_ex_rs1_data,
            i_rs2_data   => id_to_ex_rs2_data,
            i_imm        => id_to_ex_imm,
            i_pc         => id_to_ex_pc,
            i_src_imm    => id_to_ex_src_imm,
            i_branch     => id_to_ex_branch,
            i_jump       => id_to_ex_jump,
            i_arith      => id_to_ex_arith,
            i_sign       => id_to_ex_sign,
            i_alu_op     => id_to_ex_alu_op,
            i_rd_addr    => id_to_ex_rd_addr,
            i_rw         => id_to_ex_rw,
            i_wb         => id_to_ex_wb,

            o_pc_transfer => ex_to_if_pc_transfer,
            o_pc_target   => ex_to_if_pc_target,
            o_alu_result  => ex_to_me_result,
            o_store_data  => ex_to_me_store_data,
            o_we          => ex_to_me_we,
            o_rw          => ex_to_me_rw,
            o_wb          => ex_to_me_wb,
            o_rd_addr     => ex_to_me_rd_addr
        );

    -- Memory Access (MEM) Stage
    u_memory : memory
        port map (
            i_clk        => i_clk,
            i_rstn       => i_rstn,
            i_store_data => ex_to_me_store_data,
            i_rw         => ex_to_me_rw,
            i_we         => ex_to_me_we,
            i_alu_result => ex_to_me_result,
            i_wb         => ex_to_me_wb,
            i_rd_addr    => ex_to_me_rd_addr,
            i_dmem_read  => i_dmem_read,

            o_load_data  => me_to_wb_load_data,
            o_alu_result => me_to_wb_alu_result,
            o_wb         => me_to_wb_wb,
            o_rd_addr    => me_to_wb_rd_addr,
            o_dmem_en    => o_dmem_en,
            o_dmem_we    => o_dmem_we,
            o_dmem_addr  => o_dmem_addr,
            o_dmem_write => o_dmem_write
        );

    -- Write-Back (WB) Stage
    u_write_back : write_back
        port map (
            i_rw         => me_to_wb_rw,
            i_load_data  => me_to_wb_load_data,
            i_alu_result => me_to_wb_alu_result,
            i_rd_addr    => me_to_wb_rd_addr,
            i_wb         => me_to_wb_wb,

            o_rd_addr    => wb_to_id_addr,
            o_rd_data    => wb_to_id_data,
            o_wb         => wb_to_id_wb
        );



end architecture beh;
