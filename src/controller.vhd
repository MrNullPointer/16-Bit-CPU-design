-- ============================================================================
-- Controller (Control Unit) for 16-Bit CPU
-- Implements a 4-state FSM: RESET -> FETCH -> DECODE -> EXECUTE
-- Generates all control signals for the datapath
--
-- Expanded ISA with 4 modes:
--   Mode 00 - Arithmetic: ADD, SUB, MUL, INC, DEC, CMP, NOP, HALT
--   Mode 01 - Logic:      AND, OR, NAND, NOR, NOTA, NOTB, XOR, XNOR
--   Mode 10 - Memory/Imm: LDA, LDB, STC, LIC, JMP, JE, JGT, JZ
--   Mode 11 - Shift/Call: SHR, SHL, SRA, ROL, ROR, CALL, RET, RETI
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        -- ALU status flags
        flag_zero : in  std_logic;
        flag_eq   : in  std_logic;
        flag_gt   : in  std_logic;
        flag_ovf  : in  std_logic;
        flag_carry: in  std_logic;
        -- Interrupt
        irq       : in  std_logic;
        -- Instruction fields
        mode      : in  std_logic_vector(1 downto 0);
        opcode    : in  std_logic_vector(2 downto 0);
        -- Control outputs
        loadIR    : out std_logic;
        loadA     : out std_logic;
        loadB     : out std_logic;
        loadC     : out std_logic;
        loadPC    : out std_logic;
        incPC     : out std_logic;
        -- Memory control
        we_DM     : out std_logic;
        re_IM     : out std_logic;
        -- ALU control
        alu_mode  : out std_logic_vector(1 downto 0);
        alu_op    : out std_logic_vector(2 downto 0);
        -- Mux selects
        sel_pcSrc : out std_logic;  -- 0=PC+1, 1=operand (jump target)
        sel_regSrc: out std_logic;  -- 0=ALU result, 1=memory data
        -- Stack control
        sp_push   : out std_logic;
        sp_pop    : out std_logic;
        we_stack  : out std_logic;  -- Write PC to stack memory
        re_stack  : out std_logic;  -- Read return address from stack
        -- Status
        halted    : out std_logic;
        -- Interrupt ack
        irq_ack   : out std_logic
    );
end entity controller;

architecture behavioral of controller is
    type state_type is (S_RESET, S_FETCH, S_DECODE, S_EXECUTE, S_HALTED, S_IRQ_SAVE);
    signal state     : state_type;
    signal next_state: state_type;
    signal halt_flag : std_logic;
    signal irq_saved : std_logic;
