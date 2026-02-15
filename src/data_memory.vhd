-- ============================================================================
-- Data Memory for 16-Bit CPU
-- 256 x 16-bit RAM (expanded from original 8 words)
-- Synchronous write, asynchronous read
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory is
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        we      : in  std_logic;
        address : in  std_logic_vector(7 downto 0);
        dataIn  : in  std_logic_vector(15 downto 0);
        dataOut : out std_logic_vector(15 downto 0)
    );
end entity data_memory;

architecture behavioral of data_memory is
    type mem_array is array(0 to 255) of std_logic_vector(15 downto 0);
    signal mem : mem_array := (others => (others => '0'));
begin

    process(clk, reset)
    begin
        if reset = '1' then
            mem <= (others => (others => '0'));
            -- Pre-load some test data
            mem(64) <= x"000A";  -- Address 0x40: value 10
            mem(65) <= x"0014";  -- Address 0x41: value 20
        elsif rising_edge(clk) then
            if we = '1' then
                mem(to_integer(unsigned(address))) <= dataIn;
            end if;
        end if;
    end process;

    -- Asynchronous read
    dataOut <= mem(to_integer(unsigned(address)));

end architecture behavioral;
