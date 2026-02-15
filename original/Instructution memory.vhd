library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity instructionmemory is
	port(we_IM, reset, valu: IN std_logic;
	     abus: IN std_logic_vector(15 downto 0);--input pins
	     dbus: INOUT std_logic_vector(15 downto 0));--output pins
end instructionmemory;

architecture behavioral of instructionmemory is
type ramtype is array(0 to 63) of std_logic_vector(15 downto 0);

signal memory:ramtype;
begin

process(reset,we_IM)
begin

if reset='1' then
	memory(0)<= x"000A";
	memory(1)<= x"3000";
	memory(2)<= x"200B";
	memory(3)<= x"100C";
	memory(4)<= x"3001";
	memory(10)<= x"0010";
	memory(11)<= x"0011";

	for i in 12 to 63 Loop
	    memory(i) <=x"0000";
	END Loop;
elsif we_IM'event and we_IM='0' then
	memory(conv_integer(unsigned(abus)))<=dbus;
end If;
end process;
dbus <= memory(conv_integer(unsigned(abus))) when reset = '0' and valu='1' and we_IM='1' else "ZZZZZZZZZZZZZZZZ";
END behavioral;

