-- ============================================================================
-- Instruction Register for 16-Bit CPU
-- Decodes the 16-bit instruction into mode, opcode, and operand fields
--
-- Instruction format:
--   [15:14] Mode    - operation category
--   [13:11] Opcode  - specific operation within mode
--   [10:0]  Operand - immediate value or memory address (11 bits)
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;

entity instruction_register is
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        loadIR  : in  std_logic;
        irIn    : in  std_logic_vector(15 downto 0);
        mode    : out std_logic_vector(1 downto 0);
        opcode  : out std_logic_vector(2 downto 0);
        operand : out std_logic_vector(10 downto 0);
        irFull  : out std_logic_vector(15 downto 0)
    );
end entity instruction_register;

architecture behavioral of instruction_register is
    signal ir_reg : std_logic_vector(15 downto 0);
begin

    process(clk, reset)
    begin
        if reset = '1' then
            ir_reg <= (others => '0');
        elsif rising_edge(clk) then
            if loadIR = '1' then
                ir_reg <= irIn;
            end if;
        end if;
    end process;

    -- Decode fields
    mode    <= ir_reg(15 downto 14);
    opcode  <= ir_reg(13 downto 11);
    operand <= ir_reg(10 downto 0);
    irFull  <= ir_reg;

end architecture behavioral;
