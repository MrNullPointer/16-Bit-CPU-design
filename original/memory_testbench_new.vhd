library IEEE;
use ieee.std_logic_1164.all;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity memory_tb is
end memory_tb;


architecture mem of memory_tb is

component memory 
 generic (N : integer := 16;
	  M : integer := 3);

  port ( clock   : in  std_logic;
         we      : in  std_logic;
         address : in  std_logic_vector (M-1 downto 0);
         datain  : in  std_logic_vector (N-1 downto 0);
         dataout : out std_logic_vector (N-1 downto 0));
end component;


signal data_in : std_logic_vector (15 downto 0):=   (others => '0');
signal data_out: std_logic_vector (15 downto 0);
signal address: std_logic_vector (2 downto 0) :=  (others => '0');
signal enable: std_logic := '0';
signal clock: std_logic:='0';

begin

dut : memory port map (clock, enable, address, data_in, data_out);
clock   <= not clock  after 5 ns;

enable <= '1' after 5 ns, not enable  after 10 ns;

address   <= address + 1  after 20 ns;
data_in   <= data_in + 1  after 20 ns;

Simulation_process: process
begin
	enable <= '0';
	address <= "000";
	data_in <= x"00FF";

	wait for 20 ns;

	for i in 0 to 5 loop
		address <= address + "001";
		wait for 100 ns;
	end loop;

	address <= "000";
	enable <= '1';

-- start writing to memory
	wait for 100 ns;
	for i in 0 to 5 loop
		address <= address + "001";
		data_in <= data_in-x"0001";
		wait for 100 ns; 
	end loop;

	enable <= '0';
	address <= "000";
-- start reading data from memory
	
	for i in 0 to 5 loop
		address<= address + "001";
		wait for 100 ns;
	end loop;
	wait;
end process;


end mem;


