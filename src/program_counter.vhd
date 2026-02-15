-- ============================================================================
-- Program Counter for 16-Bit CPU
-- Supports: reset, load (absolute jump), increment, decrement (for RET)
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        loadPC : in  std_logic;
        incPC  : in  std_logic;
        decPC  : in  std_logic;
        pcIn   : in  std_logic_vector(15 downto 0);
        pcOut  : out std_logic_vector(15 downto 0)
    );
end entity program_counter;

architecture behavioral of program_counter is
    signal pc_reg : unsigned(15 downto 0);
begin

    process(clk, reset)
    begin
        if reset = '1' then
            pc_reg <= (others => '0');
        elsif rising_edge(clk) then
            if loadPC = '1' then
                pc_reg <= unsigned(pcIn);
            elsif incPC = '1' then
                pc_reg <= pc_reg + 1;
            elsif decPC = '1' then
                pc_reg <= pc_reg - 1;
            end if;
        end if;
    end process;

    pcOut <= std_logic_vector(pc_reg);

end architecture behavioral;
