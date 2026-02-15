-- ============================================================================
-- Program Counter Testbench
-- Tests reset, increment, load (jump), and decrement operations
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity program_counter_tb is
end entity program_counter_tb;

architecture testbench of program_counter_tb is

    component program_counter is
        port (
            clk, reset, loadPC, incPC, decPC : in std_logic;
            pcIn  : in  std_logic_vector(15 downto 0);
            pcOut : out std_logic_vector(15 downto 0)
        );
    end component;

    signal clk    : std_logic := '0';
    signal reset  : std_logic := '0';
    signal loadPC : std_logic := '0';
    signal incPC  : std_logic := '0';
    signal decPC  : std_logic := '0';
    signal pcIn   : std_logic_vector(15 downto 0) := (others => '0');
    signal pcOut  : std_logic_vector(15 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT: program_counter port map (
        clk => clk, reset => reset,
        loadPC => loadPC, incPC => incPC, decPC => decPC,
        pcIn => pcIn, pcOut => pcOut
    );

    clk <= not clk after CLK_PERIOD / 2;

    process
    begin
        -- Reset
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        assert pcOut = x"0000" report "PC not zero after reset" severity error;

        -- Increment 5 times
        incPC <= '1';
        for i in 1 to 5 loop
            wait for CLK_PERIOD;
        end loop;
        incPC <= '0';
        wait for 1 ns;
        assert pcOut = x"0005" report "PC should be 5 after 5 increments" severity error;

        -- Load a jump address
        pcIn <= x"0020";
        loadPC <= '1';
        wait for CLK_PERIOD;
        loadPC <= '0';
        wait for 1 ns;
        assert pcOut = x"0020" report "PC load failed" severity error;

        -- Continue incrementing from loaded address
        incPC <= '1';
        wait for CLK_PERIOD;
        wait for CLK_PERIOD;
        incPC <= '0';
        wait for 1 ns;
        assert pcOut = x"0022" report "PC increment after load failed" severity error;

        -- Decrement
        decPC <= '1';
        wait for CLK_PERIOD;
        decPC <= '0';
        wait for 1 ns;
        assert pcOut = x"0021" report "PC decrement failed" severity error;

        -- Reset again
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        assert pcOut = x"0000" report "Second reset failed" severity error;

        report "=== Program Counter Testbench PASSED ===" severity note;
        wait;
    end process;

end architecture testbench;
