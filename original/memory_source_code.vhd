library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.Numeric_Std.all;

entity memory is
	generic (N : integer := 16;
		 M : integer := 3);
  port ( clock   : in  std_logic;
         we      : in  std_logic;
         address : in  std_logic_vector (M-1 downto 0);
         datain  : in  std_logic_vector (N-1 downto 0);
         dataout : out std_logic_vector (N-1 downto 0));
end entity memory;

architecture mem of memory is

   type ram_type is array (0 to (2**address'length)-1) of std_logic_vector (N-1 downto 0);
   signal ram : ram_type;
   --signal read_address : std_logic_vector(address'range);

begin

  process(clock) is

  begin
   if (clock'event and clock='1') then
      if we = '1' then
        ram(to_integer(unsigned(address))) <= datain;
      end if;
     
    end if;
  end process;

  dataout <= ram(to_integer(unsigned(address)));

end architecture mem;

