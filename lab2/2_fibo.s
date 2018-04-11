.syntax unified
.cpu cortex-m4
.thumb


.text
    .global main
    .equ N, 20

N_over:
    movs R4, #-1
    bx lr
overflow:
    movs R4, #-2
    bx lr
fib:
    cmp R0, #100        //N > 100
    bgt N_over


    adds R4, R2, R3
    bvs overflow       //branch if overflow set

    movs R2, R3
    movs R3, R4

    adds R1, R1, #1 //i = i + 1
    cmp R1, #N
    blt fib

    bx lr
main:
    movs R0, #N
    movs R1, #2    //i = 0
    movs R2, #1    //f1 = 1
    movs R3, #1    //f2 = 1
    movs R4, #0

    bl fib
L: b L
