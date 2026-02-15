-- ============================================================================
-- Controller Testbench
-- Tests FSM state transitions and control signal generation
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller_tb is
end entity controller_tb;

architecture testbench of controller_tb is

    component controller is
        port (
            clk, reset       : in  std_logic;
            flag_zero, flag_eq, flag_gt, flag_ovf, flag_carry : in std_logic;
            irq              : in  std_logic;
            mode             : in  std_logic_vector(1 downto 0);
            opcode           : in  std_logic_vector(2 downto 0);
            loadIR, loadA, loadB, loadC : out std_logic;
            loadPC, incPC    : out std_logic;
            we_DM, re_IM     : out std_logic;
            alu_mode         : out std_logic_vector(1 downto 0);
            alu_op           : out std_logic_vector(2 downto 0);
            sel_pcSrc, sel_regSrc : out std_logic;
            sp_push, sp_pop  : out std_logic;
            we_stack, re_stack : out std_logic;
            halted           : out std_logic;
            irq_ack          : out std_logic
        );
    end component;

    signal clk        : std_logic := '0';
    signal reset      : std_logic := '0';
    signal flag_zero, flag_eq, flag_gt, flag_ovf, flag_carry : std_logic := '0';
    signal irq        : std_logic := '0';
    signal mode       : std_logic_vector(1 downto 0) := "00";
    signal opcode     : std_logic_vector(2 downto 0) := "000";
    signal loadIR, loadA, loadB, loadC : std_logic;
    signal loadPC, incPC : std_logic;
    signal we_DM, re_IM  : std_logic;
    signal alu_mode    : std_logic_vector(1 downto 0);
    signal alu_op      : std_logic_vector(2 downto 0);
    signal sel_pcSrc, sel_regSrc : std_logic;
    signal sp_push, sp_pop : std_logic;
    signal we_stack, re_stack : std_logic;
    signal halted_sig  : std_logic;
    signal irq_ack     : std_logic;

    constant CLK_PERIOD : time := 10 ns;

