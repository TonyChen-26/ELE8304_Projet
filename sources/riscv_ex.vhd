library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.riscv_pkg.all;

entity execute is
    Port (
        -- Inputs
        i_alu_op      : in  STD_LOGIC_VECTOR(3 downto 0);
        i_rs1_data    : in  STD_LOGIC_VECTOR(31 downto 0);
        i_rs2_data    : in  STD_LOGIC_VECTOR(31 downto 0);
        i_imm         : in  STD_LOGIC_VECTOR(31 downto 0);
        i_pc          : in  STD_LOGIC_VECTOR(31 downto 0);
        i_src_imm     : in  STD_LOGIC;
        i_branch      : in  STD_LOGIC;
        i_jump        : in  STD_LOGIC;
        
        -- Outputs
        o_pc_transfer : out STD_LOGIC_VECTOR(31 downto 0);
        o_alu_result  : out STD_LOGIC_VECTOR(31 downto 0);
        o_store_data  : out STD_LOGIC_VECTOR(31 downto 0);
        o_pc_target   : out STD_LOGIC_VECTOR(31 downto 0)
    );
end execute;

architecture Behavioral of execute is

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



    -- Signaux intermédiaires pour connecter les sous-modules
    signal alu_in2      : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_out      : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_offset    : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_next      : STD_LOGIC_VECTOR(31 downto 0);
    
begin
    -- **Sélection entre rs2_data et imm pour l'ALU (src_imm)**
    alu_in2 <= i_imm when i_src_imm = '1' else i_rs2_data;

    -- **Instance du module ALU**
    alu_instance: riscv_alu
        port map (
            i_op     => i_alu_op,
            i_data1  => i_rs1_data,
            i_data2  => alu_in2,
            o_result => alu_out
        );

    -- **Instance du module adder** (pour calculer pc + 4)
    adder_pc: riscv_adder
        port map (
            i_a => i_pc,
            i_b => x"00000004",
            o_sum => pc_next
        );

    -- **Instance du module pc_transfer** (pour calculer pc + offset)
    pc_transfer_instance: riscv_pc
        port map (
            i_pc      => i_pc,
            i_offset  => i_imm,
            o_pc_next => pc_offset
        );

    -- Gestion des branchements et sauts pour générer pc_target
    process(i_branch, i_jump, alu_out, pc_next, pc_offset)
    begin
        -- Calcul du pc_target
        if i_jump = '1' then
            o_pc_target <= i_rs1_data + i_imm; -- JALR avec rs1 et imm
        elsif i_branch = '1' then
            o_pc_target <= pc_offset; -- BEQ avec offset
        else
            o_pc_target <= pc_next; -- Par défaut, pc + 4
        end if;
    end process;

    -- **Assignation des sorties**
    o_pc_transfer <= pc_offset;
    o_alu_result <= alu_out;
    o_store_data <= i_rs2_data; -- La donnée à stocker pour les instructions de type SW

end Behavioral;
