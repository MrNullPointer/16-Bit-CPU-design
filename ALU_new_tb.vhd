LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_ARITH.ALL;
USE ieee.std_logic_UNSIGNED.ALL;
USE ieee.numeric_std.ALL;
 
entity ALU_tb is
end ALU_tb;

architecture behavior of ALU_tb is

component ALU
port (A : in std_logic_vector (15 downto 0);
      B : in std_logic_vector (15 downto 0);
      opcode1: in std_logic_vector (2 downto 0);
      Mode   : in std_logic_vector (1 downto 0);
      output : out std_logic_vector(31 downto 0);
      Overflow, EQ, GT, ZA, ZB : out std_logic);
end component;


signal A_tb, B_tb : std_logic_vector (15 downto 0);
signal mode_tb : std_logic_vector (1 downto 0);
signal opcode_tb : std_logic_vector (2 downto 0);
signal Overflow, EQ, GT, ZA, ZB :  std_logic;
signal output : std_logic_vector (31 downto 0); 

begin

DUT : ALU port map ( A => A_tb, B => B_tb , mode => mode_tb , opcode1 => opcode_tb , output => output, Overflow =>Overflow , EQ =>EQ , GT => GT, ZA =>ZA , ZB => ZB );

process
begin
        A_tb <= "0000000000000000";
        B_tb <= "0101010101010101";
        mode_tb <= "00";
        opcode_tb <= "001";
        wait for 10 ns;

        A_tb <= "0000000000111111";
        B_tb <= "0000000000000000";
        mode_tb <= "01";
        opcode_tb <= "000";
        wait for 10 ns;      


        A_tb <= "0000000000111111";
        B_tb <= "0000000000111111";
        mode_tb <= "01";
        opcode_tb <= "111";
        wait for 10 ns;


        A_tb <= "1111111111111111";
        B_tb <= "1111111111111111";
        mode_tb <= "01";
        opcode_tb <= "101";
        wait for 10 ns;

 
        A_tb <= "1010100000111111";
        B_tb <= "0111110000100010";
        mode_tb <= "01";
        opcode_tb <= "011";
        wait for 10 ns;

 
end process;
end behavior;