begin

    -- State register
    process(clk, reset)
    begin
        if reset = '1' then
            state <= S_RESET;
            halt_flag <= '0';
            irq_saved <= '0';
        elsif rising_edge(clk) then
            state <= next_state;
            if state = S_EXECUTE and mode = "00" and opcode = "111" then
                halt_flag <= '1';
            end if;
            if state = S_IRQ_SAVE then
                irq_saved <= '1';
            end if;
            if state = S_EXECUTE and mode = "11" and opcode = "111" then
                irq_saved <= '0';  -- RETI clears saved state
            end if;
        end if;
    end process;

    -- Next state logic
    process(state, halt_flag, irq, irq_saved)
    begin
        case state is
            when S_RESET =>
                next_state <= S_FETCH;

            when S_FETCH =>
                next_state <= S_DECODE;

            when S_DECODE =>
                next_state <= S_EXECUTE;

            when S_EXECUTE =>
                if halt_flag = '1' or (mode = "00" and opcode = "111") then
                    next_state <= S_HALTED;
                elsif irq = '1' and irq_saved = '0' then
                    next_state <= S_IRQ_SAVE;
                else
                    next_state <= S_FETCH;
                end if;

            when S_HALTED =>
                if reset = '1' then
                    next_state <= S_RESET;
                elsif irq = '1' then
                    next_state <= S_IRQ_SAVE;
                else
                    next_state <= S_HALTED;
                end if;

            when S_IRQ_SAVE =>
                next_state <= S_FETCH;

            when others =>
                next_state <= S_RESET;
        end case;
    end process;

    -- Output logic
    process(state, mode, opcode, flag_zero, flag_eq, flag_gt, flag_ovf, flag_carry)
    begin
        -- Default all outputs to inactive
        loadIR     <= '0';
        loadA      <= '0';
        loadB      <= '0';
        loadC      <= '0';
        loadPC     <= '0';
        incPC      <= '0';
        we_DM      <= '0';
        re_IM      <= '0';
        alu_mode   <= "00";
        alu_op     <= "000";
        sel_pcSrc  <= '0';
        sel_regSrc <= '0';
        sp_push    <= '0';
        sp_pop     <= '0';
        we_stack   <= '0';
        re_stack   <= '0';
        halted     <= '0';
        irq_ack    <= '0';

        case state is
            when S_RESET =>
                -- Everything stays at defaults (inactive)
                null;

            when S_FETCH =>
                -- Read instruction from instruction memory at PC address
                re_IM  <= '1';
                loadIR <= '1';

            when S_DECODE =>
                -- Instruction is being decoded (combinational from IR)
                -- Set up ALU with mode/opcode for next cycle
                alu_mode <= mode;
                alu_op   <= opcode;

            when S_EXECUTE =>
                alu_mode <= mode;
                alu_op   <= opcode;

                case mode is
                    -- ==========================================
                    -- Mode 00: Arithmetic operations
                    -- ==========================================
                    when "00" =>
                        case opcode is
                            when "000" =>  -- ADD: C = A + B
                                loadC <= '1';
                                incPC <= '1';

                            when "001" =>  -- SUB: C = A - B
                                loadC <= '1';
                                incPC <= '1';

                            when "010" =>  -- MUL: C = A * B
                                loadC <= '1';
                                incPC <= '1';

                            when "011" =>  -- INC: C = A + 1
                                loadC <= '1';
                                incPC <= '1';

                            when "100" =>  -- DEC: C = A - 1
                                loadC <= '1';
                                incPC <= '1';

                            when "101" =>  -- CMP: sets flags, no register write
                                incPC <= '1';

                            when "110" =>  -- NOP
                                incPC <= '1';

                            when "111" =>  -- HALT
                                halted <= '1';

                            when others =>
                                incPC <= '1';
                        end case;

                    -- ==========================================
                    -- Mode 01: Logic operations
                    -- ==========================================
                    when "01" =>
                        loadC <= '1';  -- All logic ops write to C
                        incPC <= '1';

                    -- ==========================================
                    -- Mode 10: Memory / Immediate / Branches
                    -- ==========================================
                    when "10" =>
                        case opcode is
                            when "000" =>  -- LDA: A = Mem[operand]
                                sel_regSrc <= '1';  -- Select memory data
                                loadA <= '1';
                                incPC <= '1';

                            when "001" =>  -- LDB: B = Mem[operand]
                                sel_regSrc <= '1';
                                loadB <= '1';
                                incPC <= '1';

                            when "010" =>  -- STC: Mem[operand] = C
                                we_DM <= '1';
                                incPC <= '1';

                            when "011" =>  -- LIC: C = immediate (zero-extended operand)
                                loadC <= '1';
                                incPC <= '1';

                            when "100" =>  -- JMP: PC = operand (unconditional)
                                sel_pcSrc <= '1';
                                loadPC    <= '1';

                            when "101" =>  -- JE: jump if A == B
                                if flag_eq = '1' then
                                    sel_pcSrc <= '1';
                                    loadPC    <= '1';
                                else
                                    incPC <= '1';
                                end if;

                            when "110" =>  -- JGT: jump if A > B
                                if flag_gt = '1' then
                                    sel_pcSrc <= '1';
                                    loadPC    <= '1';
                                else
                                    incPC <= '1';
                                end if;

                            when "111" =>  -- JZ: jump if zero flag set
                                if flag_zero = '1' then
                                    sel_pcSrc <= '1';
                                    loadPC    <= '1';
                                else
                                    incPC <= '1';
                                end if;

                            when others =>
                                incPC <= '1';
                        end case;

                    -- ==========================================
                    -- Mode 11: Shift / Subroutine
                    -- ==========================================
                    when "11" =>
                        case opcode is
                            when "000" =>  -- SHR
                                loadC <= '1';
                                incPC <= '1';

                            when "001" =>  -- SHL
                                loadC <= '1';
                                incPC <= '1';

                            when "010" =>  -- SRA (arithmetic shift right)
                                loadC <= '1';
                                incPC <= '1';

                            when "011" =>  -- ROL (rotate left)
                                loadC <= '1';
                                incPC <= '1';

                            when "100" =>  -- ROR (rotate right)
                                loadC <= '1';
                                incPC <= '1';

                            when "101" =>  -- CALL: push PC+1, jump to operand
                                sp_push   <= '1';
                                we_stack  <= '1';
                                sel_pcSrc <= '1';
                                loadPC    <= '1';

                            when "110" =>  -- RET: pop return address, jump to it
                                re_stack <= '1';
                                sp_pop   <= '1';
                                loadPC   <= '1';

                            when "111" =>  -- RETI: return from interrupt
                                re_stack <= '1';
                                sp_pop   <= '1';
                                loadPC   <= '1';
                                irq_ack  <= '1';

                            when others =>
                                incPC <= '1';
                        end case;

                    when others =>
                        incPC <= '1';
                end case;

            when S_HALTED =>
                halted <= '1';

            when S_IRQ_SAVE =>
                -- Push current PC to stack, then vector to interrupt handler
                sp_push  <= '1';
                we_stack <= '1';
                -- The CPU top-level will handle loading the interrupt vector address

            when others =>
                null;
        end case;
    end process;

end architecture behavioral;
