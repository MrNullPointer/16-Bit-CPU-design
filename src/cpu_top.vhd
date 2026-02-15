-- ============================================================================
-- Top-Level CPU Entity for 16-Bit CPU
-- Wires together: Controller, ALU, Register File, Program Counter,
--   Instruction Register, Instruction Memory, Data Memory,
--   Stack Pointer, and Multiplexers
--
-- Architecture: Von Neumann, multi-cycle (4-state FSM)
-- Word size: 16 bits
-- Address space: 8-bit (256 words each for instruction and data memory)
-- Registers: A, B, C (general), PC, IR, SP
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_top is
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        -- Interrupt request
        irq       : in  std_logic;
        irq_vec   : in  std_logic_vector(7 downto 0);  -- Interrupt handler address
        -- External I/O port
        io_port_in  : in  std_logic_vector(15 downto 0);
        io_port_out : out std_logic_vector(15 downto 0);
        io_port_we  : out std_logic;
        -- Status
        halted    : out std_logic;
        -- Debug outputs
        dbg_pc    : out std_logic_vector(15 downto 0);
        dbg_ir    : out std_logic_vector(15 downto 0);
        dbg_regA  : out std_logic_vector(15 downto 0);
        dbg_regB  : out std_logic_vector(15 downto 0);
        dbg_regC  : out std_logic_vector(15 downto 0);
        dbg_flags : out std_logic_vector(4 downto 0)  -- zero, eq, gt, ovf, carry
    );
end entity cpu_top;

architecture structural of cpu_top is

    -- ==========================================================
    -- Component declarations
    -- ==========================================================
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

    component alu is
        port (
            A, B     : in  std_logic_vector(15 downto 0);
            opcode   : in  std_logic_vector(2 downto 0);
            mode     : in  std_logic_vector(1 downto 0);
            result   : out std_logic_vector(15 downto 0);
            overflow, eq, gt, zero, carry : out std_logic
        );
    end component;

    component register_file is
        port (
            clk, reset : in std_logic;
            loadA, loadB, loadC : in std_logic;
            dataInA, dataInB, dataInC : in std_logic_vector(15 downto 0);
            regA, regB, regC : out std_logic_vector(15 downto 0)
        );
    end component;

    component program_counter is
        port (
            clk, reset, loadPC, incPC, decPC : in std_logic;
            pcIn  : in  std_logic_vector(15 downto 0);
            pcOut : out std_logic_vector(15 downto 0)
        );
    end component;

    component instruction_register is
        port (
            clk, reset, loadIR : in std_logic;
            irIn    : in  std_logic_vector(15 downto 0);
            mode    : out std_logic_vector(1 downto 0);
            opcode  : out std_logic_vector(2 downto 0);
            operand : out std_logic_vector(10 downto 0);
            irFull  : out std_logic_vector(15 downto 0)
        );
    end component;

    component instruction_memory is
        port (
            clk, reset, we : in std_logic;
            address : in  std_logic_vector(7 downto 0);
            dataIn  : in  std_logic_vector(15 downto 0);
            dataOut : out std_logic_vector(15 downto 0)
        );
    end component;

    component data_memory is
        port (
            clk, reset, we : in std_logic;
            address : in  std_logic_vector(7 downto 0);
            dataIn  : in  std_logic_vector(15 downto 0);
            dataOut : out std_logic_vector(15 downto 0)
        );
    end component;

    component stack_pointer is
        port (
            clk, reset, push, pop : in std_logic;
            spOut : out std_logic_vector(7 downto 0)
        );
    end component;

    component mux2to1 is
        port (
            inA, inB : in  std_logic_vector(15 downto 0);
            sel      : in  std_logic;
            mOut     : out std_logic_vector(15 downto 0)
        );
    end component;

    -- ==========================================================
    -- Internal signals
    -- ==========================================================

    -- Controller outputs
    signal ctrl_loadIR, ctrl_loadA, ctrl_loadB, ctrl_loadC : std_logic;
    signal ctrl_loadPC, ctrl_incPC   : std_logic;
    signal ctrl_we_DM, ctrl_re_IM    : std_logic;
    signal ctrl_alu_mode             : std_logic_vector(1 downto 0);
    signal ctrl_alu_op               : std_logic_vector(2 downto 0);
    signal ctrl_sel_pcSrc, ctrl_sel_regSrc : std_logic;
    signal ctrl_sp_push, ctrl_sp_pop : std_logic;
    signal ctrl_we_stack, ctrl_re_stack : std_logic;
    signal ctrl_halted               : std_logic;
    signal ctrl_irq_ack              : std_logic;

    -- IR outputs
    signal ir_mode    : std_logic_vector(1 downto 0);
    signal ir_opcode  : std_logic_vector(2 downto 0);
    signal ir_operand : std_logic_vector(10 downto 0);
    signal ir_full    : std_logic_vector(15 downto 0);

    -- PC signals
    signal pc_out     : std_logic_vector(15 downto 0);
    signal pc_in      : std_logic_vector(15 downto 0);
    signal pc_plus1   : std_logic_vector(15 downto 0);

    -- ALU signals
    signal alu_result  : std_logic_vector(15 downto 0);
    signal flag_zero   : std_logic;
    signal flag_eq     : std_logic;
    signal flag_gt     : std_logic;
    signal flag_ovf    : std_logic;
    signal flag_carry  : std_logic;

    -- Register outputs
    signal regA_out, regB_out, regC_out : std_logic_vector(15 downto 0);

    -- Register data inputs
    signal regA_in, regB_in, regC_in : std_logic_vector(15 downto 0);

    -- Memory signals
    signal imem_out    : std_logic_vector(15 downto 0);
    signal dmem_out    : std_logic_vector(15 downto 0);
    signal dmem_addr   : std_logic_vector(7 downto 0);
    signal dmem_dataIn : std_logic_vector(15 downto 0);

    -- Stack signals
    signal sp_out      : std_logic_vector(7 downto 0);
    signal stack_data  : std_logic_vector(15 downto 0);

    -- Operand zero-extended to 16 bits
    signal operand_ext : std_logic_vector(15 downto 0);

    -- Latched flags (persist across cycles)
    signal flag_zero_r  : std_logic;
    signal flag_eq_r    : std_logic;
    signal flag_gt_r    : std_logic;
    signal flag_ovf_r   : std_logic;
    signal flag_carry_r : std_logic;

