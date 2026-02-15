; ============================================
; Program: Logic Operations Demo
; Demonstrates all logic operations
; ============================================

    ; Load operands
    LIC  0xFF       ; C = 0x00FF
    STC  0x40       ; Store to mem
    LIC  0xF0       ; C = 0x00F0
    STC  0x41       ; Store to mem

    LDA  0x40       ; A = 0x00FF
    LDB  0x41       ; B = 0x00F0

    ; Perform logic operations (results go to C)
    AND             ; C = A AND B = 0x00F0
    STC  0x50       ; Store AND result

    LDA  0x40       ; Reload A
    LDB  0x41       ; Reload B
    OR              ; C = A OR B = 0x00FF
    STC  0x51       ; Store OR result

    LDA  0x40
    LDB  0x41
    XOR             ; C = A XOR B = 0x000F
    STC  0x52       ; Store XOR result

    LDA  0x40
    NOTA            ; C = NOT A = 0xFF00
    STC  0x53       ; Store NOT result

    HALT
