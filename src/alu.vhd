-- ============================================================================
-- ALU (Arithmetic Logic Unit) for 16-Bit CPU
-- Supports arithmetic, logic, shift, and comparison operations
-- ============================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port (
        A        : in  std_logic_vector(15 downto 0);
        B        : in  std_logic_vector(15 downto 0);
        opcode   : in  std_logic_vector(2 downto 0);
        mode     : in  std_logic_vector(1 downto 0);
        result   : out std_logic_vector(15 downto 0);
        overflow : out std_logic;
        eq       : out std_logic;
        gt       : out std_logic;
        zero     : out std_logic;
        carry    : out std_logic
    );
end entity alu;

architecture behavioral of alu is
    signal result_i : std_logic_vector(15 downto 0);
    signal add_full : std_logic_vector(16 downto 0);
    signal sub_full : std_logic_vector(16 downto 0);
begin

    process(A, B, opcode, mode)
        variable mul_result : std_logic_vector(31 downto 0);
    begin
        -- Default outputs
        result_i <= (others => '0');
        overflow <= '0';
        carry    <= '0';

        case mode is
            -- ==============================================
            -- Mode 00: Arithmetic operations
            -- ==============================================
            when "00" =>
                case opcode is
                    when "000" =>  -- ADD: C = A + B
                        add_full <= std_logic_vector(unsigned('0' & A) + unsigned('0' & B));
                        result_i <= add_full(15 downto 0);
                        carry    <= add_full(16);
                        -- Signed overflow: both operands same sign, result different sign
                        overflow <= (A(15) xnor B(15)) and (A(15) xor add_full(15));

                    when "001" =>  -- SUB: C = A - B
                        sub_full <= std_logic_vector(unsigned('0' & A) - unsigned('0' & B));
                        result_i <= sub_full(15 downto 0);
                        carry    <= sub_full(16);  -- borrow
                        overflow <= (A(15) xor B(15)) and (A(15) xor sub_full(15));

                    when "010" =>  -- MUL: C = lower 16 bits of A * B
                        mul_result := std_logic_vector(unsigned(A) * unsigned(B));
                        result_i <= mul_result(15 downto 0);
                        -- Overflow if upper 16 bits are non-zero
                        if unsigned(mul_result(31 downto 16)) /= 0 then
                            overflow <= '1';
                        end if;

                    when "011" =>  -- INC: C = A + 1
                        add_full <= std_logic_vector(unsigned('0' & A) + 1);
                        result_i <= add_full(15 downto 0);
                        carry    <= add_full(16);
                        overflow <= (not A(15)) and add_full(15);

                    when "100" =>  -- DEC: C = A - 1
                        sub_full <= std_logic_vector(unsigned('0' & A) - 1);
                        result_i <= sub_full(15 downto 0);
                        carry    <= sub_full(16);
                        overflow <= A(15) and (not sub_full(15));

                    when "101" =>  -- CMP: A - B (set flags only, result = A)
                        sub_full <= std_logic_vector(unsigned('0' & A) - unsigned('0' & B));
                        result_i <= A;  -- Don't change registers
                        carry    <= sub_full(16);
                        overflow <= (A(15) xor B(15)) and (A(15) xor sub_full(15));

                    when "110" =>  -- PASS A (used for moves)
                        result_i <= A;

                    when "111" =>  -- PASS B
                        result_i <= B;

                    when others =>
                        result_i <= (others => '0');
                end case;

            -- ==============================================
            -- Mode 01: Logic operations
            -- ==============================================
            when "01" =>
                case opcode is
                    when "000" =>  -- AND
                        result_i <= A and B;
                    when "001" =>  -- OR
                        result_i <= A or B;
                    when "010" =>  -- NAND
                        result_i <= A nand B;
                    when "011" =>  -- NOR
                        result_i <= A nor B;
                    when "100" =>  -- NOT A
                        result_i <= not A;
                    when "101" =>  -- NOT B
                        result_i <= not B;
                    when "110" =>  -- XOR
                        result_i <= A xor B;
                    when "111" =>  -- XNOR
                        result_i <= A xnor B;
                    when others =>
                        result_i <= (others => '0');
                end case;

            -- ==============================================
            -- Mode 10: Load/Store support (pass-through)
            -- ==============================================
            when "10" =>
                case opcode is
                    when "000" =>  -- Pass A
                        result_i <= A;
                    when "001" =>  -- Pass B
                        result_i <= B;
                    when others =>
                        result_i <= A;
                end case;

            -- ==============================================
            -- Mode 11: Shift operations
            -- ==============================================
            when "11" =>
                case opcode is
                    when "000" =>  -- SHR (logical shift right by B(3:0))
                        case B(3 downto 0) is
                            when "0001" => result_i <= '0' & A(15 downto 1);
                            when "0010" => result_i <= "00" & A(15 downto 2);
                            when "0011" => result_i <= "000" & A(15 downto 3);
                            when "0100" => result_i <= "0000" & A(15 downto 4);
                            when "0101" => result_i <= "00000" & A(15 downto 5);
                            when "0110" => result_i <= "000000" & A(15 downto 6);
                            when "0111" => result_i <= "0000000" & A(15 downto 7);
                            when "1000" => result_i <= "00000000" & A(15 downto 8);
                            when others => result_i <= A;
                        end case;

                    when "001" =>  -- SHL (logical shift left by B(3:0))
                        case B(3 downto 0) is
                            when "0001" => result_i <= A(14 downto 0) & '0';
                            when "0010" => result_i <= A(13 downto 0) & "00";
                            when "0011" => result_i <= A(12 downto 0) & "000";
                            when "0100" => result_i <= A(11 downto 0) & "0000";
                            when "0101" => result_i <= A(10 downto 0) & "00000";
                            when "0110" => result_i <= A(9 downto 0) & "000000";
                            when "0111" => result_i <= A(8 downto 0) & "0000000";
                            when "1000" => result_i <= A(7 downto 0) & "00000000";
                            when others => result_i <= A;
                        end case;

                    when "010" =>  -- SRA (arithmetic shift right, preserves sign)
                        case B(3 downto 0) is
                            when "0001" => result_i <= A(15) & A(15 downto 1);
                            when "0010" => result_i <= A(15) & A(15) & A(15 downto 2);
                            when "0011" => result_i <= A(15) & A(15) & A(15) & A(15 downto 3);
                            when "0100" => result_i <= (15 downto 12 => A(15)) & A(15 downto 4);
                            when others => result_i <= A;
                        end case;

                    when "011" =>  -- ROL (rotate left by 1)
                        result_i <= A(14 downto 0) & A(15);

                    when "100" =>  -- ROR (rotate right by 1)
                        result_i <= A(0) & A(15 downto 1);

                    when others =>
                        result_i <= A;
                end case;

            when others =>
                result_i <= (others => '0');
        end case;
    end process;

    -- Output assignments
    result <= result_i;

    -- Flag generation
    zero <= '1' when result_i = x"0000" else '0';
    eq   <= '1' when A = B else '0';
    gt   <= '1' when unsigned(A) > unsigned(B) else '0';

end architecture behavioral;