begin

    -- ==========================================================
    -- Operand extension
    -- ==========================================================
    operand_ext <= "00000" & ir_operand;

    -- ==========================================================
    -- PC+1 computation
    -- ==========================================================
    pc_plus1 <= std_logic_vector(unsigned(pc_out) + 1);

    -- ==========================================================
    -- PC input mux: select between incremented PC and jump target
    -- ==========================================================
    -- When sel_pcSrc = '0', PC loads normally (handled by incPC)
    -- When sel_pcSrc = '1', PC loads the operand (jump/call target)
    -- For RET/RETI, PC loads from stack
    pc_in <= stack_data when ctrl_re_stack = '1' else
             operand_ext when ctrl_sel_pcSrc = '1' else
             pc_plus1;

    -- ==========================================================
    -- Register input mux
    -- ==========================================================
    -- sel_regSrc: 0 = ALU result, 1 = memory data
    -- For LIC, the operand is passed through the ALU as a pass-through
    regC_in <= dmem_out when ctrl_sel_regSrc = '1' else
               operand_ext when (ir_mode = "10" and ir_opcode = "011") else
               alu_result;

    regA_in <= dmem_out when ctrl_sel_regSrc = '1' else alu_result;
    regB_in <= dmem_out when ctrl_sel_regSrc = '1' else alu_result;

    -- ==========================================================
    -- Data memory address and data muxing
    -- ==========================================================
    -- For STC, write regC to data memory
    -- For stack operations, use SP as address
    dmem_addr <= sp_out when (ctrl_we_stack = '1' or ctrl_re_stack = '1') else
                 ir_operand(7 downto 0);

    dmem_dataIn <= pc_plus1 when ctrl_we_stack = '1' else  -- CALL: push return address
                   regC_out;                                -- STC: store register C

    -- Stack read data comes from data memory
    stack_data <= dmem_out;

    -- Data memory write: either STC or CALL (push PC)
    -- We use a combined write enable
    -- (ctrl_we_DM for STC, ctrl_we_stack for CALL)

    -- ==========================================================
    -- I/O port
    -- ==========================================================
    io_port_out <= regC_out;
    io_port_we  <= '0';  -- Can be extended for I/O instructions

    -- ==========================================================
    -- Flag latching: capture ALU flags during EXECUTE state
    -- ==========================================================
    process(clk, reset)
    begin
        if reset = '1' then
            flag_zero_r  <= '0';
            flag_eq_r    <= '0';
            flag_gt_r    <= '0';
            flag_ovf_r   <= '0';
            flag_carry_r <= '0';
        elsif rising_edge(clk) then
            -- Update flags on every cycle (ALU is combinational)
            flag_zero_r  <= flag_zero;
            flag_eq_r    <= flag_eq;
            flag_gt_r    <= flag_gt;
            flag_ovf_r   <= flag_ovf;
            flag_carry_r <= flag_carry;
        end if;
    end process;

    -- ==========================================================
    -- Component instantiations
    -- ==========================================================

    CTRL: controller port map (
        clk       => clk,
        reset     => reset,
        flag_zero => flag_zero_r,
        flag_eq   => flag_eq_r,
        flag_gt   => flag_gt_r,
        flag_ovf  => flag_ovf_r,
        flag_carry=> flag_carry_r,
        irq       => irq,
        mode      => ir_mode,
        opcode    => ir_opcode,
        loadIR    => ctrl_loadIR,
        loadA     => ctrl_loadA,
        loadB     => ctrl_loadB,
        loadC     => ctrl_loadC,
        loadPC    => ctrl_loadPC,
        incPC     => ctrl_incPC,
        we_DM     => ctrl_we_DM,
        re_IM     => ctrl_re_IM,
        alu_mode  => ctrl_alu_mode,
        alu_op    => ctrl_alu_op,
        sel_pcSrc => ctrl_sel_pcSrc,
        sel_regSrc=> ctrl_sel_regSrc,
        sp_push   => ctrl_sp_push,
        sp_pop    => ctrl_sp_pop,
        we_stack  => ctrl_we_stack,
        re_stack  => ctrl_re_stack,
        halted    => ctrl_halted,
        irq_ack   => ctrl_irq_ack
    );

    ALU_INST: alu port map (
        A        => regA_out,
        B        => regB_out,
        opcode   => ctrl_alu_op,
        mode     => ctrl_alu_mode,
        result   => alu_result,
        overflow => flag_ovf,
        eq       => flag_eq,
        gt       => flag_gt,
        zero     => flag_zero,
        carry    => flag_carry
    );

    REGS: register_file port map (
        clk     => clk,
        reset   => reset,
        loadA   => ctrl_loadA,
        loadB   => ctrl_loadB,
        loadC   => ctrl_loadC,
        dataInA => regA_in,
        dataInB => regB_in,
        dataInC => regC_in,
        regA    => regA_out,
        regB    => regB_out,
        regC    => regC_out
    );

    PC_INST: program_counter port map (
        clk    => clk,
        reset  => reset,
        loadPC => ctrl_loadPC,
        incPC  => ctrl_incPC,
        decPC  => '0',
        pcIn   => pc_in,
        pcOut  => pc_out
    );

    IR_INST: instruction_register port map (
        clk     => clk,
        reset   => reset,
        loadIR  => ctrl_loadIR,
        irIn    => imem_out,
        mode    => ir_mode,
        opcode  => ir_opcode,
        operand => ir_operand,
        irFull  => ir_full
    );

    IMEM: instruction_memory port map (
        clk     => clk,
        reset   => reset,
        we      => '0',  -- Instruction memory is read-only during execution
        address => pc_out(7 downto 0),
        dataIn  => (others => '0'),
        dataOut => imem_out
    );

    DMEM: data_memory port map (
        clk     => clk,
        reset   => reset,
        we      => ctrl_we_DM or ctrl_we_stack,
        address => dmem_addr,
        dataIn  => dmem_dataIn,
        dataOut => dmem_out
    );

    SP_INST: stack_pointer port map (
        clk   => clk,
        reset => reset,
        push  => ctrl_sp_push,
        pop   => ctrl_sp_pop,
        spOut => sp_out
    );

    -- ==========================================================
    -- Debug / status outputs
    -- ==========================================================
    halted    <= ctrl_halted;
    dbg_pc    <= pc_out;
    dbg_ir    <= ir_full;
    dbg_regA  <= regA_out;
    dbg_regB  <= regB_out;
    dbg_regC  <= regC_out;
    dbg_flags <= flag_zero_r & flag_eq_r & flag_gt_r & flag_ovf_r & flag_carry_r;

end architecture structural;
