library ieee;
use ieee.std_logic_1164.all;

entity controller is

port ( EQ,ZA, ZB, Overflow, en, clb : IN std_logic;
       opcode1: in std_logic_vector (2 downto 0);
       ALU_opcode:out std_logic_vector (2 downto 0);
       Mode   : in std_logic_vector (1 downto 0); 
       loadIR, weDM , loadPC, incPC , sel1, sel2 : out std_logic;
       ALUmode : out std_logic_vector(1 downto 0); 
       loadA, loadB, loadC : inout std_logic);

end controller;

architecture controller of controller is
signal presentstate, nextstate : std_logic_vector (1 downto 0);
begin

process (en)

begin

if (clb = '0') then
	presentstate <= "00";
else
	presentstate <= nextstate;
end if;
end process;

process (ZA, ZB, Overflow, en, clb,opcode1, Mode)

begin

if(presentstate = "00") then 
	 loadIR <= '0';
	 loadA  <= '0';
	 loadB  <= '0';
	 loadC  <= '0';
	 weDM   <= '0';
	 loadPC <= '0';
	 sel1   <= '0';
	 sel2   <= '0';
	 incPC  <= '0';
end if;

if (presentstate = "01") then
	 loadIR <= '1';
	 loadA  <= '0';
	 loadB  <= '0';
	 loadC  <= '0';
	 weDM   <= '0';
	 loadPC <= '0';
	 ALU_opcode <= opcode1;
	 ALUmode <= Mode;
	 sel1 <= '0';
	 sel2 <= '0';
	 incPC <= '0';
	
end if;