begin

    DUT: controller port map (
        clk => clk, reset => reset,
        flag_zero => flag_zero, flag_eq => flag_eq,
        flag_gt => flag_gt, flag_ovf => flag_ovf, flag_carry => flag_carry,
        irq => irq, mode => mode, opcode => opcode,
        loadIR => loadIR, loadA => loadA, loadB => loadB, loadC => loadC,
        loadPC => loadPC, incPC => incPC,
        we_DM => we_DM, re_IM => re_IM,
        alu_mode => alu_mode, alu_op => alu_op,
        sel_pcSrc => sel_pcSrc, sel_regSrc => sel_regSrc,
        sp_push => sp_push, sp_pop => sp_pop,
        we_stack => we_stack, re_stack => re_stack,
        halted => halted_sig, irq_ack => irq_ack
    );

    clk <= not clk after CLK_PERIOD / 2;

    process
    begin
        -- Reset the controller
        reset <= '1';
        wait for CLK_PERIOD * 2;
        reset <= '0';

        -- ========================================
        -- Test ADD instruction (Mode 00, Op 000)
        -- ========================================
        mode <= "00"; opcode <= "000";

        -- S_RESET -> S_FETCH
        wait for CLK_PERIOD;
        -- In FETCH state: should assert re_IM and loadIR
        assert re_IM = '1' report "FETCH: re_IM should be 1" severity error;
        assert loadIR = '1' report "FETCH: loadIR should be 1" severity error;

        -- S_FETCH -> S_DECODE
        wait for CLK_PERIOD;

        -- S_DECODE -> S_EXECUTE
        wait for CLK_PERIOD;
        -- In EXECUTE for ADD: should load C and increment PC
        assert loadC = '1' report "ADD EXECUTE: loadC should be 1" severity error;
        assert incPC = '1' report "ADD EXECUTE: incPC should be 1" severity error;
        assert we_DM = '0' report "ADD EXECUTE: we_DM should be 0" severity error;

        -- ========================================
        -- Test LDA instruction (Mode 10, Op 000)
        -- ========================================
        -- Back to FETCH
        mode <= "10"; opcode <= "000";
        wait for CLK_PERIOD;  -- FETCH
        wait for CLK_PERIOD;  -- DECODE
        wait for CLK_PERIOD;  -- EXECUTE
        assert loadA = '1' report "LDA EXECUTE: loadA should be 1" severity error;
        assert sel_regSrc = '1' report "LDA EXECUTE: sel_regSrc should be 1 (mem)" severity error;
        assert incPC = '1' report "LDA EXECUTE: incPC should be 1" severity error;

        -- ========================================
        -- Test STC instruction (Mode 10, Op 010)
        -- ========================================
        mode <= "10"; opcode <= "010";
        wait for CLK_PERIOD;  -- FETCH
        wait for CLK_PERIOD;  -- DECODE
        wait for CLK_PERIOD;  -- EXECUTE
        assert we_DM = '1' report "STC EXECUTE: we_DM should be 1" severity error;
        assert loadC = '0' report "STC EXECUTE: loadC should be 0" severity error;

        -- ========================================
        -- Test JMP instruction (Mode 10, Op 100)
        -- ========================================
        mode <= "10"; opcode <= "100";
        wait for CLK_PERIOD;  -- FETCH
        wait for CLK_PERIOD;  -- DECODE
        wait for CLK_PERIOD;  -- EXECUTE
        assert sel_pcSrc = '1' report "JMP EXECUTE: sel_pcSrc should be 1" severity error;
        assert loadPC = '1' report "JMP EXECUTE: loadPC should be 1" severity error;
        assert incPC = '0' report "JMP EXECUTE: incPC should be 0" severity error;

        -- ========================================
        -- Test conditional JE: not taken (eq=0)
        -- ========================================
        mode <= "10"; opcode <= "101";
        flag_eq <= '0';
        wait for CLK_PERIOD;  -- FETCH
        wait for CLK_PERIOD;  -- DECODE
        wait for CLK_PERIOD;  -- EXECUTE
        assert incPC = '1' report "JE not-taken: incPC should be 1" severity error;
        assert loadPC = '0' report "JE not-taken: loadPC should be 0" severity error;

        -- ========================================
        -- Test conditional JE: taken (eq=1)
        -- ========================================
        mode <= "10"; opcode <= "101";
        flag_eq <= '1';
        wait for CLK_PERIOD;  -- FETCH
        wait for CLK_PERIOD;  -- DECODE
        wait for CLK_PERIOD;  -- EXECUTE
        assert loadPC = '1' report "JE taken: loadPC should be 1" severity error;
        assert sel_pcSrc = '1' report "JE taken: sel_pcSrc should be 1" severity error;

        -- ========================================
        -- Test CALL instruction (Mode 11, Op 101)
        -- ========================================
        flag_eq <= '0';
        mode <= "11"; opcode <= "101";
        wait for CLK_PERIOD;  -- FETCH
        wait for CLK_PERIOD;  -- DECODE
        wait for CLK_PERIOD;  -- EXECUTE
        assert sp_push = '1' report "CALL: sp_push should be 1" severity error;
        assert we_stack = '1' report "CALL: we_stack should be 1" severity error;
        assert loadPC = '1' report "CALL: loadPC should be 1" severity error;

        -- ========================================
        -- Test RET instruction (Mode 11, Op 110)
        -- ========================================
        mode <= "11"; opcode <= "110";
        wait for CLK_PERIOD;  -- FETCH
        wait for CLK_PERIOD;  -- DECODE
        wait for CLK_PERIOD;  -- EXECUTE
        assert re_stack = '1' report "RET: re_stack should be 1" severity error;
        assert sp_pop = '1' report "RET: sp_pop should be 1" severity error;
        assert loadPC = '1' report "RET: loadPC should be 1" severity error;

        -- ========================================
        -- Test HALT instruction (Mode 00, Op 111)
        -- ========================================
        mode <= "00"; opcode <= "111";
        wait for CLK_PERIOD;  -- FETCH
        wait for CLK_PERIOD;  -- DECODE
        wait for CLK_PERIOD;  -- EXECUTE
        assert halted_sig = '1' report "HALT: halted should be 1" severity error;

        -- Verify CPU stays halted
        wait for CLK_PERIOD * 3;
        assert halted_sig = '1' report "HALT: should stay halted" severity error;

        report "=== Controller Testbench PASSED ===" severity note;
        wait;
    end process;

end architecture testbench;
