-- ============================================================================
-- ALU Testbench - Comprehensive test for all ALU operations
-- Tests arithmetic, logic, shift, and flag generation
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_tb is
end entity alu_tb;

architecture testbench of alu_tb is

    component alu is
        port (
            A, B     : in  std_logic_vector(15 downto 0);
            opcode   : in  std_logic_vector(2 downto 0);
            mode     : in  std_logic_vector(1 downto 0);
            result   : out std_logic_vector(15 downto 0);
            overflow, eq, gt, zero, carry : out std_logic
        );
    end component;

    signal A, B       : std_logic_vector(15 downto 0) := (others => '0');
    signal opcode     : std_logic_vector(2 downto 0) := "000";
    signal mode       : std_logic_vector(1 downto 0) := "00";
    signal result     : std_logic_vector(15 downto 0);
    signal overflow_f : std_logic;
    signal eq_f       : std_logic;
    signal gt_f       : std_logic;
    signal zero_f     : std_logic;
    signal carry_f    : std_logic;

begin

    DUT: alu port map (
        A => A, B => B, opcode => opcode, mode => mode,
        result => result, overflow => overflow_f, eq => eq_f,
        gt => gt_f, zero => zero_f, carry => carry_f
    );

    process
    begin
        -- ============================
        -- MODE 00: Arithmetic
        -- ============================

        -- Test ADD: 10 + 20 = 30
        mode <= "00"; opcode <= "000";
        A <= x"000A"; B <= x"0014";
        wait for 10 ns;
        assert result = x"001E" report "ADD: 10+20 failed" severity error;
        assert zero_f = '0' report "ADD: zero flag wrong" severity error;

        -- Test ADD: 0 + 0 = 0 (zero flag)
        A <= x"0000"; B <= x"0000";
        wait for 10 ns;
        assert result = x"0000" report "ADD: 0+0 failed" severity error;
        assert zero_f = '1' report "ADD: zero flag should be set" severity error;
        assert eq_f = '1' report "ADD: eq flag should be set" severity error;

        -- Test ADD overflow: 0x7FFF + 1 = 0x8000 (signed overflow)
        A <= x"7FFF"; B <= x"0001";
        wait for 10 ns;
        assert result = x"8000" report "ADD: overflow case failed" severity error;
        assert overflow_f = '1' report "ADD: overflow flag should be set" severity error;

        -- Test ADD carry: 0xFFFF + 1 = 0x0000 (carry out)
        A <= x"FFFF"; B <= x"0001";
        wait for 10 ns;
        assert result = x"0000" report "ADD: carry case failed" severity error;
        assert carry_f = '1' report "ADD: carry flag should be set" severity error;
        assert zero_f = '1' report "ADD: zero flag should be set on wraparound" severity error;

        -- Test SUB: 20 - 10 = 10
        opcode <= "001";
        A <= x"0014"; B <= x"000A";
        wait for 10 ns;
        assert result = x"000A" report "SUB: 20-10 failed" severity error;
        assert gt_f = '1' report "SUB: gt flag should be set" severity error;

        -- Test SUB: 10 - 10 = 0
        A <= x"000A"; B <= x"000A";
        wait for 10 ns;
        assert result = x"0000" report "SUB: 10-10 failed" severity error;
        assert zero_f = '1' report "SUB: zero flag should be set" severity error;
        assert eq_f = '1' report "SUB: eq flag should be set" severity error;

        -- Test SUB: 5 - 10 (unsigned underflow)
        A <= x"0005"; B <= x"000A";
        wait for 10 ns;
        assert result = x"FFFB" report "SUB: 5-10 underflow failed" severity error;

        -- Test MUL: 3 * 4 = 12
        opcode <= "010";
        A <= x"0003"; B <= x"0004";
        wait for 10 ns;
        assert result = x"000C" report "MUL: 3*4 failed" severity error;

        -- Test MUL: 256 * 256 = 65536 (overflow into upper 16 bits)
        A <= x"0100"; B <= x"0100";
        wait for 10 ns;
        assert result = x"0000" report "MUL: 256*256 lower bits failed" severity error;
        assert overflow_f = '1' report "MUL: overflow should be set" severity error;

        -- Test INC: 41 + 1 = 42
        opcode <= "011";
        A <= x"0029"; B <= x"0000";
        wait for 10 ns;
        assert result = x"002A" report "INC: 41+1 failed" severity error;

        -- Test DEC: 42 - 1 = 41
        opcode <= "100";
        A <= x"002A"; B <= x"0000";
        wait for 10 ns;
        assert result = x"0029" report "DEC: 42-1 failed" severity error;

        -- Test CMP: A > B -> result = A, flags set
        opcode <= "101";
        A <= x"0014"; B <= x"000A";
        wait for 10 ns;
        assert result = x"0014" report "CMP: result should be A" severity error;
        assert gt_f = '1' report "CMP: gt flag should be set" severity error;

        -- ============================
        -- MODE 01: Logic
        -- ============================
        mode <= "01";

        -- Test AND
        opcode <= "000";
        A <= x"FF00"; B <= x"0FF0";
        wait for 10 ns;
        assert result = x"0F00" report "AND failed" severity error;

        -- Test OR
        opcode <= "001";
        A <= x"FF00"; B <= x"00FF";
        wait for 10 ns;
        assert result = x"FFFF" report "OR failed" severity error;

        -- Test NAND
        opcode <= "010";
        A <= x"FFFF"; B <= x"FFFF";
        wait for 10 ns;
        assert result = x"0000" report "NAND of all-1s failed" severity error;

        -- Test NOR
        opcode <= "011";
        A <= x"0000"; B <= x"0000";
        wait for 10 ns;
        assert result = x"FFFF" report "NOR of zeros failed" severity error;

        -- Test NOT A
        opcode <= "100";
        A <= x"A5A5"; B <= x"0000";
        wait for 10 ns;
        assert result = x"5A5A" report "NOT A failed" severity error;

        -- Test NOT B
        opcode <= "101";
        A <= x"0000"; B <= x"FF00";
        wait for 10 ns;
        assert result = x"00FF" report "NOT B failed" severity error;

        -- Test XOR
        opcode <= "110";
        A <= x"AAAA"; B <= x"5555";
        wait for 10 ns;
        assert result = x"FFFF" report "XOR failed" severity error;

        -- Test XNOR
        opcode <= "111";
        A <= x"AAAA"; B <= x"AAAA";
        wait for 10 ns;
        assert result = x"FFFF" report "XNOR of equal values failed" severity error;

        -- ============================
        -- MODE 11: Shift
        -- ============================
        mode <= "11";

        -- Test SHR by 1
        opcode <= "000";
        A <= x"8000"; B <= x"0001";
        wait for 10 ns;
        assert result = x"4000" report "SHR by 1 failed" severity error;

        -- Test SHL by 1
        opcode <= "001";
        A <= x"0001"; B <= x"0001";
        wait for 10 ns;
        assert result = x"0002" report "SHL by 1 failed" severity error;

        -- Test SHL by 4
        A <= x"000F"; B <= x"0004";
        wait for 10 ns;
        assert result = x"00F0" report "SHL by 4 failed" severity error;

        -- Test ROL
        opcode <= "011";
        A <= x"8001"; B <= x"0000";
        wait for 10 ns;
        assert result = x"0003" report "ROL failed" severity error;

        -- Test ROR
        opcode <= "100";
        A <= x"0001"; B <= x"0000";
        wait for 10 ns;
        assert result = x"8000" report "ROR failed" severity error;

        report "=== ALU Testbench PASSED ===" severity note;
        wait;
    end process;

end architecture testbench;
