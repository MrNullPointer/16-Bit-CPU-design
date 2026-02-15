-- ============================================================================
-- Instruction Memory for 16-Bit CPU
-- 256 x 16-bit ROM-like memory (expanded from original 64 words)
-- Can be initialized with a program via generics or reset
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_memory is
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        we      : in  std_logic;
        address : in  std_logic_vector(7 downto 0);
        dataIn  : in  std_logic_vector(15 downto 0);
        dataOut : out std_logic_vector(15 downto 0)
    );
end entity instruction_memory;

architecture behavioral of instruction_memory is
    type mem_array is array(0 to 255) of std_logic_vector(15 downto 0);
    signal mem : mem_array := (others => (others => '0'));
begin

    process(clk, reset)
    begin
        if reset = '1' then
            -- Clear all memory on reset
            mem <= (others => (others => '0'));

            -- Load default demo program:
            -- Program: Load two numbers, add them, store result
            -- Address 0: LDA 0x40   -> Load A from data memory address 0x40
            mem(0)  <= "10" & "000" & "00001000000";  -- Mode=10, Op=000(LDA), Addr=0x040
            -- Address 1: LDB 0x41   -> Load B from data memory address 0x41
            mem(1)  <= "10" & "001" & "00001000001";  -- Mode=10, Op=001(LDB), Addr=0x041
            -- Address 2: ADD
            mem(2)  <= "00" & "000" & "00000000000";  -- Mode=00, Op=000(ADD)
            -- Address 3: STC 0x42   -> Store C to data memory address 0x42
            mem(3)  <= "10" & "010" & "00001000010";  -- Mode=10, Op=010(STC), Addr=0x042
            -- Address 4: HALT
            mem(4)  <= "00" & "111" & "00000000000";  -- Mode=00, Op=111(HALT)

        elsif rising_edge(clk) then
            if we = '1' then
                mem(to_integer(unsigned(address))) <= dataIn;
            end if;
        end if;
    end process;

    -- Asynchronous read
    dataOut <= mem(to_integer(unsigned(address)));

end architecture behavioral;
