-- ============================================================================
-- Register File for 16-Bit CPU
-- Contains registers A, B, C with independent load controls
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;

entity register_file is
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        -- Load enables
        loadA   : in  std_logic;
        loadB   : in  std_logic;
        loadC   : in  std_logic;
        -- Data inputs
        dataInA : in  std_logic_vector(15 downto 0);
        dataInB : in  std_logic_vector(15 downto 0);
        dataInC : in  std_logic_vector(15 downto 0);
        -- Data outputs
        regA    : out std_logic_vector(15 downto 0);
        regB    : out std_logic_vector(15 downto 0);
        regC    : out std_logic_vector(15 downto 0)
    );
end entity register_file;

architecture behavioral of register_file is
    signal A_reg : std_logic_vector(15 downto 0);
    signal B_reg : std_logic_vector(15 downto 0);
    signal C_reg : std_logic_vector(15 downto 0);
begin

    process(clk, reset)
    begin
        if reset = '1' then
            A_reg <= (others => '0');
            B_reg <= (others => '0');
            C_reg <= (others => '0');
        elsif rising_edge(clk) then
            if loadA = '1' then
                A_reg <= dataInA;
            end if;
            if loadB = '1' then
                B_reg <= dataInB;
            end if;
            if loadC = '1' then
                C_reg <= dataInC;
            end if;
        end if;
    end process;

    regA <= A_reg;
    regB <= B_reg;
    regC <= C_reg;

end architecture behavioral;