if (presentstate = "10") then
	 loadIR <= '0';
	if (Mode = "01") then
	   case opcode1 is
	    	 when "000" =>   ALU_opcode <= opcode1;   ----AND
				 ALUmode <= Mode;
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '0';			 
				 weDM   <= '0';
				 loadPC <= '1';
				 sel1 <= '0';
 				 sel2 <= '0';
				 incPC <= '1';

		
	    	 when "001" =>   ALU_opcode <= opcode1;   ----OR
				 ALUmode <= Mode;
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '0';			 
				 weDM   <= '0';
				 loadPC <= '1';
				 sel1 <= '0';
 				 sel2 <= '0';
				 incPC <= '1';

		when "010" =>    ALU_opcode <= opcode1;   ----NAND
				 ALUmode <= Mode;
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '0';			 
				 weDM   <= '0';
				 loadPC <= '1';
				 sel1 <= '0';
 				 sel2 <= '0';
				 incPC <= '1';

		when "011" =>    ALU_opcode <= opcode1;   ----NOR
				 ALUmode <= Mode;
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '0';			 
				 weDM   <= '0';
				 loadPC <= '1';
				 sel1 <= '0';
 				 sel2 <= '0';
				 incPC <= '1';

		when "100" =>    ALU_opcode <= opcode1;   ----NOTA
				 ALUmode <= Mode;
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '0';			 
				 weDM   <= '0';
				 loadPC <= '1';
				 sel1 <= '0';
 				 sel2 <= '0';
				 incPC <= '1';

		when "101" =>    ALU_opcode <= opcode1;   ----NOTB
				 ALUmode <= Mode;
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '0';			 
				 weDM   <= '0';
				 loadPC <= '1';
				 sel1 <= '0';
 				 sel2 <= '0';
				 incPC <= '1';

		when "110" =>    ALU_opcode <= opcode1;   ----XOR
				 ALUmode <= Mode;
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '0';			 
				 weDM   <= '0';
				 loadPC <= '1';
				 sel1 <= '0';
 				 sel2 <= '0';
				 incPC <= '1';

		when "111" =>    ALU_opcode <= opcode1;   ----XNOR
				 ALUmode <= Mode;
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '0';			 
				 weDM   <= '0';
				 loadPC <= '1';
				 sel1 <= '0';
 				 sel2 <= '0';
				 incPC <= '1';
			when others => ALU_opcode <= opcode1;   ----HALT
				 ALUmode <= Mode;
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '0';
				 loadPC <= '1';
				 sel1 <= '0';
 				 sel2 <= '0';
				 incPC <= '1';

		end case;

	elsif (Mode = "00") then
	   case opcode1 is
	    	 when "000" =>   ALU_opcode <= opcode1;   ----ADD
				 ALUmode <= Mode;
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '0';			 
				 weDM   <= '0';
				 loadPC <= '1';
				 sel1 <= '0';
 				 sel2 <= '0';
                                 incPC <= '1';

	    	 when "001" =>   ALU_opcode <= opcode1;   ----MUL
				 ALUmode <= Mode;
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '0';			 
				 weDM   <= '0';
				 loadPC <= '1';
				 sel1 <= '0';
 				 sel2 <= '0';
                                 incPC <= '1';

		when "010" =>    ALU_opcode <= opcode1;   ----JZA
				 ALUmode <= Mode;
				 if (ZA = '1') then
				   loadA  <= '0';
				   loadB  <= '0';
				   loadC  <= '0';			 
				   weDM   <= '0';
				   loadPC <= '1';
				   sel1 <= '0';
 				   sel2 <= '1';
                                   incPC <= '0';
				 else
   				   loadA  <= '0';
				   loadB  <= '0';
				   loadC  <= '1';			 
				   weDM   <= '0';
				   loadPC <= '1';
				   sel1 <= '0';
 				   sel2 <= '0';
		                   incPC <= '1';
				end if;

		when "011" =>    ALU_opcode <= opcode1;   ----JE
				 ALUmode <= Mode;
		                 if (EQ = '1') then
   				   loadA  <= '0';
				   loadB  <= '0';
				   loadC  <= '1';			 
				   weDM   <= '0';
				   loadPC <= '1';
				   sel1 <= '0';
 				   sel2 <= '1';
                                   incPC <= '0';
				 else
				   loadIR <= '0';
   				   loadA  <= '0';
				   loadB  <= '0';
				   loadC  <= '1';			 
				   weDM   <= '0';
				   loadPC <= '1';
				   sel1 <= '0';
 				   sel2 <= '1';
		                   incPC <= '1';
				end if;

		when "100" =>    ALU_opcode <= opcode1;   ----JZB
				 ALUmode <= Mode;
		                 if (ZA = '1') then
		                   loadIR <= '1';
   				   loadA  <= '0';
				   loadB  <= '0';
				   loadC  <= '0';			 
				   weDM   <= '0';
				   loadPC <= '1';
				   sel1 <= '0';
 				   sel2 <= '0';
                                   incPC <= '0';
				 else
				   loadIR <= '0';
   				   loadA  <= '0';
				   loadB  <= '0';
				   loadC  <= '0';			 
				   loadPC <= '1';
				   sel1 <= '0';
 				   sel2 <= '0';
		                   incPC <= '1';
				end if;

		when "101" =>    ALU_opcode <= opcode1;   ----RDM
				 ALUmode <= Mode;
		                 loadIR <= '1';
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '1';			 
				 weDM   <= '0';
				 loadPC <= '1';
				 sel1 <= '1';
 				 sel2 <= '0';
				 incPC <= '1';

		when "110" =>    ALU_opcode <= opcode1;   ----NOP
				 ALUmode <= Mode;
		                 loadIR <= '0';
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '0';			 
				 loadPC <= '1';
				 sel1 <= '0';
 				 sel2 <= '0';
				 incPC <= '1';

		when "111" =>    ALU_opcode <= opcode1;   ----HALT
				 ALUmode <= Mode;
		                 loadIR <= '0';
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '0';
				 loadPC <= '1';
				 sel1 <= '0';
 				 sel2 <= '0';
				 incPC <= '1';
		when others => ALU_opcode <= opcode1; 
				 ALUmode <= Mode;
		                	 loadIR <= '0';
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '0';
				 loadPC <= '1';
				 sel1 <= '0';
 				 sel2 <= '0';
				 incPC <= '1';
	   end case;

	elsif (Mode = "10") then
	   case opcode1 is
	    	 when "000" =>   ALU_opcode <= opcode1;   ----LDA
				 ALUmode <= Mode;
		                 loadIR <= '1';
				 loadA  <= '1';
				 loadB  <= '0';
				 loadC  <= '1';			 
				 weDM   <= '0';
				 loadPC <= '1';
				 sel1 <= '1';
 				 sel2 <= '0';
                                 incPC <= '1';

	    	 when "001" =>   ALU_opcode <= opcode1;   ----LDB
				 ALUmode <= Mode;
		                 loadIR <= '1';
				 loadA  <= '0';
				 loadB  <= '1';
				 loadC  <= '1';			 
				 weDM   <= '0';
				 loadPC <= '1';
				 sel1 <= '1';
 				 sel2 <= '0';
                                 incPC <= '1';

		when "010" =>   ALU_opcode <= opcode1;   ----STC
				 ALUmode <= Mode;
		                 loadIR <= '1';
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '0';
				 weDM   <= '1';			 
				 loadPC <= '1';
				 sel1 <= '0';
                                 incPC <= '1';

	    	 when "011" =>   ALU_opcode <= opcode1;   ----LIC
				 ALUmode <= Mode;
		                 loadIR <= '1';
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '1';			 
				 loadPC <= '0';
				 sel1   <= '0';
 				 sel2   <= '1';
                                 incPC  <= '1';
		when others => ALU_opcode <= opcode1;   ----HALT
				 ALUmode <= Mode;
		                 loadIR <= '0';
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '0';
				 loadPC <= '1';
				 sel1 <= '0';
 				 sel2 <= '0';
				 incPC <= '1';
	   end case;

	elsif (Mode = "11") then
	   case opcode1 is
	    	 when "000" =>   ALU_opcode <= opcode1;   ----Shift right
				 ALUmode <= Mode;
				 loadA  <= '1';
				 loadB  <= '0';
				 loadC  <= '0';			 
				 weDM   <= '0';
				 loadPC <= '1';
				 sel1 <= '0';
 				 sel2 <= '0';
                                 incPC <= '1';

	    	 when "001" =>   ALU_opcode <= opcode1;   ----Shift left
				 ALUmode <= Mode;
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '0';			 
				 weDM   <= '0';
				 loadPC <= '1';
				 sel1 <= '0';
 				 sel2 <= '0';
                                 incPC <= '1';
		when others => ALU_opcode <= opcode1;   ----HALT
				 ALUmode <= Mode;
		                 loadIR <= '0';
				 loadA  <= '0';
				 loadB  <= '0';
				 loadC  <= '0';
				 loadPC <= '1';
				 sel1 <= '0';
 				 sel2 <= '0';
				 incPC <= '1';
	   end case;
	end if;
end if;
end process;
end controller;

