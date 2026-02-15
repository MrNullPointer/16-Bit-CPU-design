
-------------------------------------------
---** How to use port maps in AND Gate**---
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity and16 is

	generic (n : integer := 16);
	port( in1 : in std_logic_vector (n-1 downto 0);
	      in2 : in std_logic_vector (n-1 downto 0);
	      out1 : out std_logic_vector (n-1 downto 0));
end and16;

architecture and16 of and16 is 
 begin
          out1 <= in1 and in2;    
 end and16;

--------------
---** OR **---
--------------

library ieee;
use ieee.std_logic_1164.all;

entity test is
	port (a, b : in std_logic_vector (15 downto 0);
	       out4 : out std_logic_vector (15 downto 0));
end entity;

architecture behavior of test is 
component and16 is

	port( in1 : in std_logic_vector (15 downto 0);
	      in2 : in std_logic_vector (15 downto 0);
	      out1 : out std_logic_vector (15 downto 0));
end component;
 

begin
       p1: and16 port map(a, b, out4);
end;