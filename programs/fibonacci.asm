; ============================================
; Program: Fibonacci Sequence Generator
; Computes Fibonacci numbers: 0, 1, 1, 2, 3, 5, 8, 13, 21, ...
; Stores results in data memory starting at address 0x50
; ============================================

    ; Initialize: fib(0) = 0, fib(1) = 1
    LIC  0          ; C = 0
    STC  0x50       ; mem[0x50] = 0  (fib[0])
    LIC  1          ; C = 1
    STC  0x51       ; mem[0x51] = 1  (fib[1])

    ; Compute fib(2) = fib(0) + fib(1) = 1
    LDA  0x50       ; A = 0
    LDB  0x51       ; B = 1
    ADD             ; C = A + B = 1
    STC  0x52       ; mem[0x52] = 1

    ; Compute fib(3) = fib(1) + fib(2) = 2
    LDA  0x51       ; A = 1
    LDB  0x52       ; B = 1
    ADD             ; C = 2
    STC  0x53       ; mem[0x53] = 2

    ; Compute fib(4) = fib(2) + fib(3) = 3
    LDA  0x52       ; A = 1
    LDB  0x53       ; B = 2
    ADD             ; C = 3
    STC  0x54       ; mem[0x54] = 3

    ; Compute fib(5) = fib(3) + fib(4) = 5
    LDA  0x53       ; A = 2
    LDB  0x54       ; B = 3
    ADD             ; C = 5
    STC  0x55       ; mem[0x55] = 5

    ; Compute fib(6) = fib(4) + fib(5) = 8
    LDA  0x54       ; A = 3
    LDB  0x55       ; B = 5
    ADD             ; C = 8
    STC  0x56       ; mem[0x56] = 8

    HALT
