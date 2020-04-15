library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PC  is 
	PORT (clk, en,loadPC,IncPC, reset: IN std_logic;
	      IRout: IN std_logic_vector(15 downto 0);--INPUT
	      PCout: OUT std_logic_vector(15 downto 0)); --output
end PC;

architecture behaviour of PC is

signal pcReg: std_logic_vector(15 downto 0);
begin

process(clk)
begin

if clk'event and clk='1' then
  if reset='1' then
	pcReg <= x"0000";

  elsif loadPC='1' then
	pcReg <= IRout;

  elsif IncPC ='1' then
	pcReg <= pcReg+ x"0001";
  end if; 
end if;
end process;
PCout <= pcReg when en='1' else "ZZZZZZZZZZZZZZZZ";
end behaviour;

