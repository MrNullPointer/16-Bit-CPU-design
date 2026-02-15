-- ============================================================================
-- 2-to-1 Multiplexer (16-bit) for 16-Bit CPU
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;

entity mux2to1 is
    port (
        inA  : in  std_logic_vector(15 downto 0);
        inB  : in  std_logic_vector(15 downto 0);
        sel  : in  std_logic;
        mOut : out std_logic_vector(15 downto 0)
    );
end entity mux2to1;

architecture behavioral of mux2to1 is
begin
    mOut <= inB when sel = '1' else inA;
end architecture behavioral;
