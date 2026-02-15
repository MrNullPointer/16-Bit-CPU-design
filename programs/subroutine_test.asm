; ============================================
; Program: Subroutine Call/Return Test
; Tests CALL and RET instructions
; ============================================

    ; Main program
    LIC  10         ; C = 10
    STC  0x40       ; mem[0x40] = 10
    LIC  20         ; C = 20
    STC  0x41       ; mem[0x41] = 20

    CALL add_sub    ; Call subroutine at label 'add_sub'

    ; After return, result should be in mem[0x42]
    LDA  0x42       ; A = result
    HALT

; Subroutine: loads two values, adds them, stores result, returns
add_sub:
    LDA  0x40       ; A = 10
    LDB  0x41       ; B = 20
    ADD             ; C = 30
    STC  0x42       ; Store result
    RET             ; Return to caller
