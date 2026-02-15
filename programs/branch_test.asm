; ============================================
; Program: Branch Instructions Test
; Tests conditional and unconditional jumps
; ============================================

    ; Load equal values to test JE
    LIC  42         ; C = 42
    STC  0x40       ; mem[0x40] = 42
    STC  0x41       ; mem[0x41] = 42 (same value)

    LDA  0x40       ; A = 42
    LDB  0x41       ; B = 42
    CMP             ; Compare A and B (sets EQ flag)
    JE   equal      ; Jump if equal -> should jump

    ; This should be skipped
    LIC  0xFF       ; Should NOT execute
    STC  0x50       ; Should NOT execute

equal:
    LIC  1          ; C = 1 (marker: we jumped correctly)
    STC  0x50       ; mem[0x50] = 1

    ; Test JMP (unconditional)
    JMP  done       ; Jump to end

    ; This should be skipped
    LIC  0xFF
    STC  0x51

done:
    LIC  2          ; C = 2 (marker: JMP worked)
    STC  0x51       ; mem[0x51] = 2
    HALT
