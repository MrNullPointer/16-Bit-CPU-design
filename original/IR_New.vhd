library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;


entity IR is
	port(clk,ldir,enableAB, enableDB,reset: IN std_logic;
	     abus: OUT std_logic_vector(15 downto 0);
	     dbus: INOUT std_logic_vector(15 downto 0);
	     load,store,add,halt,jump:OUT std_logic;
	     Cjump,Iload,Istore,Dload,Dadd:OUT std_logic);
end IR;

architecture behavior of IR is

signal irReg:std_logic_vector(15 downto 0);
begin

process(clk)
begin

if clk'event and clk='0' then
   if reset='1' then irReg <= x"0000";
   elsif ldir= '1' then irReg <= dbus;
   end if;
end if;
end process;

abus <= "0000" & irReg(11 downto 0) when enableAB= '1'
	else "ZZZZZZZZZZZZZZZZ";
dbus <= "0000" & irReg(11 downto 0) when enableDB= '1' 
	else "ZZZZZZZZZZZZZZZZ";
load <= '1' when irReg(15 downto 12) = x"0" 
	else '0';
store <= '1' when irReg(15 downto 12) = x"1"
 	else '0';
add <= '1' when irReg(15 downto 12) = x"2" 
	else '0';
halt <= '1' when irReg= x"3" & x"001" 
	else '0';
jump <= '1' when irReg(15 downto 12) = x"4" 
	else '0';
Cjump <= '1' when irReg(15 downto 12) = x"5" 
	else '0';
Iload <= '1' when irReg(15 downto 12) = x"6" 
	else '0';
Istore <= '1' when irReg(15 downto 12) = x"7"
	 else '0';
Dload <= '1' when irReg(15 downto 12) = x"8" 
	else '0';
Dadd <= '1' when irReg(15 downto 12) = x"9" 
	else '0';
end behavior;

