-- ============================================================================
-- Register File Testbench
-- Tests load and read operations for registers A, B, C
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file_tb is
end entity register_file_tb;

architecture testbench of register_file_tb is

    component register_file is
        port (
            clk, reset : in std_logic;
            loadA, loadB, loadC : in std_logic;
            dataInA, dataInB, dataInC : in std_logic_vector(15 downto 0);
            regA, regB, regC : out std_logic_vector(15 downto 0)
        );
    end component;

    signal clk     : std_logic := '0';
    signal reset   : std_logic := '0';
    signal loadA, loadB, loadC : std_logic := '0';
    signal dataInA, dataInB, dataInC : std_logic_vector(15 downto 0) := (others => '0');
    signal regA, regB, regC : std_logic_vector(15 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT: register_file port map (
        clk => clk, reset => reset,
        loadA => loadA, loadB => loadB, loadC => loadC,
        dataInA => dataInA, dataInB => dataInB, dataInC => dataInC,
        regA => regA, regB => regB, regC => regC
    );

    clk <= not clk after CLK_PERIOD / 2;

    process
    begin
        -- Reset
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        wait for CLK_PERIOD;

        -- Verify all registers are zero after reset
        assert regA = x"0000" report "Register A not zero after reset" severity error;
        assert regB = x"0000" report "Register B not zero after reset" severity error;
        assert regC = x"0000" report "Register C not zero after reset" severity error;

        -- Load register A
        dataInA <= x"DEAD";
        loadA <= '1';
        wait for CLK_PERIOD;
        loadA <= '0';
        wait for CLK_PERIOD;
        assert regA = x"DEAD" report "Register A load failed" severity error;
        assert regB = x"0000" report "Register B changed during A load" severity error;

        -- Load register B
        dataInB <= x"BEEF";
        loadB <= '1';
        wait for CLK_PERIOD;
        loadB <= '0';
        wait for CLK_PERIOD;
        assert regB = x"BEEF" report "Register B load failed" severity error;
        assert regA = x"DEAD" report "Register A changed during B load" severity error;

        -- Load register C
        dataInC <= x"CAFE";
        loadC <= '1';
        wait for CLK_PERIOD;
        loadC <= '0';
        wait for CLK_PERIOD;
        assert regC = x"CAFE" report "Register C load failed" severity error;

        -- Simultaneous load of all registers
        dataInA <= x"1111";
        dataInB <= x"2222";
        dataInC <= x"3333";
        loadA <= '1'; loadB <= '1'; loadC <= '1';
        wait for CLK_PERIOD;
        loadA <= '0'; loadB <= '0'; loadC <= '0';
        wait for CLK_PERIOD;
        assert regA = x"1111" report "Simultaneous load A failed" severity error;
        assert regB = x"2222" report "Simultaneous load B failed" severity error;
        assert regC = x"3333" report "Simultaneous load C failed" severity error;

        -- Verify data retention (no load enables, data should not change)
        dataInA <= x"FFFF";
        dataInB <= x"FFFF";
        dataInC <= x"FFFF";
        wait for CLK_PERIOD * 3;
        assert regA = x"1111" report "Register A changed without load" severity error;
        assert regB = x"2222" report "Register B changed without load" severity error;
        assert regC = x"3333" report "Register C changed without load" severity error;

        -- Reset clears everything
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        wait for CLK_PERIOD;
        assert regA = x"0000" report "Reset failed for A" severity error;
        assert regB = x"0000" report "Reset failed for B" severity error;
        assert regC = x"0000" report "Reset failed for C" severity error;

        report "=== Register File Testbench PASSED ===" severity note;
        wait;
    end process;

end architecture testbench;
