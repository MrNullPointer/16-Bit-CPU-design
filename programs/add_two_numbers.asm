; ============================================
; Program: Add Two Numbers
; Loads values from memory, adds them, stores result
; ============================================

    LDA  0x40       ; A = mem[0x40] (value: 10)
    LDB  0x41       ; B = mem[0x41] (value: 20)
    ADD             ; C = A + B = 30
    STC  0x42       ; mem[0x42] = C (store result)
    HALT            ; Stop execution
