library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mux IS
	Port ( ALUout, IRout: IN std_logic;
	      Sel2: IN std_logic; -- select line for the multiplexer.
	      MuxOut: OUT std_logic); -- output the selected input (A for Sel=0) 
end Mux;

architecture behavior of Mux is 
begin

process(ALUout, IRout ,Sel2) 

begin

if (Sel2 = '0') then MuxOut<= ALUout ; 
elsif (Sel2 = '1') then MuxOut<= IRout ; 
end if;

end process;
end behavior;


