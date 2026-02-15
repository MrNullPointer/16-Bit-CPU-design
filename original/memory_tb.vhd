LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
ENTITY tb_mem16b IS
generic ( N: integer := 3;
M: integer := 16);
END tb_mem16b;
ARCHITECTURE mem2 OF tb_mem16b IS
-- Component Declaration for the memory
COMPONENT mem16b
PORT(
ADDRESS : IN std_logic_vector(N-1 downto 0);
DATAIN : IN std_logic_vector(M-1 downto 0);
WE : IN std_logic;
CLOCK : IN std_logic;
DATAOUT : OUT std_logic_vector(M-1 downto 0)
);
END COMPONENT;
signal ADDRESS : std_logic_vector(N-1 downto 0) := (others => '0');
signal DATAIN : std_logic_vector(M-1 downto 0) := (others => '0');
signal WE : std_logic := '0';
signal CLOCK : std_logic := '0';
--Outputs
signal DATAOUT : std_logic_vector(M-1 downto 0);
-- Clock period definitions
constant CLOCK_period : time := 10 ns;
BEGIN
-- Instantiate the memory in VHDL
uut: mem16b PORT MAP (
ADDRESS => ADDRESS,
DATAIN => DATAIN,
WE => WE,
CLOCK => CLOCK,
DATAOUT => DATAOUT
);
-- Clock process definitions
CLOCK_process: process
begin
CLOCK <= '0';
wait for CLOCK_period/2;
CLOCK <= '1';
wait for CLOCK_period/2;
end process;
Simulation_process: process
begin
WE <= '0';
ADDRESS <= "000";
DATAIN <= x"00FF";
wait for 100 ns;
for i in 0 to 5 loop
ADDRESS <= ADDRESS + "001";
wait for CLOCK_period*5;
end loop;
ADDRESS <= "000";

WE <= '1';
-- start writing to memory
wait for 100 ns;
for i in 0 to 5 loop
ADDRESS <= ADDRESS + "001";
DATAIN <= DATAIN-x"0001";
wait for CLOCK_period*5;
end loop;
WE <= '0';
ADDRESS <= "000";
-- start reading data from memory
for i in 0 to 5 loop

ADDRESS <= ADDRESS + "001";
wait for CLOCK_period*5;
end loop;
wait;
end process;
END mem2;








