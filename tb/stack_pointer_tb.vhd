-- ============================================================================
-- Stack Pointer Testbench
-- Tests push (decrement) and pop (increment) operations
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stack_pointer_tb is
end entity stack_pointer_tb;

architecture testbench of stack_pointer_tb is

    component stack_pointer is
        port (
            clk, reset, push, pop : in std_logic;
            spOut : out std_logic_vector(7 downto 0)
        );
    end component;

    signal clk   : std_logic := '0';
    signal reset  : std_logic := '0';
    signal push   : std_logic := '0';
    signal pop    : std_logic := '0';
    signal spOut  : std_logic_vector(7 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT: stack_pointer port map (
        clk => clk, reset => reset,
        push => push, pop => pop, spOut => spOut
    );

    clk <= not clk after CLK_PERIOD / 2;

    process
    begin
        -- Reset: SP should be 0xFF
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        wait for 1 ns;
        assert spOut = x"FF" report "SP not 0xFF after reset" severity error;

        -- Push 3 times (SP decrements)
        push <= '1';
        wait for CLK_PERIOD;
        assert spOut = x"FE" report "SP after 1 push wrong" severity error;
        wait for CLK_PERIOD;
        assert spOut = x"FD" report "SP after 2 pushes wrong" severity error;
        wait for CLK_PERIOD;
        push <= '0';
        assert spOut = x"FC" report "SP after 3 pushes wrong" severity error;

        -- Pop 2 times (SP increments)
        pop <= '1';
        wait for CLK_PERIOD;
        assert spOut = x"FD" report "SP after 1 pop wrong" severity error;
        wait for CLK_PERIOD;
        pop <= '0';
        assert spOut = x"FE" report "SP after 2 pops wrong" severity error;

        -- Reset again
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        wait for 1 ns;
        assert spOut = x"FF" report "SP not restored after reset" severity error;

        report "=== Stack Pointer Testbench PASSED ===" severity note;
        wait;
    end process;

end architecture testbench;
