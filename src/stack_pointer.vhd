-- ============================================================================
-- Stack Pointer for 16-Bit CPU
-- Manages the call stack for CALL/RET instructions
-- Stack grows downward from top of memory (0xFF)
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stack_pointer is
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        push   : in  std_logic;
        pop    : in  std_logic;
        spOut  : out std_logic_vector(7 downto 0)
    );
end entity stack_pointer;

architecture behavioral of stack_pointer is
    signal sp_reg : unsigned(7 downto 0);
begin

    process(clk, reset)
    begin
        if reset = '1' then
            sp_reg <= x"FF";  -- Stack starts at top of memory
        elsif rising_edge(clk) then
            if push = '1' then
                sp_reg <= sp_reg - 1;  -- Grow downward
            elsif pop = '1' then
                sp_reg <= sp_reg + 1;  -- Shrink upward
            end if;
        end if;
    end process;

    spOut <= std_logic_vector(sp_reg);

end architecture behavioral;
