-- ============================================================================
-- Data Memory Testbench
-- Tests read, write, and reset operations on 256x16 RAM
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity data_memory_tb is
end entity data_memory_tb;

architecture testbench of data_memory_tb is

    component data_memory is
        port (
            clk, reset, we : in std_logic;
            address : in  std_logic_vector(7 downto 0);
            dataIn  : in  std_logic_vector(15 downto 0);
            dataOut : out std_logic_vector(15 downto 0)
        );
    end component;

    signal clk     : std_logic := '0';
    signal reset   : std_logic := '0';
    signal we      : std_logic := '0';
    signal address : std_logic_vector(7 downto 0) := (others => '0');
    signal dataIn  : std_logic_vector(15 downto 0) := (others => '0');
    signal dataOut : std_logic_vector(15 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT: data_memory port map (
        clk => clk, reset => reset, we => we,
        address => address, dataIn => dataIn, dataOut => dataOut
    );

    clk <= not clk after CLK_PERIOD / 2;

    process
    begin
        -- Reset: loads pre-defined values
        reset <= '1';
        wait for CLK_PERIOD;
        reset <= '0';
        wait for CLK_PERIOD;

        -- Read pre-loaded data at address 0x40 (64)
        address <= x"40";
        wait for 1 ns;
        assert dataOut = x"000A" report "Pre-loaded data at 0x40 wrong" severity error;

        -- Read pre-loaded data at address 0x41 (65)
        address <= x"41";
        wait for 1 ns;
        assert dataOut = x"0014" report "Pre-loaded data at 0x41 wrong" severity error;

        -- Write to address 0x10
        address <= x"10";
        dataIn  <= x"ABCD";
        we <= '1';
        wait for CLK_PERIOD;
        we <= '0';
        wait for 1 ns;
        assert dataOut = x"ABCD" report "Write to 0x10 failed" severity error;

        -- Write to address 0x11
        address <= x"11";
        dataIn  <= x"1234";
        we <= '1';
        wait for CLK_PERIOD;
        we <= '0';
        wait for 1 ns;
        assert dataOut = x"1234" report "Write to 0x11 failed" severity error;

        -- Verify 0x10 still holds its value
        address <= x"10";
        wait for 1 ns;
        assert dataOut = x"ABCD" report "Data at 0x10 lost" severity error;

        -- Write multiple locations
        for i in 0 to 7 loop
            address <= std_logic_vector(to_unsigned(i, 8));
            dataIn  <= std_logic_vector(to_unsigned(i * 100, 16));
            we <= '1';
            wait for CLK_PERIOD;
        end loop;
        we <= '0';

        -- Verify all written values
        for i in 0 to 7 loop
            address <= std_logic_vector(to_unsigned(i, 8));
            wait for 1 ns;
            assert dataOut = std_logic_vector(to_unsigned(i * 100, 16))
                report "Write/read loop failed at address " & integer'image(i) severity error;
        end loop;

        report "=== Data Memory Testbench PASSED ===" severity note;
        wait;
    end process;

end architecture testbench;
