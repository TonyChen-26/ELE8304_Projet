library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
port (
    i_clk           : in std_logic;
    i_store_data    : in std_logic_vector(31 downto 0);
    i_rw            : in std_logic;
    i_we            : in std_logic;
    i_alu_result    : in std_logic_vector(31 downto 0);
    i_wb            : in std_logic;
    i_rd_addr       : in std_logic_vector(4 downto 0);

    o_load_data     : out std_logic_vector(31 downto 0);
    o_alu_result    : out std_logic_vector(31 downto 0);
    o_wb            : out std_logic;
    o_rd_addr       : out std_logic_vector(4 downto 0)
  );
end entity memory;


architecture Behavioral of memory is

--signal i_clk_buffer : std_logic;
--signal i_store_data_buffer : std_logic_vector(31 downto 0);
--signal i_rw_buffer : std_logic;
--signal i_we_buffer : std_logic; 
signal mem_load_data_buffer: std_logic_vector(31 downto 0):= (others => '1');
  -- Signaux internes pour connecter les composants
  signal mem_load_data : std_logic_vector(31 downto 0);
  signal reg_alu_result : std_logic_vector(31 downto 0);
  signal reg_wb : std_logic;
  signal reg_rd_addr : std_logic_vector(4 downto 0);


begin
  -- Instanciation du module D-MEM
  d_mem_instance : entity work.d_mem
    port map (
      i_clk        => i_clk,         -- Signal d'horloge
      i_store_data => i_store_data,  -- Données à écrire dans la mémoire
      i_rw         => i_rw,          -- Contrôle lecture/écriture
      i_we         => i_we,          -- Activation de l'écriture
      i_alu_result => i_alu_result,  -- Adresse mémoire fournie par l'ALU
      o_load_data  => mem_load_data_buffer  -- Données lues depuis la mémoire
    );

  -- Registre ME/WB pour retenir les valeurs précédentes
  process(i_clk)
  begin
    if rising_edge(i_clk) then
      reg_alu_result <= i_alu_result; -- Stockage du résultat ALU
      reg_wb <= i_wb;                 -- Stockage de WB
      reg_rd_addr <= i_rd_addr;       -- Stockage de l'adresse registre
    end if;
  end process;

  -- Assignations des sorties via les buffers
  o_load_data <= mem_load_data_buffer;   -- Données lues depuis la mémoire
  o_alu_result <= reg_alu_result; -- Valeur précédente de ALU Result
  o_wb <= reg_wb;                 -- Valeur précédente de WB
  o_rd_addr <= reg_rd_addr;       -- Valeur précédente de l'adresse registre

end architecture Behavioral;