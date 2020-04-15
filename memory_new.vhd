library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
entity mem16b is
generic ( N: integer := 3;
M: integer := 16);
port(
address: in std_logic_vector(N-1 downto 0);
datain: in std_logic_vector(M-1 downto 0); 
WE: in std_logic;
CLOCK: in std_logic; 
DATAOUT: out std_logic_vector(M-1 downto 0) 
);
end mem16b;
architecture mem1 of mem16b is
type MEM_ARRAY is array (0 to M-1 ) of std_logic_vector (M-1 downto 0);
signal MEM: MEM_ARRAY :=(others=> (others=>'0'));
begin
process(CLOCK)
begin
if(rising_edge(CLOCK)) then
if(WE='1') then -- when write enable = 1,
-- write input data into memory at the provided addressess
MEM(to_integer(unsigned(ADDRESS))) <= DATAIN;
end if;
end if;
end process;
-- Data to be read out
DATAOUT <= MEM(to_integer(unsigned(ADDRESS)));
end;



